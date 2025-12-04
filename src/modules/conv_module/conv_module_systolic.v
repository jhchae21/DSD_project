/*
* conv_module.v
* * [Architecture]
* - Parameterized Systolic Array (Default 4x4)
* - Fully Banked Memory System (Weight & Output Banks generated as independent BRAMs)
* - Ping-Pong Double Buffering for Simultaneous Compute & Send
* * [Dataflow]
* 1. Load Features & Bias (Once)
* 2. STREAM Loop:
* a. Load Weights for current Output Tile (Concurrent with Send)
* b. Compute Tile (Systolic Flow) -> Write to Output Bank (Ping)
* c. Send Previous Tile Result (Pong) -> AXI Stream
*/

module conv_module 
  #(
    parameter integer C_S00_AXIS_TDATA_WIDTH = 32,
    parameter integer ARRAY_SIZE             = 4  // Must be multiple of 4
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

  // ===========================================================================
  // 1. Internal Signals & Constants
  // ===========================================================================
  
  reg [31:0] m_axis_tdata_reg;
  reg m_axis_tlast_reg;
  reg m_axis_tvalid_reg;
  wire s_axis_tready;
  
  assign S_AXIS_TREADY = s_axis_tready;
  assign M_AXIS_TDATA = m_axis_tdata_reg;
  assign M_AXIS_TLAST = m_axis_tlast_reg;
  assign M_AXIS_TVALID = m_axis_tvalid_reg;
  assign M_AXIS_TUSER = 1'b0;
  assign M_AXIS_TKEEP = {(C_S00_AXIS_TDATA_WIDTH/8) {1'b1}};

  localparam STATE_IDLE        = 3'd0;
  localparam STATE_LOAD_FEAT   = 3'd1;
  localparam STATE_LOAD_BIAS   = 3'd2;
  localparam STATE_STREAM      = 3'd3; 
  localparam STATE_FINISH      = 3'd4;

  reg [2:0] state;
  wire [11:0] total_pixels = feature_length * feature_length;
  wire [11:0] words_per_channel = total_pixels >> 2;

  // ===========================================================================
  // 2. Memory Definitions (Generating Independent BRAM Banks)
  // ===========================================================================

  // Input Buffer: Distributed RAM
  (* ram_style = "distributed" *) reg signed [7:0] input_buf [0:8191];
  
  // Bias Buffer: Distributed RAM
  (* ram_style = "distributed" *) reg signed [7:0] bias_buf [0:255];  

  // Weight Banks (Rows) - Generated BRAMs
  // To allow independent access, we generate N always blocks
  reg [31:0] w_bank_wdata [0:ARRAY_SIZE-1];  // 각 뱅크에 쓸 데이터
  reg [11:0] w_bank_addr  [0:ARRAY_SIZE-1];  // 각 뱅크의 주소 (Depth 4096)
  reg        w_bank_we    [0:ARRAY_SIZE-1];  // 각 뱅크의 쓰기 신호
  wire [31:0] w_bank_rdata [0:ARRAY_SIZE-1];  // 각 뱅크의 읽기 결과

  // Output Banks (Rows) - 각 Bank가 Output channel 1개 전체 가짐!(4개씩 묶어서) Generated BRAMs, Port A: write, Port B: Read
  reg [31:0] o_bank_wdata_a [0:ARRAY_SIZE-1]; 
  reg [11:0] o_bank_addr_a  [0:ARRAY_SIZE-1];
  reg        o_bank_we_a    [0:ARRAY_SIZE-1];
  reg [11:0] o_bank_addr_b  [0:ARRAY_SIZE-1];
  wire [31:0] o_bank_rdata_b [0:ARRAY_SIZE-1];
  

  genvar bk;
  generate
      for (bk=0; bk < ARRAY_SIZE; bk=bk+1) begin : gen_banks
          
          // Weight Bank BRAM
          (* ram_style = "block" *) reg [31:0] weight_mem [0:4095];
          reg [31:0] w_rdata_reg;
          
          always @(posedge clk) begin
              if (w_bank_we[bk]) 
                  weight_mem[w_bank_addr[bk]] <= w_bank_wdata[bk];
              w_rdata_reg <= weight_mem[w_bank_addr[bk]]; // Sync Read
          end
          assign w_bank_rdata[bk] = w_rdata_reg; // BRAM의 결과는 1clk 뒤에 나옴!

          // Output Bank BRAM
          (* ram_style = "block" *) reg [31:0] output_mem [0:4095];
          reg [31:0] o_rdata_reg;
          
          always @(posedge clk) begin
              if (o_bank_we_a[bk]) 
                  output_mem[o_bank_addr_a[bk]] <= o_bank_wdata_a[bk];
              o_rdata_reg <= output_mem[o_bank_addr_b[bk]]; // Sync Read
          end
          assign o_bank_rdata_b[bk] = o_rdata_reg; // BRAM의 결과는 1clk 뒤에 나옴!
      end
  endgenerate

  // ===========================================================================
  // 3. Counters & Control Signals
  // ===========================================================================
  
  reg [31:0] write_ptr; // 각 Weight Bank에 현재 write할 위치
  
  // Compute Loop Counters
  reg [8:0] co_tile_idx;  // 현재 처리중인 output channel group(0, 4, 8, ...)
  reg [10:0] pix_cnt;     // 현재 처리중인 픽셀 index
  reg [8:0] ci_cnt;       // 현재 처리중인 input channel
  reg [3:0] k_cnt;        // 현재 처리중인 filter 내 위치
  
  // Send Loop Counters
  reg [31:0] sent_word_cnt;      // 총 전송된 워드 수
  reg [31:0] stored_word_cnt;
  reg [31:0] total_output_words; // 총 보낼 word 수

  // Send Banking Counters
  reg [8:0]  send_ch_offset;   // 현재 보내는 channel이 몇번째인지 (0~ARRAY_SIZE-1)
  reg [11:0] send_word_idx;    // 현재 channel에서의 word index
  reg [8:0] send_co_tile;

  // Ping-Pong Control
  reg compute_bank_sel; // 0: 하위 주소(0~2047), 1: 상위 주소(2048~4095)
  reg send_bank_sel;    // 전송은 계산과 반대쪽 버퍼를 읽음
  
  // Systolic Array Signals
  reg sa_start_clr;                                     // 새로운 data 계산 start signal
  wire [ARRAY_SIZE*8-1:0] w_vec;                        // Systolic array에 넣어줄 weight vector
  wire [ARRAY_SIZE*8-1:0] f_vec;                        // Systolic array에 넣어줄 input vector
  wire [ARRAY_SIZE*ARRAY_SIZE*32-1:0] sa_results_flat;  // Systolic array에서 받은 결과들 vector(flattened)
  
  // Handshake
  reg load_weight_phase;                                 // weight load 해야할 때
  wire s_data_fire = S_AXIS_TVALID && s_axis_tready;
  wire m_data_fire = m_axis_tvalid_reg && M_AXIS_TREADY;
  
  assign s_axis_tready = (state == STATE_LOAD_FEAT || state == STATE_LOAD_BIAS || (state == STATE_STREAM && load_weight_phase));

  reg [2:0] prev_command;

  // Weight Alignment Logic Variables
  reg [31:0] w_carry_reg;
  reg [2:0]  w_carry_cnt;
  reg [31:0] bytes_written_cnt;
  wire [31:0] bytes_per_filter = input_ch * 9;

  // Weight Alignment Logic Variables (Combinational에서 사용)
  reg [63:0] comb_combined_data;
  reg [31:0] comb_data_to_write;
  reg [31:0] comb_next_carry_reg;
  reg [2:0]  comb_next_carry_cnt;
  reg        comb_filter_done;    // 필터가 끝났는지 여부
  reg weight_phase_off;

  // ===========================================================================
  // 4. Systolic Array Instantiation
  // ===========================================================================
  
  systolic_array #(
      .DATA_WIDTH(8),
      .ACC_WIDTH(32),
      .ARRAY_SIZE(ARRAY_SIZE)
  ) u_sa (
      .clk(clk),
      .rstn(rstn),
      .start_clr(sa_start_clr),
      .w_in(w_vec),
      .f_in(f_vec),
      .pe_results(sa_results_flat)
  );

  wire signed [31:0] sa_res_mat [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];  // Flattened systolic array result를 2차원으로 저장
  genvar r, c;
  generate
      for(r=0; r<ARRAY_SIZE; r=r+1) begin : res_row
          for(c=0; c<ARRAY_SIZE; c=c+1) begin : res_col
              assign sa_res_mat[r][c] = sa_results_flat[((r*ARRAY_SIZE + c) + 1)*32 - 1 : (r*ARRAY_SIZE + c)*32];
          end
      end
  endgenerate

  // ===========================================================================
  // 5. Data Feeding & Banking Logic
  // ===========================================================================

  wire [31:0] w_idx_linear = (ci_cnt * 9) + k_cnt; // 각 weight bank들에서 weight 가져올 주소
  reg [1:0] w_byte_sel;                            // BRAM에서 읽어온 32비트 데이터 중 어느 바이트를 쓸지 선택하는 신호(BRAM latency 맞춰 1클럭 늦게 반영)

  reg [11:0] w_load_cnt; // 현재 필터 내에서의 워드 인덱스
  reg [5:0]  w_bank_idx; // 현재 저장 중인 뱅크 인덱스

  wire [31:0] w_limit = ((input_ch * 9) + 3) >> 2;  // 필터 하나당 워드 수 = (InputCh * 9 + 3) / 4 (Ceiling)

  // [추가] Weight Alignment Combinational Logic
  always @(*) begin
      comb_combined_data = 0;
      comb_data_to_write = 0;
      comb_next_carry_reg = 0;
      comb_next_carry_cnt = 0;
      comb_filter_done = 0;

      if (state == STATE_STREAM && load_weight_phase) begin
          // 1. Combine Carry + New Data (Little Endian)
          // Carry가 LSB(먼저 온 데이터), S_AXIS_TDATA가 MSB(나중에 온 데이터)
          comb_combined_data = ({32'd0, S_AXIS_TDATA} << (w_carry_cnt * 8)) | w_carry_reg;
          
          // BRAM에 쓸 데이터는 하위 32비트
          comb_data_to_write = comb_combined_data[31:0];

          // 2. Boundary Check (필터가 끝나는지 계산)
          if ((bytes_per_filter - bytes_written_cnt) <= 8) weight_phase_off <= 1;
          // 남은 바이트 수 계산
          if ((bytes_per_filter - bytes_written_cnt) <= 4) begin
              // 필터 완료 (Filter Done)
              comb_filter_done = 1;
              
              // 다음 필터를 위해 넘길 Carry 계산
              // 사용된 바이트 수 = (bytes_per_filter - bytes_written_cnt)
              comb_next_carry_reg = comb_combined_data >> ((bytes_per_filter - bytes_written_cnt) * 8);
              
              // 다음 Carry 개수 = (기존 Carry + 4) - 사용된 바이트
              comb_next_carry_cnt = (w_carry_cnt + 4) - (bytes_per_filter - bytes_written_cnt);
          end 
          else begin
              // 필터 계속됨 (Filter Continues)
              comb_filter_done = 0;
              
              // 상위 32비트를 Carry로 넘김
              comb_next_carry_reg = comb_combined_data[63:32];
              // 4바이트를 꽉 채워 썼으므로 Carry 개수는 변함 없음 (Input 4B -> Output 4B)
              comb_next_carry_cnt = w_carry_cnt;
          end
      end
  end

  // Pack Read Data to w_vec
  genvar k;
  generate
      for(k=0; k<ARRAY_SIZE; k=k+1) begin : pack_w
          assign w_vec[(k+1)*8-1 : k*8] = w_bank_rdata[k][w_byte_sel * 8 +: 8]; // w_bank_rdata(32bit)에서 w_byte_sel에 해당하는 8bit만 추출
      end
  endgenerate

  // --- Feature Feeder (Im2col Address Gen) ---
  reg [7:0] f_feed_val [0:ARRAY_SIZE-1];         // f_vec에 넣어줄 각 위치에 대한 값들
  reg signed [15:0] cur_r, cur_c, pad_r, pad_c;  // 현재 pixel의 r, c 값들
  reg [10:0] cur_pix_idx;                        // 현재 pixel의 index
  integer j_idx;                                 // Array index
  
  always @(*) begin
      for(j_idx=0; j_idx<ARRAY_SIZE; j_idx=j_idx+1) begin
          cur_pix_idx = pix_cnt + j_idx; // column에 따라 pixel 위치 하나씩 변함
          // Coordinate Decode
          if (feature_length == 32) begin cur_r = cur_pix_idx[9:5]; cur_c = cur_pix_idx[4:0]; end
          else if (feature_length == 16) begin cur_r = cur_pix_idx[7:4]; cur_c = cur_pix_idx[3:0]; end
          else if (feature_length == 8) begin cur_r = cur_pix_idx[5:3]; cur_c = cur_pix_idx[2:0]; end
          else begin cur_r = cur_pix_idx[3:2]; cur_c = cur_pix_idx[1:0]; end
          
          // Offset
          pad_r = cur_r + (k_cnt/3) - 1;
          pad_c = cur_c + (k_cnt%3) - 1;
          
          // Read
          if (cur_pix_idx >= total_pixels || pad_r < 0 || pad_r >= feature_length || pad_c < 0 || pad_c >= feature_length)
              f_feed_val[j_idx] = 8'd0;
          else
              f_feed_val[j_idx] = input_buf[(ci_cnt * total_pixels) + (pad_r * feature_length) + pad_c];
      end
  end

  generate
      for(k=0; k<ARRAY_SIZE; k=k+1) begin : pack_f
          assign f_vec[(k+1)*8-1 : k*8] = f_feed_val[k];
      end
  endgenerate

  // --- Send Logic (Read MUX) ---
  // 전송할 데이터 선택
  reg [31:0] send_rdata_mux;
  
  always @(*) begin
      send_rdata_mux = 0;
      // 현재 전송 중인 채널(0~3)에 해당하는 뱅크 데이터를 선택
      if (send_ch_offset < ARRAY_SIZE) begin
          send_rdata_mux = o_bank_rdata_b[send_ch_offset];
      end
  end

  // ===========================================================================
  // 6. Sequential Logic
  // ===========================================================================
  integer b;
  
  // Writeback
  reg [31:0] wb_pack_reg [0:ARRAY_SIZE-1]; // writeback할 8bit 값들 32bit로 packing한 register
  reg [2:0]  wb_cnt [0:ARRAY_SIZE-1];      // bank 안에서의 counter
  reg        wb_active [0:ARRAY_SIZE-1];   // Writeback active flag

  // Trigger signal: When calculation finishes (k=8, ci=last)
  wire tile_done_pulse = (state == STATE_STREAM && !load_weight_phase && k_cnt == 8 && ci_cnt == input_ch - 1);
  reg [ARRAY_SIZE-1:0] row_trigger_sr; // Delayed trigger for each row (Wavefront)

  reg signed [31:0] raw_v;
  reg [7:0] q_v;

  // Weight write alignment용
  reg [63:0] combined_data;
  reg [31:0] data_to_write;
  integer bytes_needed;
  
  always @(posedge clk) begin
    if (!rstn) begin
      state <= STATE_IDLE;
      write_ptr <= 0;
      co_tile_idx <= 0; pix_cnt <= 0; ci_cnt <= 0; k_cnt <= 0;
      compute_bank_sel <= 0; send_bank_sel <= 1;
      load_weight_phase <= 0; sa_start_clr <= 0;
      f_writedone <= 0; b_writedone <= 0; cal_done <= 0; transmit_done <= 0; conv_done <= 0;
      m_axis_tvalid_reg <= 0; m_axis_tlast_reg <= 0; m_axis_tdata_reg <= 0;
      sent_word_cnt <= 0; stored_word_cnt <= 0; prev_command <= 0;
      send_ch_offset <= 0; send_word_idx <= 0; send_co_tile <= 0;
      w_load_cnt <= 0; w_bank_idx <= 0; w_byte_sel <= 0;
      row_trigger_sr <= 0;
      w_carry_reg <= 0;
      w_carry_cnt <= 0;
      bytes_written_cnt <= 0; weight_phase_off <= 0;
      
      for(b=0; b<ARRAY_SIZE; b=b+1) begin
          w_bank_we[b] <= 0; w_bank_addr[b] <= 0; w_bank_wdata[b] <= 0;
          o_bank_we_a[b] <= 0; o_bank_addr_a[b] <= 0; o_bank_wdata_a[b] <= 0; o_bank_addr_b[b] <= 0;
          wb_pack_reg[b] <= 0; wb_cnt[b] <= 0; wb_active[b] <= 0;
      end
    end
    else begin
      prev_command <= command;
      
      // 1. Trigger Propagation (Row Skew)
      // row_trigger_sr[0] is for Row 0 (Bank 0).
      row_trigger_sr <= {row_trigger_sr[ARRAY_SIZE-2:0], tile_done_pulse};
      
      // 2. Per-Bank Packing Logic
      for (b=0; b<ARRAY_SIZE; b=b+1) begin
          // 각 뱅크는 자기 차례가 오면 작업 시작
          if (row_trigger_sr[b]) begin
              wb_active[b] <= 1; // 수집 시작 플래그 on
              wb_cnt[b] <= 0;    // 뱅크 내 픽셀 카운터 0으로 초기화
          end
          
          if (wb_active[b]) begin
              // 32비트 output 값(sa_res_mat[b]) 처리해서 8 bit로 만들기(q_v)             
              raw_v = (sa_res_mat[b][wb_cnt[b]] >>> 6) + bias_buf[co_tile_idx + b];
              
              if(raw_v < 0) q_v = 0;
              else if(raw_v > 127) q_v = 127;
              else q_v = raw_v[7:0];
              
              // q_v들 32비트로 packing
              wb_pack_reg[b][wb_cnt[b]*8 +: 8] <= q_v;
              
              if (wb_cnt[b][1:0] == 2'b11) begin
                  // Packing Done -> Write to Bank 'b'
                  o_bank_we_a[b] <= 1;

                  o_bank_wdata_a[b] <= {q_v, wb_pack_reg[b][23:0]}; // Include current byte
                  
                  // 주소 증가 (뱅크별 독립적인 주소 카운터 사용)
                  o_bank_addr_a[b] <= o_bank_addr_a[b] + 1;

                  // 모든 픽셀 처리 완료 여부 확인
                  if (wb_cnt[b] == ARRAY_SIZE - 1) begin
                      wb_active[b] <= 0; // 이 타일 처리 끝
                      
                      // 첫 번째 뱅크가 완료되면 전역 카운터 업데이트 (동기화용)
                      if (b == 0) stored_word_cnt <= stored_word_cnt + (ARRAY_SIZE / 4);
                  end
              end else begin
                  o_bank_we_a[b] <= 0;
              end
              // 카운터 증가 (완료되지 않았으면)
              if (wb_active[b]) wb_cnt[b] <= wb_cnt[b] + 1;
          end else begin
              o_bank_we_a[b] <= 0;
          end
      end

      // --- Memory Control Signals Generation (Registered) ---
      
      // 1. Weight Bank Write (During Load)
      if (state == STATE_STREAM && load_weight_phase && s_data_fire) begin
          // 현재 뱅크에 데이터 쓰기
          w_bank_we[w_bank_idx] <= 1;
          w_bank_wdata[w_bank_idx] <= comb_data_to_write;
          w_bank_addr[w_bank_idx] <= w_load_cnt;
          
          for(b=0; b<ARRAY_SIZE; b=b+1) begin
              if(b != w_bank_idx) w_bank_we[b] <= 0;
          end

          // 상태 업데이트 (Filter Done 여부에 따라 분기)
          if (comb_filter_done) begin
              // 한 필터 완료 -> 다음 뱅크로 이동
              w_load_cnt <= 0;
              bytes_written_cnt <= 0;
              
              if (w_bank_idx == ARRAY_SIZE - 1) w_bank_idx <= 0; 
              else w_bank_idx <= w_bank_idx + 1;
          end 
          else begin
              // 필터 계속 -> 주소 증가
              w_load_cnt <= w_load_cnt + 1;
              bytes_written_cnt <= bytes_written_cnt + 4;
          end
          
          // Carry 레지스터 업데이트
          w_carry_reg <= comb_next_carry_reg;
          w_carry_cnt <= comb_next_carry_cnt;
      end 
      // 2. Weight Bank Read (During Calc)
      else if (state == STATE_STREAM && !load_weight_phase) begin
          for(b=0; b<ARRAY_SIZE; b=b+1) begin
              w_bank_we[b] <= 0;
              w_bank_addr[b] <= w_idx_linear[31:2]; // Divide by 4 (주소 4개씩 packing)
          end
          w_byte_sel <= w_idx_linear[1:0]; // Modulo 4
      end else begin
          for(b=0; b<ARRAY_SIZE; b=b+1) w_bank_we[b] <= 0;
      end

      // 4. Output Bank Read (During Send)
      if (state == STATE_STREAM || state == STATE_FINISH) begin
          for(b=0; b<ARRAY_SIZE; b=b+1) begin
              o_bank_addr_b[b] <= (send_bank_sel ? 2048 : 0) + send_word_idx; // Next address to read
          end
      end


      // --- Main FSM ---
      case(state)
        STATE_IDLE: begin
            write_ptr <= 0; sent_word_cnt <= 0; sent_word_cnt <= 0;
            if (command == 3'd1 && prev_command != 3'd1) begin state <= STATE_LOAD_FEAT; f_writedone <= 0; end
            else if (command == 3'd2 && prev_command != 3'd2) begin state <= STATE_LOAD_BIAS; b_writedone <= 0; end
            else if (command == 3'd3 && prev_command != 3'd3) begin 
                state <= STATE_STREAM; 
                cal_done <= 0; transmit_done <= 0;
                load_weight_phase <= 1; // Start by loading weights
                co_tile_idx <= 0; pix_cnt <= 0;
                write_ptr <= 0; w_load_cnt <= 0; w_bank_idx <= 0;
                total_output_words <= (feature_length * feature_length * output_ch) >> 2; 

                // Write Addr 초기화
                for(b=0; b<ARRAY_SIZE; b=b+1) o_bank_addr_a[b] <= (compute_bank_sel ? 2048 : 0);
            end
        end

        STATE_LOAD_FEAT: begin
            if(s_data_fire) begin
                input_buf[write_ptr] <= S_AXIS_TDATA[7:0];
                input_buf[write_ptr+1] <= S_AXIS_TDATA[15:8];
                input_buf[write_ptr+2] <= S_AXIS_TDATA[23:16];
                input_buf[write_ptr+3] <= S_AXIS_TDATA[31:24];
                write_ptr <= write_ptr + 4;
                if(S_AXIS_TLAST) begin state <= STATE_IDLE; f_writedone <= 1; end
            end
        end

        STATE_LOAD_BIAS: begin
            if(s_data_fire) begin
                bias_buf[write_ptr] <= S_AXIS_TDATA[7:0];
                bias_buf[write_ptr+1] <= S_AXIS_TDATA[15:8];
                bias_buf[write_ptr+2] <= S_AXIS_TDATA[23:16];
                bias_buf[write_ptr+3] <= S_AXIS_TDATA[31:24];
                write_ptr <= write_ptr + 4;
                if(S_AXIS_TLAST) begin state <= STATE_IDLE; b_writedone <= 1; end
            end
        end
        
        STATE_STREAM: begin
            // --- Thread 1: Compute & Load ---
            if (load_weight_phase) begin
                // [수정] 로딩 종료 조건: 타일 하나(4필터) 분량 완료 시
                if (s_data_fire && ((w_bank_idx == ARRAY_SIZE - 1 && weight_phase_off) || S_AXIS_TLAST)) begin
                    load_weight_phase <= 0; 
                    sa_start_clr <= 1; ci_cnt <= 0; k_cnt <= 0;
                    w_load_cnt <= 0; w_bank_idx <= 0; weight_phase_off <= 0;
                end
            end
            else begin
                if (sa_start_clr) sa_start_clr <= 0;
                
                if (k_cnt == 8) begin
                    k_cnt <= 0;
                    if (ci_cnt == input_ch - 1) begin
                        ci_cnt <= 0;
                        // Tile Done!
                        if (pix_cnt >= total_pixels - ARRAY_SIZE) begin
                            pix_cnt <= 0;
                            // Buffer Swap
                            compute_bank_sel <= ~compute_bank_sel;
                            send_bank_sel <= ~send_bank_sel;
                            
                            // Reset Write Addrs for new buffer
                            for(b=0; b<ARRAY_SIZE; b=b+1) 
                                o_bank_addr_a[b] <= (compute_bank_sel ? 0 : 2048); // Swap은 여기서 적용 안 됨? 
                                // 아, 위에서 토글했으니 반대로 적용해야 함. 
                                // 토글된 compute_bank_sel이 다음 타겟.
                                // (주의: ~compute_bank_sel 값이 다음 클럭에 적용됨)
                                // 여기서는 Non-blocking 할당이므로 현재 값의 반대로 세팅해야 함?
                                // 복잡하니 compute_bank_sel 로직을 잘 맞춰야 함.
                                // 토글된 값이 적용된 주소를 넣어야 함.
                                
                            // Reset Send Logic
                            send_co_tile <= co_tile_idx; 
                            send_ch_offset <= 0;
                            send_word_idx <= 0; 

                            if (co_tile_idx + ARRAY_SIZE >= output_ch) begin
                                state <= STATE_FINISH; 
                            end else begin
                                co_tile_idx <= co_tile_idx + ARRAY_SIZE;
                                load_weight_phase <= 1; 
                                write_ptr <= 0;
                            end
                        end else begin
                            pix_cnt <= pix_cnt + ARRAY_SIZE;
                            sa_start_clr <= 1; 
                        end
                    end else begin
                        ci_cnt <= ci_cnt + 1;
                    end
                end else begin
                    k_cnt <= k_cnt + 1;
                end
            end

            // [Thread 2] Send (NCHW Order)
            // 한글 설명:
            // 1. 'sent_word_cnt'가 'stored_word_cnt * ARRAY_SIZE'(현재까지 저장된 총 워드 수)보다 작으면 전송 가능
            // 2. 한 채널(Bank)의 데이터를 다 보낼 때까지 쭉 읽음 (send_word_idx 증가)
            // 3. 다 보내면 다음 채널(Bank)로 넘어감 (send_ch_offset 증가)
            // 4. 이 과정을 4개 채널에 대해 반복
            
            if (M_AXIS_TREADY) begin
                if (sent_word_cnt < (stored_word_cnt * ARRAY_SIZE) && sent_word_cnt < total_output_words) begin
                     m_axis_tvalid_reg <= 1;
                     m_axis_tdata_reg <= send_rdata_mux; 
                     
                     if (m_axis_tvalid_reg) begin
                         sent_word_cnt <= sent_word_cnt + 1;
                         if (sent_word_cnt == total_output_words - 1) m_axis_tlast_reg <= 1;
                         
                         if (send_word_idx == words_per_channel - 1) begin
                             send_word_idx <= 0;
                             if (send_ch_offset < ARRAY_SIZE - 1) 
                                 send_ch_offset <= send_ch_offset + 1;
                             else 
                                 send_ch_offset <= 0; 
                         end else begin
                             send_word_idx <= send_word_idx + 1;
                         end
                         
                         // Next Addr (Double Buffer Offset applied)
                         o_bank_addr_b[send_ch_offset] <= (send_bank_sel ? 2048 : 0) + send_word_idx + 1;
                     end
                end else begin
                    m_axis_tvalid_reg <= 0;
                    m_axis_tlast_reg <= 0;
                end
            end
        end
        
        STATE_FINISH: begin
            // Wait for remaining Send
            if (sent_word_cnt < total_output_words) begin
                 if (M_AXIS_TREADY) begin
                    m_axis_tvalid_reg <= 1;
                    m_axis_tdata_reg <= send_rdata_mux;
                    if (m_axis_tvalid_reg) begin
                         sent_word_cnt <= sent_word_cnt + 1;
                         if (sent_word_cnt == total_output_words - 1) m_axis_tlast_reg <= 1;
                    end
                 end
            end else begin
                 state <= STATE_IDLE;
                 m_axis_tvalid_reg <= 0; m_axis_tlast_reg <= 0;
                 cal_done <= 1; transmit_done <= 1; conv_done <= 1;
                 w_load_cnt <= 0;
                 w_bank_idx <= 0;
            end
        end

      endcase
      
      // Ack Resets
      if (f_writedone_ack) f_writedone <= 0;
      if (b_writedone_ack) b_writedone <= 0;
      if (cal_done_ack) cal_done <= 0;
      if (transmit_done_ack) transmit_done <= 0;
    end
  end

endmodule
