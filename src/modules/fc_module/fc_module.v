/*
* fc_module.v
*/

module fc_module 
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

    input fc_start, 
    output reg fc_done,
    //////////////////////////////////////////////////////////////////////////
    // TODO : Add ports as you need
    //////////////////////////////////////////////////////////////////////////
    input wire [2:0] COMMAND,
    input wire [31:0] num_input_words,  // FC1: 256, FC2: 64, FC3: 16
    input wire [31:0] num_output_words, // FC1: 64,  FC2: 16, FC3: 3

    output reg F_writedone,
    output reg B_writedone,
    output reg [31:0] max_index,
    output reg cal_done
  ); 

  //reg m_axis_tuser;
  wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata;
  //reg [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] m_axis_tkeep;
  reg m_axis_tlast;
  reg m_axis_tvalid;
  wire s_axis_tready;
  
  assign S_AXIS_TREADY = s_axis_tready;
  assign M_AXIS_TDATA = m_axis_tdata;
  assign M_AXIS_TLAST = m_axis_tlast;
  assign M_AXIS_TVALID = m_axis_tvalid;
  assign M_AXIS_TUSER = 1'b0;
  assign M_AXIS_TKEEP = {(C_S00_AXIS_TDATA_WIDTH/8) {1'b1}};

  ////////////////////////////////////////////////////////////////////////////
  // TODO : Write your code here
  ////////////////////////////////////////////////////////////////////////////
  // -------------------------------------------------------------------------
  // 1. Parameter & Memory Definitions (32-bit words 기준)
  // -------------------------------------------------------------------------
  // Testbench Parameter
  // 1 word = 4 Bytes = 32 bits
  // *** MODIFIED: Increased sizes to support FC1 (Max Input 256 words, Max Output 64 words) ***
  localparam FEATURE_WORD_LEN  = 256; // fc1: 256, fc2: 64, fc3: 16
  localparam BIAS_WORD_LEN     = 64;  // fc1: 64,  fc2: 16, fc3: 3 (10 bytes)
  localparam RESULT_WORD_LEN   = 64;  // fc1: 64,  fc2: 16, fc3: 3 (10 bytes)

  // localparam FEATURE_WORD_LEN  = 64;  
  // localparam BIAS_WORD_LEN     = 16;  
  // localparam RESULT_WORD_LEN   = 16; 
  
  // Fixed-Point Scaling Factor (Q11.12 -> Q1.6: Shift Right 6)
  localparam SCALE_SHIFT = 6;
  
  // Buffer Memory (BRAM)
  reg [31:0]        buf_feature [0:FEATURE_WORD_LEN-1]; 
  reg signed [31:0] buf_bias   [0:RESULT_WORD_LEN-1]; 
  reg [31:0]        buf_result [0:RESULT_WORD_LEN-1]; 

  // Length Counters & Indices
  reg [31:0] input_len;  // 32bit word 기준으로
  reg [31:0] output_len; 
  reg [31:0] idx;        
  reg [31:0]  k_idx;      // Feature Word Index (0 to 63)
  reg [31:0]  neuron_idx; // Current Neuron Index (0 to 63), neuron 단위는 1 Byte
  reg [31:0]  result_idx; // Output Word Index (0 to 15)

  reg signed [31:0] current_max_val; // 현재까지의 최대값 (비교용)
  reg [31:0]        max_idx_reg;     // 현재 최대값의 인덱스

  always @(*) max_index = max_idx_reg;
  
  // AXI Control Signals (Internal Registers)
  reg s_ready_reg;
  
  // Slave Ready Signal
  assign S_AXIS_TREADY = s_ready_reg;

  // -------------------------------------------------------------------------
  // 2. Datapath: SIMD DSP Logic (Fixed-Point Q1.6 x Q1.6 Accumulation)
  // -------------------------------------------------------------------------
  // Accumulator: Q11.12 (64-bit for safety margin)
  reg signed [63:0] acc;         

  // Combinational Logic으로 계산할 Wire들 (Blocking 할당 제거용)
  wire signed [63:0] next_acc;      // 다음 사이클에 acc에 들어갈 값
  wire signed [31:0] scaled_val;    // Scaling 결과
  wire signed [31:0] biased_val;    // Bias 더한 값
  wire signed [31:0] final_val;     // ReLU & Saturation 적용된 최종 값 

  // Wires for splitting 32-bit data into 4x 8-bit signed values
  wire signed [7:0] w0, w1, w2, w3; 
  wire signed [7:0] f0, f1, f2, f3; 
  wire [31:0] current_feat_word;    

  // Data Unpacking (Q1.6 to 32-bit signed value for calculation)
  // 매핑 방식 유지: w0/f0 gets the 7:0 byte (LSB)
  assign w0 = $signed(S_AXIS_TDATA[7:0]);   
  assign w1 = $signed(S_AXIS_TDATA[15:8]);
  assign w2 = $signed(S_AXIS_TDATA[23:16]);
  assign w3 = $signed(S_AXIS_TDATA[31:24]); 
  
  assign current_feat_word = buf_feature[k_idx];
  assign f0 = $signed(current_feat_word[7:0]); 
  assign f1 = $signed(current_feat_word[15:8]);
  assign f2 = $signed(current_feat_word[23:16]);
  assign f3 = $signed(current_feat_word[31:24]); 

  // Signed 8-bit to Signed 64-bit multiplication (Q1.6 * Q1.6 = Q2.12)
  wire signed [63:0] term0 = $signed(w0) * $signed(f0);
  wire signed [63:0] term1 = $signed(w1) * $signed(f1);
  wire signed [63:0] term2 = $signed(w2) * $signed(f2);
  wire signed [63:0] term3 = $signed(w3) * $signed(f3);
  
  // MAC Result (Q11.12 format contribution)
  wire signed [63:0] mac_result_64 = term0 + term1 + term2 + term3;

  // Combinational Logic Chains
  assign next_acc = acc + mac_result_64;
  assign scaled_val = (next_acc >>> SCALE_SHIFT); // Shift Right 6

  wire [1:0] bias_byte_pos;
  wire [7:0] current_bias_q1_6;
  wire signed [31:0] signed_bias_32;
  
  
  // Combinatorial Bias Extraction Logic (Must be outside the sequential block)
  assign bias_byte_pos = neuron_idx[1:0];  // 0,1,2,3 for byte positions in a 4byte word
  assign current_bias_q1_6 = buf_bias[result_idx] >> (8 * bias_byte_pos);
  // sign-extended 32bit bias
  assign signed_bias_32 = $signed({ {24{current_bias_q1_6[7]}}, current_bias_q1_6 }); 

  // Bias Add & ReLU & Saturation Logic (Combinational)
  assign biased_val = scaled_val + signed_bias_32;
  assign final_val = (biased_val < 0)   ? 32'd0   : // ReLU
                     (biased_val > 127) ? 32'd127 : // Saturation
                     biased_val;                    // Pass-through


  // -------------------------------------------------------------------------
  // 3. FSM (Finite State Machine)
  // -------------------------------------------------------------------------
  localparam S_IDLE       = 3'd0; 
  localparam S_LOAD_FEAT  = 3'd1; 
  localparam S_LOAD_BIAS  = 3'd2; 
  localparam S_CALC_W     = 3'd3; 
  localparam S_SEND_RES   = 3'd4; 
  localparam S_WAIT_CMD   = 3'd5; 
  
  reg [2:0] state;
  reg [2:0] prev_command; 

  // Combinatorial assign for M_AXIS_TDATA (since m_axis_tdata is a wire)
  assign m_axis_tdata = (state == S_SEND_RES) ? buf_result[result_idx] : 32'h00000000;
  
  


  // State Transition Logic
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      // Reset
      state             <= S_IDLE;
      s_ready_reg       <= 0;
      m_axis_tvalid     <= 0; 
      m_axis_tlast      <= 0; 
      
      F_writedone       <= 0;
      B_writedone       <= 0;
      cal_done          <= 0;
      fc_done           <= 0;
      
      idx               <= 0;
      k_idx             <= 0;
      neuron_idx        <= 0;
      result_idx        <= 0;
      acc               <= 0;
      input_len         <= 0;
      output_len        <= 0;
      prev_command      <= 3'b000;

      current_max_val <= 32'h80000000; // 가장 작은 음수로 초기화
      max_idx_reg <= 0;
    end 
    else begin
      // AXI Master Handshake Clear
      if (m_axis_tvalid && M_AXIS_TREADY) begin
        m_axis_tvalid <= 0;
        m_axis_tlast  <= 0;
      end

      case (state)
        // ===================================================================
        // IDLE STATE
        // ===================================================================
        S_IDLE: begin
          s_ready_reg       <= 0;
          m_axis_tvalid     <= 0; 
          m_axis_tlast      <= 0; 
          
          F_writedone       <= 0;
          B_writedone       <= 0;
          cal_done          <= 0;
          fc_done           <= 0;

          if (fc_start) begin
            prev_command <= COMMAND;
            current_max_val <= 32'h80000000; // 최소값 (signed min)
            max_idx_reg <= 0;
            case (COMMAND)
              3'b001: begin // LOAD_FEAT
                state             <= S_LOAD_FEAT;
                s_ready_reg       <= 1; 
                idx               <= 0;
              end
              3'b010: begin // LOAD_BIAS
                state             <= S_LOAD_BIAS;
                s_ready_reg       <= 1; 
                idx               <= 0;
              end
              3'b100: begin // CALC_WEIGHT
                state             <= S_CALC_W;
                s_ready_reg       <= 1; 
                k_idx             <= 0; 
                neuron_idx        <= 0; 
                result_idx        <= 0; 
                acc               <= 0;
              end
              3'b101: begin // SEND_RESULT
                state             <= S_SEND_RES;
                result_idx        <= 0; // Send starts from result word 0
              end
              default: state <= S_IDLE;
            endcase
          end
        end

        // ===================================================================
        // 1. LOAD FEATURE
        // ===================================================================
        S_LOAD_FEAT: begin
          if (S_AXIS_TVALID && s_ready_reg) begin
            buf_feature[idx] <= S_AXIS_TDATA; 
            idx <= idx + 1;
            
            if (S_AXIS_TLAST || idx == num_input_words - 1) begin
              input_len     <= idx + 1;
              s_ready_reg   <= 0; 
              F_writedone   <= 1; 
              state         <= S_WAIT_CMD;
            end
          end
        end

        // ===================================================================
        // 2. LOAD BIAS
        // ===================================================================
        S_LOAD_BIAS: begin
          if (S_AXIS_TVALID && s_ready_reg) begin
            buf_bias[idx] <= $signed(S_AXIS_TDATA); 
            idx <= idx + 1;
            
            if (S_AXIS_TLAST || idx == num_output_words - 1) begin
              output_len    <= idx + 1;
              s_ready_reg   <= 0; 
              B_writedone   <= 1; 
              state         <= S_WAIT_CMD;
            end
          end
        end

        // ===================================================================
        // 3. CALC WEIGHT
        // ===================================================================
        S_CALC_W: begin
          if (S_AXIS_TVALID && s_ready_reg) begin
            acc   <= next_acc;
            k_idx <= k_idx + 1; 

            // Check if one NEURON's(1 output byte) calculation is finished (k_idx == 63)
            if (k_idx == num_input_words - 1) begin
              // --- max index update logic ---: fc3에서만 유효
              if (neuron_idx == 0) begin
                current_max_val <= final_val;
                max_idx_reg <= 0;
              end 
              else if (final_val > current_max_val) begin
                current_max_val <= final_val;
                max_idx_reg <= neuron_idx; // 현재 output byte index (aka neuron_idx) 저장
              end
              
              // Use pre-calculated wire 'final_val' (ReLU/Saturate included)
              // --- 4. Pack into buf_result (4 results per word) ---
              case (neuron_idx % 4)
                // 0: buf_result[result_idx][7:0]   <= final_val[7:0]; 
                0: buf_result[result_idx]        <= {24'd0, final_val[7:0]}; // zero padding
                1: buf_result[result_idx][15:8]  <= final_val[7:0]; 
                2: buf_result[result_idx][23:16] <= final_val[7:0]; 
                3: begin
                  buf_result[result_idx][31:24] <= final_val[7:0]; 
                  result_idx                    <= result_idx + 1; 
                end
              endcase

              // 5. Reset and Advance
              acc        <= 0;
              k_idx      <= 0; 
              neuron_idx <= neuron_idx + 1; 
            end
            
            // Check if all weights are processed
            if (S_AXIS_TLAST) begin
              s_ready_reg   <= 0; 
              cal_done      <= 1; 
              state         <= S_WAIT_CMD;
            end
          end
        end

        // ===================================================================
        // 4. SEND RESULT
        // ===================================================================
          // // Combinatorial assign for M_AXIS_TDATA (since m_axis_tdata is a wire)
          // assign m_axis_tdata = (state == S_SEND_RES) ? buf_result[result_idx] : 32'h00000000;
          
        S_SEND_RES: begin
          // Master Valid High을 시도 
          if (!m_axis_tvalid || (M_AXIS_TREADY && m_axis_tvalid)) begin
            m_axis_tvalid <= 1;

            // Advance Index on Handshake
            if (M_AXIS_TREADY && m_axis_tvalid) begin
              if (result_idx == num_output_words - 1) begin
                m_axis_tvalid <= 0;
                m_axis_tlast  <= 0;
                fc_done     <= 1; 
                state       <= S_WAIT_CMD;
              end 
              else if (result_idx == num_output_words - 2) begin
                result_idx <= result_idx + 1;
                m_axis_tlast  <= 1;
              end
              else begin
                result_idx <= result_idx + 1;
              end
            end 
          end
        end
        
        // ===================================================================
        // WAIT_CMD STATE
        // ===================================================================
        S_WAIT_CMD: begin
          if (fc_start == 1'b0) begin
            state <= S_IDLE;
            input_len         <= 0;
            output_len        <= 0;
            prev_command      <= 3'b000;
          end
          // while COMMAND == prev_command, stay in WAIT_CMD
          else if (COMMAND != prev_command) begin 
             prev_command <= COMMAND; 
             
             case (COMMAND)
               3'b001: begin 
                  state <= S_LOAD_FEAT;
                  s_ready_reg <= 1; 
                  idx <= 0; 
                  F_writedone <= 0; 
                end
               3'b010: begin 
                  state <= S_LOAD_BIAS;
                  s_ready_reg <= 1; 
                  idx <= 0; 
                  B_writedone <= 0; 
                end
               3'b100: begin 
                  state <= S_CALC_W;
                  s_ready_reg <= 1; 
                  k_idx <= 0; 
                  neuron_idx <= 0; 
                  result_idx <= 0; 
                  acc <= 0; 
                  cal_done <= 0;
                end
               3'b101: begin 
                  state <= S_SEND_RES;
                  result_idx <= 0; 
                  fc_done <= 0; 
                end
               default: state <= S_IDLE;
             endcase
          end
        end
        
        default: state <= S_IDLE;
      endcase
    end
  end
  
endmodule