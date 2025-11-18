/*
* pool_module.v
*/

module pool_module 
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

    input pool_start, 
    output reg pool_done,

    //////////////////////////////////////////////////////////////////////////
    // TODO : Add ports if you need them
    //////////////////////////////////////////////////////////////////////////
    input wire [5:0] input_size,
    input wire [8:0] input_channel_size
  );
  
  reg m_axis_tuser;
  reg [C_S00_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata;
  reg [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] m_axis_tkeep;
  reg m_axis_tlast;
  reg m_axis_tvalid;
  wire s_axis_tready;
  
  assign S_AXIS_TREADY = s_axis_tready;
  assign M_AXIS_TDATA = m_axis_tdata;
  assign M_AXIS_TLAST = m_axis_tlast;
  assign M_AXIS_TVALID = m_axis_tvalid;
  assign M_AXIS_TUSER = 1'b0;
  assign M_AXIS_TKEEP = {(C_S00_AXIS_TDATA_WIDTH/8) {1'b1}};
  
  //////////////////////////////////////////////////////////////////////////
  // TODO : Write your code here
  //////////////////////////////////////////////////////////////////////////

  // FSM States
  localparam STATE_IDLE   = 2'b00; // 시작 대기
  localparam STATE_RUN    = 2'b01; // 데이터 받고, 연산하고, 전송
  localparam STATE_DONE   = 2'b10; // 완료 신호

  reg [1:0] state, next_state;

  wire s_data_fire; // 입력 데이터가 실제로 전송되는 시점 (TVALID & TREADY)
  wire m_data_fire; // 출력 데이터가 실제로 전송되는 시점 (TVALID & TREADY)

  reg [8:0] ch_cnt; // channel counter
  reg [5:0] y_cnt;  // line counter
  reg [3:0] x_cnt;  // line의 word(S_AXIS_TDATA로 받는 단위=32bit) number counter(data number counter/4)

  // input_size를 4로 나눠 한 line의 워드 수 계산
  wire [3:0] words_per_line; 
  assign words_per_line = input_size >> 2;

  // BRAM 기반 라인 버퍼 (최대 16 워드 = 64 픽셀)
  reg [31:0] line_buffer [0:15];
  // 입력 픽셀
  wire [7:0] in_pix0 = S_AXIS_TDATA[7:0];
  wire [7:0] in_pix1 = S_AXIS_TDATA[15:8];
  wire [7:0] in_pix2 = S_AXIS_TDATA[23:16];
  wire [7:0] in_pix3 = S_AXIS_TDATA[31:24];

  // 라인 버퍼 픽셀
  wire [31:0] line_buffer_word = line_buffer[x_cnt];
  wire [7:0] buf_pix0 = line_buffer_word[7:0];
  wire [7:0] buf_pix1 = line_buffer_word[15:8];
  wire [7:0] buf_pix2 = line_buffer_word[23:16];
  wire [7:0] buf_pix3 = line_buffer_word[31:24];

  // 2x2 Max Pool 연산 결과
  wire [7:0] out_pix0; // max(buf_pix0, buf_pix1, in_pix0, in_pix1)
  wire [7:0] out_pix1; // max(buf_pix2, buf_pix3, in_pix2, in_pix3)
  
  // 출력 데이터 4개를 모으기 위한 버퍼
  reg [15:0] output_buffer; // 먼저 계산된 2개의 데이터(16비트)을 저장
  reg output_buffer_valid;  // 버퍼에 데이터가 있으면 1, 비었으면 0

  wire compute_fire;     // 연산이 발생하는 시점
  wire is_last_compute;  // 마지막 연산인지 확인

  always @(*) begin
    next_state = state;

    case(state)
      STATE_IDLE:
        if (pool_start) begin
          next_state = STATE_RUN;
        end

      STATE_RUN:
        // m_data_fire가 1이고 m_axis_tlast가 1이었다면 (마지막 데이터 전송 완료)
        if (m_data_fire && m_axis_tlast) begin 
          next_state = STATE_DONE;
        end

      STATE_DONE:
        next_state = STATE_IDLE;
    
    endcase
  end

  // S_AXIS_TREADY: 실행 상태이고, 출력할 데이터가 VDMA로 전송 대기 중이 아닐 때만 데이터 받을 준비 됨
  assign s_axis_tready = (state == STATE_RUN) && (m_axis_tvalid == 1'b0);
  
  // 데이터 전송 감지
  assign s_data_fire = S_AXIS_TVALID && s_axis_tready; // Data 받음
  assign m_data_fire = M_AXIS_TREADY && m_axis_tvalid; // Data 전송
  
  // 연산 시점 감지: Data 받는중이고, 홀수 번째 줄일 때
  assign compute_fire = s_data_fire && y_cnt[0]; // y_cnt[0]가 1이면 홀수 줄

  // 첫 번째 2x2 풀링(word의 4개 데이터 중 1, 2번째 위치 데이터에 대한 pooling), 결과는 out_pix0
  wire [7:0] max_AB = ($signed(buf_pix0) > $signed(buf_pix1)) ? buf_pix0 : buf_pix1;
  wire [7:0] max_CD = ($signed(in_pix0) > $signed(in_pix1)) ? in_pix0 : in_pix1;
  assign out_pix0 = ($signed(max_AB) > $signed(max_CD)) ? max_AB : max_CD;

  // 두 번째 2x2 풀링(word의 4개 데이터 중 3, 4번째 위치 데이터에 대한 pooling), 결과는 out_pix1
  wire [7:0] max_AB_2 = ($signed(buf_pix2) > $signed(buf_pix3)) ? buf_pix2 : buf_pix3;
  wire [7:0] max_CD_2 = ($signed(in_pix2) > $signed(in_pix3)) ? in_pix2 : in_pix3;
  assign out_pix1 = ($signed(max_AB_2) > $signed(max_CD_2)) ? max_AB_2 : max_CD_2;
  
  // 마지막 연산인지 확인(마지막 채널의 마지막 줄의 마지막 워드일 때)
  assign is_last_compute = compute_fire && (x_cnt == (words_per_line - 1)) && (y_cnt == (input_size - 1)) && (ch_cnt == (input_channel_size - 1));

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state     <= STATE_IDLE;
      pool_done <= 1'b0;

      ch_cnt <= 0;
      y_cnt  <= 0;
      x_cnt  <= 0;
          
      m_axis_tvalid <= 1'b0;
      m_axis_tlast  <= 1'b0;
      m_axis_tdata  <= 32'd0;
        
      output_buffer <= 16'd0;
      output_buffer_valid <= 1'b0;          
    end
    else begin
      state <= next_state;
         
      if (state == STATE_DONE) begin
        pool_done <= 1'b1;
      end else begin
        pool_done <= 1'b0;
      end

      // 데이터를 전송했을 때
      if (m_data_fire) begin
        m_axis_tvalid <= 1'b0;
        m_axis_tlast  <= 1'b0;
      end

      // 데이터를 받았을 때
      if (s_data_fire) begin
              
        // 라인 버퍼 저장 (짝수 줄일 때만)
        if (y_cnt[0] == 1'b0) begin // 짝수 줄
          line_buffer[x_cnt] <= S_AXIS_TDATA;
        end

        // 연산 및 출력 준비 ---
        if (compute_fire) begin // 홀수 줄 데이터가 들어왔을 때(연산 해야할 때)
                  
          if (output_buffer_valid == 1'b0) begin
            // 버퍼가 비어있음 -> 현재 계산된 16비트를 저장해둠
            output_buffer <= {out_pix1, out_pix0};
            output_buffer_valid <= 1'b1;
          end
          else begin
            // 버퍼에 데이터가 있음 -> 저장된 것 + 현재 계산된 것 합쳐서 32비트 출력
            m_axis_tdata  <= {out_pix1, out_pix0, output_buffer}; 
            m_axis_tvalid <= 1'b1;
            output_buffer_valid <= 1'b0;

            // 마지막 연산이었다면 TLAST 신호 설정
            if (is_last_compute) begin
              m_axis_tlast <= 1'b1;
            end
          end
        end

        // 카운터 업데이트
        if (x_cnt == (words_per_line - 1)) begin
          x_cnt <= 0;
          if (y_cnt == (input_size - 1)) begin
            y_cnt <= 0;
            if (ch_cnt == (input_channel_size - 1)) begin
              ch_cnt <= 0; // FSM이 IDLE로 돌아가며 리셋
            end else begin
              ch_cnt <= ch_cnt + 1;
            end
          end else begin
            y_cnt <= y_cnt + 1;
          end
        end else begin
          x_cnt <= x_cnt + 1;
        end
              
      end
          
      // FSM이 IDLE로 돌아갈 때 카운터 확실히 리셋
      if (next_state == STATE_IDLE) begin
        ch_cnt <= 0;
        y_cnt  <= 0;
        x_cnt  <= 0;
      end
    end
  end
endmodule