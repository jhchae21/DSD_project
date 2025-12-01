module conv_module 
  #(
    parameter integer C_S00_AXIS_TDATA_WIDTH = 32
  )
  (
    input wire clk,
    input wire rstn,

    // AXI-Stream Slave (Input)
    output wire S_AXIS_TREADY,
    input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
    input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TKEEP, 
    input wire S_AXIS_TUSER, 
    input wire S_AXIS_TLAST, 
    input wire S_AXIS_TVALID, 

    // AXI-Stream Master (Output)
    input wire M_AXIS_TREADY, 
    output wire M_AXIS_TUSER, 
    output wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA, 
    output wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TKEEP, 
    output wire M_AXIS_TLAST, 
    output wire M_AXIS_TVALID, 

    // APB Signals
    input wire conv_start, 
    output reg conv_done,

    // Simulation Control Ports
    input wire [2:0] command,      
    input wire [8:0] input_ch,     
    input wire [8:0] output_ch,    
    input wire [5:0] feature_length,

    output reg f_writedone,        
    output reg b_writedone,        
    output reg cal_done,           
    output reg transmit_done,      

    input wire f_writedone_ack,    
    input wire b_writedone_ack,
    input wire cal_done_ack,
    input wire transmit_done_ack
  );

  wire [C_S00_AXIS_TDATA_WIDTH-1 : 0]            m_axis_tdata;
  reg                                           m_axis_tlast;
  reg                                           m_axis_tvalid;
  wire                                          s_axis_tready;
  
  assign S_AXIS_TREADY = s_axis_tready;
  assign M_AXIS_TDATA = m_axis_tdata;
  assign M_AXIS_TLAST = m_axis_tlast;
  assign M_AXIS_TVALID = m_axis_tvalid;
  assign M_AXIS_TUSER = 1'b0;
  assign M_AXIS_TKEEP = {(C_S00_AXIS_TDATA_WIDTH/8) {1'b1}};
  
  // 1. 내부 레지스터 및 연결
  reg [31:0] m_axis_tdata_reg;
  assign m_axis_tdata = m_axis_tdata_reg;

  // FSM States
  localparam STATE_IDLE            = 3'd0;
  localparam STATE_LOAD_FEAT       = 3'd1;
  localparam STATE_LOAD_BIAS       = 3'd2;
  localparam STATE_STREAM_AND_CALC = 3'd3;
  localparam STATE_SEND            = 3'd4;

  reg [2:0] state;

  // 2. Buffers
  // Input Buf: Distributed RAM (병렬 읽기 지원을 위해 필수)
  (* ram_style = "distributed" *) reg signed [7:0] input_buf [0:8191];
  
  // Bias Buf: Distributed RAM (빠른 접근)
  (* ram_style = "distributed" *) reg signed [7:0] bias_buf [0:255];  
  
  // Output Buf: Block RAM (32비트 확장, Port A/B 동시 사용)
  (* ram_style = "block" *) reg signed [31:0] output_buf [0:32767]; 

  // Accumulator Register (Image Size: 32x32) (계산 중에는 BRAM 대신 이 레지스터에 값을 누적)
  reg signed [31:0] acc_mem [0:1023];

  // 3. Weight Streaming (Double Buffering용 FIFO)
  // 9 bytes (커널 1개) 단위로 처리
  reg signed [7:0] wgt_fifo [0:63]; 
  reg [6:0] wgt_count;              
  
  // Active Kernel: 9개 (현재 계산에 사용할 3x3 커널)
  reg signed [7:0] active_kernel [0:8]; 
  reg compute_busy; // 연산 중인지 표시하는 플래그

  // 4. Counters
  reg [31:0] write_ptr; 
  reg [31:0] read_ptr;
  
  reg [8:0] co_cnt; // Output Channel
  reg [8:0] ci_cnt; // Input Channel
  reg [5:0] r_cnt;  // Row
  reg [5:0] c_cnt;  // Col (2씩 증가!)
  
  // 커널 내부는 Combinational Logic으로 처리하므로 ky, kx 카운터 제거

  reg [31:0] total_output_words; 
  reg [31:0] sent_word_cnt;    
  reg [7:0] o0, o1, o2, o3;  
  reg send_phase; // 0: 하위 2개 읽기, 1: 상위 2개 읽기

  reg [2:0] prev_command;
  
  // Data Fire Signals
  wire s_data_fire = S_AXIS_TVALID && s_axis_tready;
  wire m_data_fire = m_axis_tvalid && M_AXIS_TREADY;

  wire do_receive = s_data_fire;
  wire do_load = (!compute_busy && wgt_count >= 9); // 커널 1개(9바이트)만 있으면 됨
  
  // ===================================================================
  // Combinational Logic: 2-Way Parallel MAC (Pixel A & Pixel B)
  // ===================================================================

  // s_axis_tready 제어
  assign s_axis_tready = (state == STATE_LOAD_FEAT) || 
                         (state == STATE_LOAD_BIAS) || 
                         ((state == STATE_STREAM_AND_CALC) && (wgt_count < 40)); 

  // -----------------------------------------------------------
  // [Wire Logic] Zero Padding & Indexing
  // -----------------------------------------------------------
  
  // Pixel A (현재 c_cnt)와 Pixel B (c_cnt + 1)의 좌표 계산
  // 9개의 커널 위치(k)에 대해 각각 계산해야 함
  
  integer k;
  reg signed [7:0]  w_val [0:8];    // 커널 가중치
  reg signed [7:0]  i_val_A [0:8];  // Pixel A의 9개 입력값
  reg signed [7:0]  i_val_B [0:8];  // Pixel B의 9개 입력값
  reg signed [31:0] psum_result_A;  // Pixel A의 MAC 결과
  reg signed [31:0] psum_result_B;  // Pixel B의 MAC 결과
  
  always @(*) begin
      psum_result_A = 0;
      psum_result_B = 0;
      
      for (k = 0; k < 9; k = k + 1) begin
          // (1) Weight 가져오기
          w_val[k] = active_kernel[k];
          
          // (2) Input 좌표 계산 (Zero Padding)
          // k/3 = dy, k%3 = dx
          // Row는 A, B 동일: r_cnt + (k/3) - 1
          // Col A: c_cnt + (k%3) - 1
          // Col B: (c_cnt + 1) + (k%3) - 1
          
          // --- Pixel A Input ---
          if ( ($signed({1'b0, r_cnt}) + (k/3) - 1 < 0) || 
               ($signed({1'b0, r_cnt}) + (k/3) - 1 >= feature_length) ||
               ($signed({1'b0, c_cnt}) + (k%3) - 1 < 0) || 
               ($signed({1'b0, c_cnt}) + (k%3) - 1 >= feature_length) ) begin
              i_val_A[k] = 8'd0; 
          end else begin
              i_val_A[k] = input_buf[ (ci_cnt * feature_length * feature_length) + 
                                    (($signed({1'b0, r_cnt}) + (k/3) - 1) * feature_length) + 
                                    ($signed({1'b0, c_cnt}) + (k%3) - 1) ];
          end

          // --- Pixel B Input (옆 칸) ---
          if ( ($signed({1'b0, r_cnt}) + (k/3) - 1 < 0) || 
               ($signed({1'b0, r_cnt}) + (k/3) - 1 >= feature_length) ||
               ($signed({1'b0, c_cnt}) + 1 + (k%3) - 1 < 0) ||           // c_cnt + 1
               ($signed({1'b0, c_cnt}) + 1 + (k%3) - 1 >= feature_length) ) begin
              i_val_B[k] = 8'd0; 
          end else begin
              i_val_B[k] = input_buf[ (ci_cnt * feature_length * feature_length) + 
                                    (($signed({1'b0, r_cnt}) + (k/3) - 1) * feature_length) + 
                                    ($signed({1'b0, c_cnt}) + 1 + (k%3) - 1) ];
          end
          
          // (3) 2-Way MAC (18개 곱셈)
          psum_result_A = psum_result_A + (i_val_A[k] * w_val[k]);
          psum_result_B = psum_result_B + (i_val_B[k] * w_val[k]);
      end
  end

  // -----------------------------------------------------------
  // Bias Add & Saturation Logic (마지막 단계용)
  // -----------------------------------------------------------
  // 저장할 acc_mem 주소 계산 (Port A: c_cnt, Port B: c_cnt+1)
  wire [31:0] addr_A = (r_cnt * feature_length) + c_cnt;
  wire [31:0] addr_B = (r_cnt * feature_length) + c_cnt + 1;

  // BRAM 출력 버퍼 저장용 주소 (전체 채널 오프셋 포함)
  wire [31:0] bram_addr_A = (co_cnt * feature_length * feature_length) + addr_A;
  wire [31:0] bram_addr_B = (co_cnt * feature_length * feature_length) + addr_B;

  // 기존 값 읽기 (누적용) - acc_mem 레지스터에서 읽음
  wire signed [31:0] psum_mem_A = acc_mem[addr_A];
  wire signed [31:0] psum_mem_B = acc_mem[addr_B];

  // 최종 값 계산용 변수 (Combinational)
  reg signed [31:0] temp_A, temp_B;
  reg signed [7:0]  final_byte_A, final_byte_B;

  always @(*) begin
      // [Pixel A 계산]
      temp_A = (ci_cnt == 0) ? psum_result_A : (psum_mem_A + psum_result_A);
      
      if (ci_cnt == input_ch - 1) begin // 마지막 채널이면 Bias + ReLU + Saturation
          temp_A = (temp_A >>> 6) + bias_buf[co_cnt];
          if (temp_A < 0) temp_A = 0; 
          else if (temp_A > 127) temp_A = 127;
      end
      final_byte_A = temp_A[7:0];

      // [Pixel B 계산]
      temp_B = (ci_cnt == 0) ? psum_result_B : (psum_mem_B + psum_result_B);
      
      if (ci_cnt == input_ch - 1) begin
          temp_B = (temp_B >>> 6) + bias_buf[co_cnt]; // 같은 Output Channel이므로 같은 Bias
          if (temp_B < 0) temp_B = 0; 
          else if (temp_B > 127) temp_B = 127;
      end
      final_byte_B = temp_B[7:0];
  end


  // ===================================================================
  // 5. Sequential Logic
  // ===================================================================
  integer i_loop;
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state <= STATE_IDLE;
      m_axis_tvalid <= 0; m_axis_tlast <= 0; m_axis_tdata_reg <= 0;
      f_writedone <= 0; b_writedone <= 0; cal_done <= 0; transmit_done <= 0; conv_done <= 0;
      write_ptr <= 0; read_ptr <= 0;
      wgt_count <= 0; compute_busy <= 0;
      co_cnt <= 0; ci_cnt <= 0; r_cnt <= 0; c_cnt <= 0;
      send_phase <= 0; 
      o0 <= 0; o1 <= 0; o2 <= 0; o3 <= 0;
      prev_command <= 0;
    end
    else begin
      prev_command <= command;

      case (state)
        // -------------------------------------------------------
        // 0. IDLE
        // -------------------------------------------------------
        STATE_IDLE: begin
          write_ptr <= 0; m_axis_tvalid <= 0; wgt_count <= 0; compute_busy <= 0;
          
          if (command == 3'd1 && prev_command != 3'd1) begin
            state <= STATE_LOAD_FEAT; f_writedone <= 0;
          end
          else if (command == 3'd2 && prev_command != 3'd2) begin
            state <= STATE_LOAD_BIAS; b_writedone <= 0;
          end
          else if (command == 3'd3 && prev_command != 3'd3) begin
            state <= STATE_STREAM_AND_CALC; // 통합 상태 진입
            cal_done <= 0;
            co_cnt <= 0; ci_cnt <= 0; r_cnt <= 0; c_cnt <= 0;
            compute_busy <= 0; 
          end
          else if (command == 3'd4 && prev_command != 3'd4) begin
            state <= STATE_SEND; transmit_done <= 0;
            read_ptr <= 0; sent_word_cnt <= 0;
            total_output_words <= (feature_length * feature_length * output_ch) >> 2;
          end
        end

        // -------------------------------------------------------
        // 1 & 2. LOAD FEAT / BIAS (기존과 동일)
        // -------------------------------------------------------
        STATE_LOAD_FEAT: begin
          if (s_data_fire) begin
            input_buf[write_ptr] <= S_AXIS_TDATA[7:0];
            input_buf[write_ptr+1] <= S_AXIS_TDATA[15:8];
            input_buf[write_ptr+2] <= S_AXIS_TDATA[23:16];
            input_buf[write_ptr+3] <= S_AXIS_TDATA[31:24];
            write_ptr <= write_ptr + 4;
            if (S_AXIS_TLAST) begin f_writedone <= 1; state <= STATE_IDLE; end
          end
        end
        STATE_LOAD_BIAS: begin
          if (s_data_fire) begin
            bias_buf[write_ptr] <= S_AXIS_TDATA[7:0];
            bias_buf[write_ptr+1] <= S_AXIS_TDATA[15:8];
            bias_buf[write_ptr+2] <= S_AXIS_TDATA[23:16];
            bias_buf[write_ptr+3] <= S_AXIS_TDATA[31:24];
            write_ptr <= write_ptr + 4;
            if (S_AXIS_TLAST) begin b_writedone <= 1; state <= STATE_IDLE; end
          end
        end

        // -------------------------------------------------------
        // 3. STREAM & 2-WAY PIXEL PARALLEL CALC
        // -------------------------------------------------------
        STATE_STREAM_AND_CALC: begin

          // [Case 1] 수신 & 로드 동시 발생
          if (do_receive && do_load) begin
             for(i_loop=0; i_loop<9; i_loop=i_loop+1) active_kernel[i_loop] <= wgt_fifo[i_loop];
             
             for(i_loop=0; i_loop<55; i_loop=i_loop+1) wgt_fifo[i_loop] <= wgt_fifo[i_loop+9]; 
             
             // 새 데이터 쓰기 (당겨진 위치)
             wgt_fifo[wgt_count - 9]     <= S_AXIS_TDATA[7:0];
             wgt_fifo[wgt_count - 9 + 1] <= S_AXIS_TDATA[15:8];
             wgt_fifo[wgt_count - 9 + 2] <= S_AXIS_TDATA[23:16];
             wgt_fifo[wgt_count - 9 + 3] <= S_AXIS_TDATA[31:24];
             
             wgt_count <= wgt_count - 5; // +4 -9 = -5
             
             compute_busy <= 1'b1; // 계산 시작
             r_cnt <= 0; c_cnt <= 0;
          end
          // [Case 2] 로드만
          else if (do_load) begin
             for(i_loop=0; i_loop<9; i_loop=i_loop+1) active_kernel[i_loop] <= wgt_fifo[i_loop];
             for(i_loop=0; i_loop<55; i_loop=i_loop+1) wgt_fifo[i_loop] <= wgt_fifo[i_loop+9]; 
             wgt_count <= wgt_count - 9;
             
             compute_busy <= 1'b1;
             r_cnt <= 0; c_cnt <= 0;
          end
          // [Case 3] 수신만
          else if (do_receive) begin
             wgt_fifo[wgt_count]   <= S_AXIS_TDATA[7:0];
             wgt_fifo[wgt_count+1] <= S_AXIS_TDATA[15:8];
             wgt_fifo[wgt_count+2] <= S_AXIS_TDATA[23:16];
             wgt_fifo[wgt_count+3] <= S_AXIS_TDATA[31:24];
             wgt_count <= wgt_count + 4;
          end
          
          // [Computer] 2-Pixel Parallel Computation
          if (compute_busy) begin
             
             // --- 메모리 쓰기 (Port A, Port B 동시 사용) ---
             // temp_A/B 값은 Combinational Logic에서 계산됨 (덮어쓰기 or 누적)
             // 레지스터 배열은 Multi-port Write 가능하므로 문제 없음
             
             // 1. Accumulate to Register (acc_mem)
             if (ci_cnt != input_ch - 1) begin
                acc_mem[addr_A] <= temp_A;
                acc_mem[addr_B] <= temp_B;
             end
             else begin
                // 2. Last Channel: Write to BRAM (output_buf)
                // 이때는 acc_mem을 업데이트할 필요 없음 (다음 필터 때 초기화되므로)
                // final_byte_A/B는 Bias/ReLU 적용된 최종값
                // BRAM Port A, B 동시에 사용하여 2개 값 씀 (물리적으로 가능)
                output_buf[bram_addr_A] <= final_byte_A;
                output_buf[bram_addr_B] <= final_byte_B;
             end

             // --- 픽셀 이동 (2칸씩 점프!) ---
             if (c_cnt >= feature_length - 2) begin // 한 줄 끝 도달 (c_cnt가 마지막 또는 그 앞)
                 c_cnt <= 0;
                 if (r_cnt == feature_length - 1) begin
                     r_cnt <= 0;
                     
                     // --- 한 커널에 대한 전체 이미지 완료 ---
                     compute_busy <= 1'b0; // 멈추고 다음 가중치 대기
                     
                     if (ci_cnt == input_ch - 1) begin
                         ci_cnt <= 0;
                         co_cnt <= co_cnt + 1; // 출력 채널 1개 완료
                         
                         if (co_cnt + 1 >= output_ch) begin
                             state <= STATE_IDLE;
                             cal_done <= 1'b1;
                             conv_done <= 1'b1;
                         end
                     end else begin
                         ci_cnt <= ci_cnt + 1;
                     end
                 end else r_cnt <= r_cnt + 1;
             end else c_cnt <= c_cnt + 2; // [중요] 2칸씩 이동
          end 
        end

        // -------------------------------------------------------
        // 4. SEND RESULT (기존 동일)
        // -------------------------------------------------------
        STATE_SEND: begin
          if (!m_axis_tvalid) begin
            if (send_phase == 1'b0) begin
                 // Phase 0: 하위 2개 바이트 읽기 (read_ptr, read_ptr+1)
                 // Non-blocking으로 레지스터에 저장
                 o0 <= output_buf[read_ptr];
                 o1 <= output_buf[read_ptr+1];
                 send_phase <= 1'b1; // 다음 페이즈로
             end
             else begin
                 // Phase 1: 상위 2개 바이트 읽기 (read_ptr+2, read_ptr+3)
                 // o2, o3에 저장함과 동시에 패킹해서 내보낼 준비
                 o2 <= output_buf[read_ptr+2];
                 o3 <= output_buf[read_ptr+3];
                 
                 // o0, o1은 이미 저장되어 있음
                 m_axis_tdata_reg <= {output_buf[read_ptr+3][7:0], output_buf[read_ptr+2][7:0], o1, o0};
                 
                 m_axis_tvalid <= 1'b1;
                 if (sent_word_cnt == total_output_words - 1) m_axis_tlast <= 1'b1;
                 
                 send_phase <= 1'b0; // 초기화
             end
          end
          if (m_data_fire) begin
            m_axis_tvalid <= 1'b0; m_axis_tlast <= 1'b0;
            read_ptr <= read_ptr + 4; sent_word_cnt <= sent_word_cnt + 1;
            if (sent_word_cnt == total_output_words - 1) begin
              state <= STATE_IDLE; transmit_done <= 1'b1;
            end
          end
        end
        
        default: state <= STATE_IDLE;
      endcase
      
      if (f_writedone_ack) f_writedone <= 0;
      if (b_writedone_ack) b_writedone <= 0;
      if (cal_done_ack) cal_done <= 0;
      if (transmit_done_ack) transmit_done <= 0;
    end
  end

endmodule

/*
* conv_module.v
* Ultimate Optimized: 16-Way Full Parallelism (1 Clock = 144 MACs)
* - Structure: Stream & Calc combined (Single State)
* - Logic: 16 Pixels x 9 Weights Parallel Calculation
* - Memory: Distributed RAM (Input) + Register Array (Accumulator) + BRAM (Final Storage)
*/
/*
module conv_module 
  #(
    parameter integer C_S00_AXIS_TDATA_WIDTH = 32
  )
  (
    input wire clk,
    input wire rstn,

    // AXI-Stream Slave (Input)
    output wire S_AXIS_TREADY,
    input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
    input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TKEEP, 
    input wire S_AXIS_TUSER, 
    input wire S_AXIS_TLAST, 
    input wire S_AXIS_TVALID, 

    // AXI-Stream Master (Output)
    input wire M_AXIS_TREADY, 
    output wire M_AXIS_TUSER, 
    output wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA, 
    output wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TKEEP, 
    output wire M_AXIS_TLAST, 
    output wire M_AXIS_TVALID, 

    // APB Signals
    input wire conv_start, 
    output reg conv_done,

    // Simulation Control Ports
    input wire [2:0] command,      
    input wire [8:0] input_ch,     
    input wire [8:0] output_ch,    
    input wire [5:0] feature_length,

    output reg f_writedone,        
    output reg b_writedone,        
    output reg cal_done,           
    output reg transmit_done,      

    input wire f_writedone_ack,    
    input wire b_writedone_ack,
    input wire cal_done_ack,
    input wire transmit_done_ack
  );

  // --- 기존 선언부 유지 ---
  wire [C_S00_AXIS_TDATA_WIDTH-1 : 0]            m_axis_tdata;
  reg                                           m_axis_tlast;
  reg                                           m_axis_tvalid;
  wire                                          s_axis_tready;
  
  assign S_AXIS_TREADY = s_axis_tready;
  assign M_AXIS_TDATA = m_axis_tdata;
  assign M_AXIS_TLAST = m_axis_tlast;
  assign M_AXIS_TVALID = m_axis_tvalid;
  assign M_AXIS_TUSER = 1'b0;
  assign M_AXIS_TKEEP = {(C_S00_AXIS_TDATA_WIDTH/8) {1'b1}};
  
  // ===================================================================
  // Implementation: 16-Way Full Parallelism (144 MACs)
  // ===================================================================

  // 1. 내부 레지스터 연결
  reg [31:0] m_axis_tdata_reg;
  assign m_axis_tdata = m_axis_tdata_reg;

  // FSM States
  localparam STATE_IDLE            = 3'd0;
  localparam STATE_LOAD_FEAT       = 3'd1;
  localparam STATE_LOAD_BIAS       = 3'd2;
  localparam STATE_STREAM_AND_CALC = 3'd3; // 스트리밍 + 16배속 완전 병렬 연산
  localparam STATE_WRITE_BACK      = 3'd4; // [NEW] 레지스터 -> BRAM 복사
  localparam STATE_SEND            = 3'd5;

  reg [2:0] state;

  // 2. Buffers
  // Input Buf: Distributed RAM (144 port read 지원)
  (* ram_style = "distributed" *) reg signed [7:0] input_buf [0:8191];
  
  // Bias Buf: Distributed RAM
  (* ram_style = "distributed" *) reg signed [7:0] bias_buf [0:255];  
  
  // [작업대] Accumulator Registers (32x32 Image Buffer)
  // BRAM 대신 레지스터를 사용하여 16픽셀 동시 쓰기 지원
  reg signed [31:0] acc_mem [0:1023];

  // [창고] Output Buffer (Block RAM)
  // 최종 결과 보관 및 전송용
  (* ram_style = "block" *) reg signed [31:0] output_buf [0:32767]; 

  // 3. Weight Streaming (Double Buffering FIFO)
  reg signed [7:0] wgt_fifo [0:63]; 
  reg [6:0] wgt_count;              
  
  // Active Kernel: 9개 (현재 계산할 3x3 커널)
  reg signed [7:0] active_kernel [0:8]; 
  reg compute_busy; 

  // 4. Counters
  reg [31:0] write_ptr; 
  reg [31:0] read_ptr;
  reg [31:0] wb_ptr; // Write-Back Pointer
  
  reg [8:0] co_cnt; // Output Channel
  reg [8:0] ci_cnt; // Input Channel
  reg [5:0] r_cnt;  // Row
  reg [5:0] c_cnt;  // Col (16씩 증가!)
  
  // kx, ky 제거됨 (병렬 처리)

  reg [31:0] total_output_words; 
  reg [31:0] sent_word_cnt;      

  reg [2:0] prev_command;
  
  // Data Fire Signals
  wire s_data_fire = S_AXIS_TVALID && s_axis_tready;
  wire m_data_fire = m_axis_tvalid && M_AXIS_TREADY;

  wire do_receive = s_data_fire;
  wire do_load = (!compute_busy && wgt_count >= 9); // 커널 1개(9바이트)만 있으면 됨

  // [수정 1] Combinational Logic을 위한 변수들을 모듈 최상단에 선언
  // Write Back용
  reg signed [31:0] wb_val_a, wb_val_b;
  reg signed [31:0] wb_raw_a, wb_raw_b;
  
  // Send용
  reg [7:0] snd_o0, snd_o1, snd_o2, snd_o3;
  reg [31:0] send_pack_data;


  // ===================================================================
  // Combinational Logic (Always @*)
  // ===================================================================

  assign s_axis_tready = (state == STATE_LOAD_FEAT) || 
                         (state == STATE_LOAD_BIAS) || 
                         ((state == STATE_STREAM_AND_CALC) && (wgt_count < 40)); 

  // -----------------------------------------------------------
  // [16-Way Full Parallel MAC Logic]
  // -----------------------------------------------------------
  integer p, k;
  
  reg signed [7:0]  w_val;          
  reg signed [7:0]  i_val;   
  reg signed [31:0] mult;   
  reg signed [31:0] pixel_sum; // 9개 MAC 합
  reg signed [31:0] next_acc [0:15]; 

  reg signed [15:0] curr_r, curr_c, pad_r, pad_c;
  reg [31:0] acc_idx;

  always @(*) begin
      // --- MAC Calculation (16 Pixels x 9 Weights) ---
      
      for (p = 0; p < 16; p = p + 1) begin
          
          pixel_sum = 0; // 이 픽셀에 대한 9개 MAC 합 초기화
          
          // [중요] Inner Loop: 9개 Weight에 대한 곱셈 및 합산 (Combinational)
          for (k = 0; k < 9; k = k + 1) begin
              // (1) Weight 가져오기
              w_val = active_kernel[k];
              
              // (2) Input 좌표 계산 (Padding 포함)
              // k=0:(y-1,x-1) ... k=8:(y+1,x+1)
              // ky = k/3 - 1, kx = k%3 - 1
              
              curr_r = $signed({1'b0, r_cnt});
              curr_c = $signed({1'b0, c_cnt}) + p;
              
              pad_r = curr_r + (k/3) - 1;
              pad_c = curr_c + (k%3) - 1;
              
              if ( (curr_c >= feature_length) || 
                   (pad_r < 0) || (pad_r >= feature_length) || 
                   (pad_c < 0) || (pad_c >= feature_length) ) begin
                  i_val = 8'd0; 
              end else begin
                  // Distributed RAM에서 데이터 읽기
                  i_val = input_buf[ (ci_cnt * feature_length * feature_length) + 
                                     (pad_r * feature_length) + pad_c ];
              end
              
              // (3) 곱셈 및 누적 (Combinational)
              mult = i_val * w_val;
              pixel_sum = pixel_sum + mult;
          end // k loop end
          
          // (4) 최종 누적값 계산 (기존 acc_mem 값 + 현재 9-MAC 결과)
          acc_idx = (curr_r * feature_length) + curr_c;
          
          if (ci_cnt == 0) begin
             next_acc[p] = pixel_sum; // 첫 채널이면 덮어쓰기
          end else begin
             next_acc[p] = acc_mem[acc_idx] + pixel_sum; // 아니면 누적
          end
          
      end // p loop end

      // --- (2) Write Back Logic (Bias/ReLU/Sat) ---
      // Sequential에서 wb_ptr를 쓰기 전에 미리 계산
      wb_raw_a = acc_mem[wb_ptr];
      wb_raw_b = acc_mem[wb_ptr+1];
      
      // Scaling & Bias Add
      wb_raw_a = (wb_raw_a >>> 6) + bias_buf[co_cnt];
      wb_raw_b = (wb_raw_b >>> 6) + bias_buf[co_cnt];
      
      // ReLU & Saturation (A)
      if (wb_raw_a < 0) wb_val_a = 0;
      else if (wb_raw_a > 127) wb_val_a = 127;
      else wb_val_a = wb_raw_a;
      
      // ReLU & Saturation (B)
      if (wb_raw_b < 0) wb_val_b = 0;
      else if (wb_raw_b > 127) wb_val_b = 127;
      else wb_val_b = wb_raw_b;


      // --- (3) Send Data Packing Logic ---
      snd_o0 = output_buf[read_ptr];
      snd_o1 = output_buf[read_ptr+1];
      snd_o2 = output_buf[read_ptr+2];
      snd_o3 = output_buf[read_ptr+3];
      
      send_pack_data = {snd_o3, snd_o2, snd_o1, snd_o0};
  end


  // ===================================================================
  // 5. Sequential Logic
  // ===================================================================
  integer i_seq, p_seq;
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state <= STATE_IDLE;
      m_axis_tvalid <= 0; m_axis_tlast <= 0; m_axis_tdata_reg <= 0;
      f_writedone <= 0; b_writedone <= 0; cal_done <= 0; transmit_done <= 0; conv_done <= 0;
      write_ptr <= 0; read_ptr <= 0; wb_ptr <= 0;
      wgt_count <= 0; compute_busy <= 0;
      co_cnt <= 0; ci_cnt <= 0; r_cnt <= 0; c_cnt <= 0; 
      
      // acc_mem 초기화는 ci_cnt==0 로직으로 처리됨
      prev_command <= 0;
    end
    else begin
      prev_command <= command;

      case (state)
        STATE_IDLE: begin
          write_ptr <= 0; wb_ptr <= 0; m_axis_tvalid <= 0; wgt_count <= 0; compute_busy <= 0;
          
          if (command == 3'd1 && prev_command != 3'd1) begin
            state <= STATE_LOAD_FEAT; f_writedone <= 0;
          end
          else if (command == 3'd2 && prev_command != 3'd2) begin
            state <= STATE_LOAD_BIAS; b_writedone <= 0;
          end
          else if (command == 3'd3 && prev_command != 3'd3) begin
            state <= STATE_STREAM_AND_CALC;
            cal_done <= 0;
            co_cnt <= 0; ci_cnt <= 0; r_cnt <= 0; c_cnt <= 0;
            compute_busy <= 0; 
          end
          else if (command == 3'd4 && prev_command != 3'd4) begin
            state <= STATE_SEND; transmit_done <= 0;
            read_ptr <= 0; sent_word_cnt <= 0;
            total_output_words <= (feature_length * feature_length * output_ch) >> 2;
          end
        end

        STATE_LOAD_FEAT: begin
          if (s_data_fire) begin
            input_buf[write_ptr]     <= S_AXIS_TDATA[7:0];
            input_buf[write_ptr + 1] <= S_AXIS_TDATA[15:8];
            input_buf[write_ptr + 2] <= S_AXIS_TDATA[23:16];
            input_buf[write_ptr + 3] <= S_AXIS_TDATA[31:24];
            write_ptr <= write_ptr + 4;
            if (S_AXIS_TLAST) begin f_writedone <= 1; state <= STATE_IDLE; end
          end
        end

        STATE_LOAD_BIAS: begin
          if (s_data_fire) begin
            bias_buf[write_ptr]     <= S_AXIS_TDATA[7:0];
            bias_buf[write_ptr + 1] <= S_AXIS_TDATA[15:8];
            bias_buf[write_ptr + 2] <= S_AXIS_TDATA[23:16];
            bias_buf[write_ptr + 3] <= S_AXIS_TDATA[31:24];
            write_ptr <= write_ptr + 4;
            if (S_AXIS_TLAST) begin b_writedone <= 1; state <= STATE_IDLE; end
          end
        end

        STATE_STREAM_AND_CALC: begin

          // [Loader] FIFO Filling & Loading
          if (do_receive && do_load) begin
             for(i_seq=0; i_seq<9; i_seq=i_seq+1) active_kernel[i_seq] <= wgt_fifo[i_seq];
             for(i_seq=0; i_seq<55; i_seq=i_seq+1) wgt_fifo[i_seq] <= wgt_fifo[i_seq+9]; 
             
             wgt_fifo[wgt_count - 9]     <= S_AXIS_TDATA[7:0];
             wgt_fifo[wgt_count - 9 + 1] <= S_AXIS_TDATA[15:8];
             wgt_fifo[wgt_count - 9 + 2] <= S_AXIS_TDATA[23:16];
             wgt_fifo[wgt_count - 9 + 3] <= S_AXIS_TDATA[31:24];
             
             wgt_count <= wgt_count - 5;
             compute_busy <= 1'b1; 
             r_cnt <= 0; c_cnt <= 0;
          end
          else if (do_load) begin
             for(i_seq=0; i_seq<9; i_seq=i_seq+1) active_kernel[i_seq] <= wgt_fifo[i_seq];
             for(i_seq=0; i_seq<55; i_seq=i_seq+1) wgt_fifo[i_seq] <= wgt_fifo[i_seq+9]; 
             wgt_count <= wgt_count - 9;
             compute_busy <= 1'b1;
             r_cnt <= 0; c_cnt <= 0;
          end
          else if (do_receive) begin
             wgt_fifo[wgt_count]   <= S_AXIS_TDATA[7:0];
             wgt_fifo[wgt_count+1] <= S_AXIS_TDATA[15:8];
             wgt_fifo[wgt_count+2] <= S_AXIS_TDATA[23:16];
             wgt_fifo[wgt_count+3] <= S_AXIS_TDATA[31:24];
             wgt_count <= wgt_count + 4;
          end
          
          // [Computer] 16-Pixel Full Parallel Computation (144 MACs)
          if (compute_busy) begin
             
             // (1) acc_mem 업데이트 (16픽셀 동시 쓰기)
             // next_acc_val은 Combinational Logic에서 9-MAC 합산까지 완료된 값
             for (p_seq = 0; p_seq < 16; p_seq = p_seq + 1) begin
                 if (c_cnt + p_seq < feature_length) begin
                     acc_mem[(r_cnt * feature_length) + c_cnt + p_seq] <= next_acc[p_seq];
                 end
             end

             // (2) 루프 진행 (1클럭에 16픽셀 점프, 커널 루프 없음!)
             if (c_cnt >= feature_length - 16) begin 
                 c_cnt <= 0;
                 if (r_cnt == feature_length - 1) begin
                   r_cnt <= 0;
                   
                   // --- 전체 이미지 완료 (64클럭) ---
                   compute_busy <= 1'b0; // 다음 가중치 대기
                   
                   if (ci_cnt == input_ch - 1) begin
                       ci_cnt <= 0;
                       state <= STATE_WRITE_BACK; // 계산 끝, 복사 시작
                       wb_ptr <= 0;
                   end else begin
                       ci_cnt <= ci_cnt + 1;
                       // (state 유지: STATE_STREAM_AND_CALC)
                   end
                 end else r_cnt <= r_cnt + 1;
             end else c_cnt <= c_cnt + 16; 
          end 
        end

        STATE_WRITE_BACK: begin
           // 미리 계산된 wb_val_a, wb_val_b를 가져와 저장
           output_buf[(co_cnt * feature_length * feature_length) + wb_ptr] <= wb_val_a;
           output_buf[(co_cnt * feature_length * feature_length) + wb_ptr + 1] <= wb_val_b;
           
           wb_ptr <= wb_ptr + 2;
           
           if (wb_ptr >= (feature_length * feature_length) - 2) begin
               if (co_cnt == output_ch - 1) begin
                   state <= STATE_IDLE; cal_done <= 1'b1; conv_done <= 1'b1;
               end else begin
                   co_cnt <= co_cnt + 1;
                   state <= STATE_STREAM_AND_CALC; 
               end
           end
        end

        STATE_SEND: begin
          if (!m_axis_tvalid) begin
            m_axis_tdata_reg <= send_pack_data;
            m_axis_tvalid <= 1'b1;
            if (sent_word_cnt == total_output_words - 1) m_axis_tlast <= 1'b1;
          end
          if (m_data_fire) begin
            m_axis_tvalid <= 1'b0; m_axis_tlast <= 1'b0;
            read_ptr <= read_ptr + 4; sent_word_cnt <= sent_word_cnt + 1;
            if (sent_word_cnt == total_output_words - 1) begin
              state <= STATE_IDLE; transmit_done <= 1'b1;
            end
          end
        end
        
        default: state <= STATE_IDLE;
      endcase
      
      if (f_writedone_ack) f_writedone <= 0;
      if (b_writedone_ack) b_writedone <= 0;
      if (cal_done_ack) cal_done <= 0;
      if (transmit_done_ack) transmit_done <= 0;
    end
  end

endmodule*/