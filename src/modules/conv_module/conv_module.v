/*
* conv_module.v
*/

module conv_module 
  #(
    parameter integer C_S00_AXIS_TDATA_WIDTH = 32
  )
  (
    input wire clk,
    input wire rstn,

    output wire S_AXIS_TREADY,
    input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
    input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TKEEP, 
    input wire S_AXIS_TUSER, 
    input wire S_AXIS_TLAST, 
    input wire S_AXIS_TVALID, 

    input wire M_AXIS_TREADY, 
    output wire M_AXIS_TUSER, 
    output wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA, 
    output wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TKEEP, 
    output wire M_AXIS_TLAST, 
    output wire M_AXIS_TVALID, 

    input conv_start, 
    output reg conv_done,

    //////////////////////////////////////////////////////////////////////////
    // TODO : Add ports if you need them
    //////////////////////////////////////////////////////////////////////////
    input wire [2:0] command,      // 동작 명령 (1:Feature, 2:Bias, 3:Weight&Calc, 4:Send)
    input wire [8:0] input_ch,     // 입력 채널 수 (예: 3)
    input wire [8:0] output_ch,    // 출력 채널 수 (=필터 개수, 예: 8)
    input wire [5:0] feature_length,// 입력 이미지 가로/세로 크기 (예: 8)

    output reg f_writedone,        // Feature 데이터 저장 완료 신호
    output reg b_writedone,        // Bias 데이터 저장 완료 신호
    output reg cal_done,           // 연산 완료 신호
    output reg transmit_done,      // 결과 전송 완료 신호

    input wire f_writedone_ack,    // 완료 신호에 대한 TB의 응답 (Handshake)
    input wire b_writedone_ack,
    input wire cal_done_ack,
    input wire transmit_done_ack
  );
  
  //reg                                           m_axis_tuser;
  wire [C_S00_AXIS_TDATA_WIDTH-1 : 0]            m_axis_tdata;
  //reg [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0]        m_axis_tkeep;
  reg                                           m_axis_tlast;
  reg                                           m_axis_tvalid;
  wire                                          s_axis_tready;
  
  assign S_AXIS_TREADY = s_axis_tready;
  assign M_AXIS_TDATA = m_axis_tdata;
  assign M_AXIS_TLAST = m_axis_tlast;
  assign M_AXIS_TVALID = m_axis_tvalid;
  assign M_AXIS_TUSER = 1'b0;
  assign M_AXIS_TKEEP = {(C_S00_AXIS_TDATA_WIDTH/8) {1'b1}};

  ////////////////////////////////////////////////////////////////////////////
  // TODO : Write your code here
  ////////////////////////////////////////////////////////////////////////////
  reg [31:0] m_axis_tdata_reg;
  assign m_axis_tdata = m_axis_tdata_reg;

  // FSM States
  localparam STATE_IDLE       = 3'd0;
  localparam STATE_LOAD_FEAT  = 3'd1; // 입력 Feature Map 데이터 수신 및 저장
  localparam STATE_LOAD_BIAS  = 3'd2; // Bias 데이터 수신 및 저장
  localparam STATE_LOAD_WGT   = 3'd3; // Weight 데이터 수신 및 저장
  localparam STATE_CALC       = 3'd4; // Convolution 연산 수행
  localparam STATE_SEND       = 3'd5; // 결과 데이터 전송

  reg [2:0] state;

  // Input Buf: Max 8,192 Bytes (CONV2(16x16x32), CONV4(8x8x128) 입력 크기)
  reg signed [7:0] input_buf  [0:8191]; 
  // Weight Buf: Max 589,824 Bytes (CONV6(256x256x9) 가중치 크기)
  reg signed [7:0] weight_buf [0:589823]; 
  // Bias Buf: Max 256 Bytes (CONV5, CONV6 출력 채널 수)
  reg signed [7:0] bias_buf   [0:255];  
  // Output Buf: Max 32,768 Bytes (CONV1(32x32x32) 출력 크기)
  reg signed [7:0] output_buf [0:32767]; 

  // Loading Ptr: 데이터를 버퍼에 저장할 때 사용하는 주소 포인터
  reg [31:0] write_ptr; 

  // Calculation Counters (4중 루프를 위한 카운터)
  reg [8:0] co_cnt; // Output Channel (현재 계산 중인 필터 번호)
  reg [5:0] r_cnt;  // Row (출력 이미지의 세로 좌표)
  reg [5:0] c_cnt;  // Col (출력 이미지의 가로 좌표)
  reg [8:0] ci_cnt; // Input Channel (입력 이미지의 채널 번호)
  reg [1:0] ky_cnt; // Kernel Row (3x3 커널의 세로 좌표: 0~2)
  reg [1:0] kx_cnt; // Kernel Col (3x3 커널의 가로 좌표: 0~2)
  
  // MAC Accumulator
  reg signed [31:0] mac_sum; // 곱셈 결과를 계속 더해나갈 레지스터
  reg signed [31:0] psum;    // Bias까지 더한 최종 결과 (Partial Sum)

  // Sending Counters
  reg [31:0] read_ptr;           // 결과 버퍼에서 읽어올 위치
  reg [31:0] total_output_words; // 전송해야 할 총 32비트 워드 개수
  reg [31:0] sent_word_cnt;      // 현재까지 전송한 워드 개수

  // 핸드셰이킹 확인용 신호
  wire s_data_fire = S_AXIS_TVALID && s_axis_tready; // Valid와 Ready가 둘 다 1일 때 데이터가 들어옴
  wire m_data_fire = m_axis_tvalid && M_AXIS_TREADY; // Valid와 Ready가 둘 다 1일 때 데이터가 전송됨

  // Combinational Logic
  assign s_axis_tready = (state == STATE_LOAD_FEAT) || (state == STATE_LOAD_BIAS) || (state == STATE_LOAD_WGT);  // 데이터를 받아야 하는 상태(LOAD_*)일 때만 데이터 받음
  
  // 인덱스 및 값 로딩
  integer idx;
  wire [31:0] w_idx;
  wire signed [7:0] w_val;
  wire signed [7:0] i_val;
  
  assign w_idx = (co_cnt * input_ch * 9) + (ci_cnt * 9) + (ky_cnt * 3) + kx_cnt;
  assign w_val = weight_buf[w_idx];

  // Zero padding & Indexing
  wire signed [15:0] calc_row;
  wire signed [15:0] calc_col;

  assign calc_row = $signed({1'b0, r_cnt}) + $signed({1'b0, ky_cnt}) - 16'sd1;
  assign calc_col = $signed({1'b0, c_cnt}) + $signed({1'b0, kx_cnt}) - 16'sd1;

  wire is_padding;
  assign is_padding = (calc_row < 0) || (calc_row >= $signed({1'b0, feature_length})) || (calc_col < 0) || (calc_col >= $signed({1'b0, feature_length}));
  
  wire [31:0] calc_idx;
  assign calc_idx = (ci_cnt * feature_length * feature_length) + (calc_row * feature_length) + calc_col;

  assign i_val = (is_padding) ? 8'sd0 : input_buf[calc_idx];

  // 계산 중간 단계
  wire signed [31:0] current_mult;  // 현재 곱셈 값
  wire signed [31:0] next_mac_sum;  // 현재까지의 누적 합 (현재 곱셈 포함)
  wire signed [31:0] sum_with_bias; // Bias까지 더한 값
  
  assign current_mult = i_val * w_val;
  assign next_mac_sum = mac_sum + current_mult; // 기존 합 + 현재 곱
  assign sum_with_bias = (next_mac_sum >>> 6) + bias_buf[co_cnt];

  // ReLU & Saturation(최종 결과값 계산)
  reg signed [7:0] final_pixel_val;

  always @(*) begin
      if (sum_with_bias < 0) 
          final_pixel_val = 8'd0; // ReLU
      else if (sum_with_bias > 32'd127) 
          final_pixel_val = 8'd127; // Saturation
      else 
          final_pixel_val = sum_with_bias[7:0];
  end

  // Sequential Logic
  reg [2:0] prev_command;
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state <= STATE_IDLE;
      
      // 출력 신호 초기화
      m_axis_tvalid <= 1'b0;
      m_axis_tlast  <= 1'b0;
      m_axis_tdata_reg <= 32'd0;
      
      // 완료 플래그 초기화
      f_writedone <= 1'b0;
      b_writedone <= 1'b0;
      cal_done    <= 1'b0;
      transmit_done <= 1'b0;
      conv_done <= 1'b0;
      
      // 포인터 및 카운터 초기화
      write_ptr <= 0;
      read_ptr <= 0;
      
      co_cnt <= 0; r_cnt <= 0; c_cnt <= 0;
      ci_cnt <= 0; ky_cnt <= 0; kx_cnt <= 0;
      mac_sum <= 0;

      prev_command <= 3'd0;
    end
    else begin
      prev_command <= command;
      case (state)
        STATE_IDLE: begin
          write_ptr <= 0;        // 저장 포인터 초기화
          m_axis_tvalid <= 1'b0; // 출력 신호 끄기
          
          if (command == 3'd1 && prev_command != 3'd1) begin
            state <= STATE_LOAD_FEAT;
            f_writedone <= 1'b0; // 완료 신호 내림 (새 작업 시작)
          end
          else if (command == 3'd2 && prev_command != 3'd2) begin
            state <= STATE_LOAD_BIAS;
            b_writedone <= 1'b0;
          end
          else if (command == 3'd3 && prev_command != 3'd3) begin
            state <= STATE_LOAD_WGT;
            cal_done <= 1'b0;
          end
          else if (command == 3'd4 && prev_command != 3'd4) begin
            state <= STATE_SEND;
            transmit_done <= 1'b0;
            read_ptr <= 0;
            sent_word_cnt <= 0;
            total_output_words <= (feature_length * feature_length * output_ch) >> 2;
          end
        end

        STATE_LOAD_FEAT: begin // 입력 이미지 저장
          // 데이터가 들어오면 (s_data_fire)
          if (s_data_fire) begin
            input_buf[write_ptr]     <= S_AXIS_TDATA[7:0];
            input_buf[write_ptr + 1] <= S_AXIS_TDATA[15:8];
            input_buf[write_ptr + 2] <= S_AXIS_TDATA[23:16];
            input_buf[write_ptr + 3] <= S_AXIS_TDATA[31:24];
            write_ptr <= write_ptr + 4; // 포인터 4칸 전진

            if (S_AXIS_TLAST) begin
              f_writedone <= 1'b1; // 완료 신호 발생
              state <= STATE_IDLE; // IDLE로 복귀
            end
          end
        end
        
        STATE_LOAD_BIAS: begin
          if (s_data_fire) begin
            bias_buf[write_ptr]     <= S_AXIS_TDATA[7:0];
            bias_buf[write_ptr + 1] <= S_AXIS_TDATA[15:8];
            bias_buf[write_ptr + 2] <= S_AXIS_TDATA[23:16];
            bias_buf[write_ptr + 3] <= S_AXIS_TDATA[31:24];
            write_ptr <= write_ptr + 4;

            if (S_AXIS_TLAST) begin
              b_writedone <= 1'b1;
              state <= STATE_IDLE;
            end
          end
        end

        STATE_LOAD_WGT: begin
          if (s_data_fire) begin
            weight_buf[write_ptr]     <= S_AXIS_TDATA[7:0];
            weight_buf[write_ptr + 1] <= S_AXIS_TDATA[15:8];
            weight_buf[write_ptr + 2] <= S_AXIS_TDATA[23:16];
            weight_buf[write_ptr + 3] <= S_AXIS_TDATA[31:24];
            write_ptr <= write_ptr + 4;

            if (S_AXIS_TLAST) begin
              // Weight 로드가 끝나면, TB의 명령 없이 바로 연산 상태로 넘어감
              state <= STATE_CALC; 
              
              // 연산을 위해 모든 카운터 초기화
              co_cnt <= 0; r_cnt <= 0; c_cnt <= 0;
              ci_cnt <= 0; ky_cnt <= 0; kx_cnt <= 0;
              mac_sum <= 0;
            end
          end
        end


        // 4. CALCULATION Loop Order: OutCh -> Row -> Col -> (InCh -> Ky -> Kx)
        STATE_CALC: begin
          // MAC 누적 
          mac_sum <= next_mac_sum;

          // 카운터 업데이트
          if (kx_cnt == 2) begin
            kx_cnt <= 0;
            if (ky_cnt == 2) begin
              ky_cnt <= 0;
              if (ci_cnt == input_ch - 1) begin
                // 1개 픽셀 연산 완료 시점
                ci_cnt <= 0;
                
                // 결과 저장
                output_buf[(co_cnt * feature_length * feature_length) + (r_cnt * feature_length) + c_cnt] <= final_pixel_val;
                
                // 누적기 초기화
                mac_sum <= 0;

                if (c_cnt == feature_length - 1) begin
                  c_cnt <= 0;
                  if (r_cnt == feature_length - 1) begin
                    r_cnt <= 0;
                    if (co_cnt == output_ch - 1) begin
                      // 모든 연산 완료
                      state <= STATE_IDLE;
                      cal_done <= 1'b1; 
                      conv_done <= 1'b1; 
                    end else begin
                      co_cnt <= co_cnt + 1; // 다음 출력 채널(필터)로
                    end
                  end else begin
                    r_cnt <= r_cnt + 1; // 다음 줄로
                  end
                end else begin
                  c_cnt <= c_cnt + 1; // 다음 칸으로
                end
                
              end else begin
                ci_cnt <= ci_cnt + 1; // 다음 입력 채널로
              end
            end else begin
              ky_cnt <= ky_cnt + 1; // 다음 커널 행으로
            end
          end else begin
            kx_cnt <= kx_cnt + 1; // 다음 커널 열로
          end
        end

        // 결과 데이터 전송
        STATE_SEND: begin
          // 보낼 데이터 준비
          if (!m_axis_tvalid) begin
            // 결과 버퍼에서 4개(32비트)씩 읽어서 패킹
            m_axis_tdata_reg <= {output_buf[read_ptr+3], output_buf[read_ptr+2], output_buf[read_ptr+1], output_buf[read_ptr]};
            m_axis_tvalid <= 1'b1;
            
            // 마지막 데이터인지 확인
            if (sent_word_cnt == total_output_words - 1) begin
              m_axis_tlast <= 1'b1;
            end
          end
          
          // Handshake 성공 (VDMA가 데이터를 가져감)
          if (m_data_fire) begin
            m_axis_tvalid <= 1'b0; // 신호 내림
            m_axis_tlast <= 1'b0;
            read_ptr <= read_ptr + 4; // 다음 데이터 주소로
            sent_word_cnt <= sent_word_cnt + 1; // 보낸 개수 증가
            
            // 전부 다 보냈으면 종료
            if (sent_word_cnt == total_output_words - 1) begin
              state <= STATE_IDLE;
              transmit_done <= 1'b1; // TB에 전송 끝 보고
            end
          end
        end
        
        default: state <= STATE_IDLE;
      endcase
      
      // 핸드셰이크 응답이 오면 완료 신호 초기화
      if (f_writedone_ack) f_writedone <= 1'b0;
      if (b_writedone_ack) b_writedone <= 1'b0;
      if (cal_done_ack)    cal_done    <= 1'b0;
      if (transmit_done_ack) transmit_done <= 1'b0;
    end
  end

endmodule