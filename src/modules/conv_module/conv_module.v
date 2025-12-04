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
  
  reg [31:0] m_axis_tdata_reg;
  assign m_axis_tdata = m_axis_tdata_reg;

  // FSM States
  localparam STATE_IDLE            = 3'd0;
  localparam STATE_LOAD_FEAT       = 3'd1;
  localparam STATE_LOAD_BIAS       = 3'd2;
  localparam STATE_STREAM_AND_CALC = 3'd3;
  localparam STATE_SEND            = 3'd4;

  reg [2:0] state;

  // Input Buf: Distributed RAM (병렬 읽기 지원을 위해 필수)
  (* ram_style = "distributed" *) reg signed [7:0] input_buf [0:8191];
  
  // Bias Buf: Distributed RAM (빠른 접근)
  (* ram_style = "distributed" *) reg signed [7:0] bias_buf [0:255];  
  
  // Output Buf: Block RAM, Packed (32bit)
  (* ram_style = "block" *) reg signed [31:0] output_buf [0:8191]; 

  // Accumulator Register (Image Size: 32x32) (계산 중에는 BRAM 대신 이 레지스터에 값을 누적)
  reg signed [31:0] acc_mem [0:1023];

  // Weight Streaming: 9 bytes (커널 1개) 단위로 처리
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
  reg [10:0] pix_cnt;  // Pixel Counter (0 ~ 1023, 32*32)
  
  reg [31:0] total_output_words; 
  reg [31:0] sent_word_cnt;
  reg [2:0] prev_command;
  
  // Data Fire Signals
  wire s_data_fire = S_AXIS_TVALID && s_axis_tready;
  wire m_data_fire = m_axis_tvalid && M_AXIS_TREADY;

  wire do_receive = s_data_fire;
  wire do_load = (!compute_busy && wgt_count >= 9); // 커널 1개(9바이트)만 있으면 됨

  // [Wire Logic] Zero Padding & Indexing
  
  integer p, k;
  reg signed [7:0]  w_val;    // 커널 가중치
  reg signed [7:0]  i_val;  // Pixel의 입력값
  reg signed [31:0] mult;   
  reg signed [31:0] pixel_sum; 
  reg signed [31:0] next_acc [0:3];

  reg signed [15:0] curr_r, curr_c, pad_r, pad_c;

  // Packing Variables
  reg signed [31:0] raw_val;
  reg [7:0] final_byte [0:7]; // 8픽셀용
  reg [31:0] pack_word;
  
  // BRAM Control MUX
  reg [31:0] bram_addr;
  reg bram_we;
  reg [31:0] bram_wdata;
  
  // Send Variables
  reg [31:0] send_data_latch; 
  reg send_phase; // BRAM Read Latency용 (0:Addr, 1:Data Valid)

  wire [10:0] total_pixels = feature_length * feature_length;
  reg [10:0] logic_idx;

  // Combinational Logic
  assign s_axis_tready = (state == STATE_LOAD_FEAT) || (state == STATE_LOAD_BIAS) || ((state == STATE_STREAM_AND_CALC) && (wgt_count < 40)); 
  
  always @(*) begin
      // 36-Way Parallel MAC Logic (4 Pixels x 9 Weights)
      for (p = 0; p < 4; p = p + 1) begin
          pixel_sum = 0; // 9 MACs sum initialization
          // pix_cnt + p 가 현재 처리할 픽셀의 인덱스, feature_length에 따라 row, col을 역산하여 패딩 처리
          logic_idx = pix_cnt + p;
          
          // Coordinate Decoder
          if (feature_length == 32) begin
            curr_r = logic_idx[9:5]; curr_c = logic_idx[4:0];
          end else if (feature_length == 16) begin
            curr_r = logic_idx[7:4]; curr_c = logic_idx[3:0];
          end else if (feature_length == 8) begin
            curr_r = logic_idx[5:3]; curr_c = logic_idx[2:0];
          end else begin // length == 4
            curr_r = logic_idx[3:2]; curr_c = logic_idx[1:0];
          end
            
          // 9-Way Kernel Loop
          for (k = 0; k < 9; k = k + 1) begin
              w_val = active_kernel[k];
              
              pad_r = curr_r + (k/3) - 1;
              pad_c = curr_c + (k%3) - 1;
              
              // Zero Padding Check
              if ( (logic_idx >= total_pixels) ||
                  (pad_r < 0) || (pad_r >= feature_length) || 
                  (pad_c < 0) || (pad_c >= feature_length) ) begin
                  i_val = 8'd0; 
              end else begin
                  i_val = input_buf[ (ci_cnt * total_pixels) + (pad_r * feature_length) + pad_c ];
              end
                
              mult = i_val * w_val;
              pixel_sum = pixel_sum + mult;
          end 
            
          // Accumulate
          if (ci_cnt == 0) next_acc[p] = pixel_sum; 
          else next_acc[p] = acc_mem[logic_idx] + pixel_sum; 
      end 

      // Packing Logic (for Last Channel)
      for(p=0; p<4; p=p+1) begin
          raw_val = (next_acc[p] >>> 6) + bias_buf[co_cnt];
          if (raw_val < 0) final_byte[p] = 0;
          else if (raw_val > 127) final_byte[p] = 127;
          else final_byte[p] = raw_val[7:0];
      end
      pack_word = {final_byte[3], final_byte[2], final_byte[1], final_byte[0]};

      // BRAM Control
      bram_we = 0;
      bram_addr = 0;
      bram_wdata = 0;

      // pix_cnt 기반 BRAM 주소 계산
      if (state == STATE_STREAM_AND_CALC && compute_busy && (ci_cnt == input_ch - 1)) begin
          bram_we = 1'b1;
          bram_addr = (co_cnt * (total_pixels >> 2)) + (pix_cnt >> 2);
          
          bram_wdata = pack_word;
      end
      else if (state == STATE_SEND) begin
          bram_addr = read_ptr;
      end
  end


  // Sequential Logic
  integer i_seq, p_seq;
  always @(posedge clk) begin
    if (!rstn) begin
      state <= STATE_IDLE;
      m_axis_tvalid <= 0; m_axis_tlast <= 0; m_axis_tdata_reg <= 0;
      f_writedone <= 0; b_writedone <= 0; cal_done <= 0; transmit_done <= 0; conv_done <= 0;
      write_ptr <= 0; read_ptr <= 0; 
      wgt_count <= 0; compute_busy <= 0;
      co_cnt <= 0; ci_cnt <= 0; 
      pix_cnt <= 0;
      send_phase <= 0;
      prev_command <= 0;
    end
    else begin
      prev_command <= command;
      
      if (bram_we) output_buf[bram_addr] <= bram_wdata;

      case (state)
        STATE_IDLE: begin
          write_ptr <= 0; m_axis_tvalid <= 0; wgt_count <= 0; compute_busy <= 0; send_phase <= 0;
          if (command == 3'd1 && prev_command != 3'd1) begin state <= STATE_LOAD_FEAT; f_writedone <= 0; end
          else if (command == 3'd2 && prev_command != 3'd2) begin state <= STATE_LOAD_BIAS; b_writedone <= 0; end
          else if (command == 3'd3 && prev_command != 3'd3) begin state <= STATE_STREAM_AND_CALC; cal_done <= 0;
            co_cnt <= 0; ci_cnt <= 0; pix_cnt <= 0;
          end
          else if (command == 3'd4 && prev_command != 3'd4) begin state <= STATE_SEND; transmit_done <= 0;
            read_ptr <= 0; sent_word_cnt <= 0; send_phase <= 0;
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
          // Loader
          if (do_receive && do_load) begin
             for(i_seq=0; i_seq<9; i_seq=i_seq+1) active_kernel[i_seq] <= wgt_fifo[i_seq];
             for(i_seq=0; i_seq<55; i_seq=i_seq+1) wgt_fifo[i_seq] <= wgt_fifo[i_seq+9]; 
             wgt_fifo[wgt_count - 9]     <= S_AXIS_TDATA[7:0];
             wgt_fifo[wgt_count - 9 + 1] <= S_AXIS_TDATA[15:8];
             wgt_fifo[wgt_count - 9 + 2] <= S_AXIS_TDATA[23:16];
             wgt_fifo[wgt_count - 9 + 3] <= S_AXIS_TDATA[31:24];
             wgt_count <= wgt_count - 5;
             compute_busy <= 1'b1; 
             pix_cnt <= 0; // 리셋
          end
          else if (do_load) begin
             for(i_seq=0; i_seq<9; i_seq=i_seq+1) active_kernel[i_seq] <= wgt_fifo[i_seq];
             for(i_seq=0; i_seq<55; i_seq=i_seq+1) wgt_fifo[i_seq] <= wgt_fifo[i_seq+9]; 
             wgt_count <= wgt_count - 9;
             compute_busy <= 1'b1;
             pix_cnt <= 0;
          end
          else if (do_receive) begin
             wgt_fifo[wgt_count]   <= S_AXIS_TDATA[7:0];
             wgt_fifo[wgt_count+1] <= S_AXIS_TDATA[15:8];
             wgt_fifo[wgt_count+2] <= S_AXIS_TDATA[23:16];
             wgt_fifo[wgt_count+3] <= S_AXIS_TDATA[31:24];
             wgt_count <= wgt_count + 4;
          end
          
          // Computer
          if (compute_busy) begin
             
             // acc_mem Update (Always 16-Way)
             if (ci_cnt != input_ch - 1) begin
                 for (p_seq = 0; p_seq < 4; p_seq = p_seq + 1) begin
                     if (pix_cnt + p_seq < total_pixels) begin
                         acc_mem[pix_cnt + p_seq] <= next_acc[p_seq];
                     end
                 end
             end

             // Next Pixel
             if (pix_cnt >= total_pixels - 4) begin
                 // Image Done
                 pix_cnt <= 0;
                 compute_busy <= 1'b0;
                 
                 if (ci_cnt == input_ch - 1) begin
                     ci_cnt <= 0;
                     co_cnt <= co_cnt + 1;
                     if (co_cnt + 1 >= output_ch) begin
                         state <= STATE_IDLE;
                         cal_done <= 1'b1; conv_done <= 1'b1;
                     end
                 end else begin
                     ci_cnt <= ci_cnt + 1;
                 end
             end else begin
                 pix_cnt <= pix_cnt + 4;
             end
          end 
        end

        // SEND RESULT
        STATE_SEND: begin
          // BRAM Read Latency Handling (1-Cycle Wait)
          if (!m_axis_tvalid) begin
              if (send_phase == 0) begin
                  // Wait 1 Cycle for BRAM Data
                  send_phase <= 1;
              end
              else begin
                  // Data Ready
                  m_axis_tdata_reg <= output_buf[bram_addr]; // Packed Data
                  m_axis_tvalid <= 1'b1;
                  if (sent_word_cnt == total_output_words - 1) m_axis_tlast <= 1'b1;
                  send_phase <= 0; 
              end
          end
          
          if (m_data_fire) begin
            m_axis_tvalid <= 1'b0; m_axis_tlast <= 1'b0;
            read_ptr <= read_ptr + 1; // Word 단위 증가
            sent_word_cnt <= sent_word_cnt + 1;
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