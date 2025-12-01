/*
* conv_apb.v
*/

module conv_apb 
  (
    input wire PCLK,           // APB clock
    input wire PRESETB,        // APB asynchronous reset (0: reset, 1: normal)
    input wire [31:0] PADDR,   // APB address
    input wire PSEL,           // APB select
    input wire PENABLE,        // APB enable
    input wire PWRITE,         // APB write enable
    input wire [31:0] PWDATA,  // APB write data
    output wire [31:0] PRDATA,

    input wire [31:0] clk_counter, // 실행 시간 측정용 카운터
    input wire [0:0] conv_done,    // 모듈이 다 끝났다고 보내는 신호
    output reg [0:0] conv_start,   // 모듈에게 시작하라고 보내는 신호

    //////////////////////////////////////////////////////////////////////////
    // TODO : Add ports if you need them
    //////////////////////////////////////////////////////////////////////////
    // PC -> FPGA
    output reg [2:0] command,         // 1:Feature, 2:Bias, 3:Weight, 4:Send
    output reg [8:0] input_ch,        // 입력 채널 수
    output reg [8:0] output_ch,       // 출력 채널 수
    output reg [5:0] feature_length,  // 이미지 크기
    
    // FPGA -> PC
    input wire f_writedone,   // Feature 저장 완료
    input wire b_writedone,   // Bias 저장 완료
    input wire cal_done_stat, // 계산 완료
    input wire transmit_done  // 전송 완료
  );
  
  wire state_enable;
  wire state_enable_pre;
  reg [31:0] prdata_reg;
  
  assign state_enable = PSEL & PENABLE;
  assign state_enable_pre = PSEL & ~PENABLE;

  //////////////////////////////////////////////////////////////////////////
  // TODO : Write your code here
  //////////////////////////////////////////////////////////////////////////
  
  // READ OUTPUT (PC로 특정 주소에 대한 데이터 전달)
  always @(posedge PCLK, negedge PRESETB) begin
    if (PRESETB == 1'b0) begin
      prdata_reg <= 32'h00000000;
    end
    else begin
      if (~PWRITE & state_enable_pre) begin // 읽기 모드
        case ({PADDR[31:2], 2'h0}) // 주소 (4byte 정렬)
          /*READOUT*/
          32'h00000000 : prdata_reg <= {31'h0,conv_start};
          32'h00000004 : prdata_reg <= {31'd0,conv_done};
          32'h00000008 : prdata_reg <= clk_counter; //Do not fix!
          32'h00000010 : prdata_reg <= {31'd0, f_writedone};
          32'h00000014 : prdata_reg <= {31'd0, b_writedone};
          32'h00000018 : prdata_reg <= {31'd0, cal_done_stat};
          32'h0000001C : prdata_reg <= {31'd0, transmit_done};
          default: prdata_reg <= 32'h0;
        endcase
      end
      else begin
        prdata_reg <= 32'h0;
      end
    end
  end
  
  assign PRDATA = (~PWRITE & state_enable) ? prdata_reg : 32'h00000000;
  
  // WRITE ACCESS (PC에서 전달받은 값 특정 주소에 대해 특정 port에 쓰기)
  always @(posedge PCLK, negedge PRESETB) begin
    if (PRESETB == 1'b0) begin
      /*WRITERES*/
      conv_start <= 1'b0;
      command <= 3'd0;
      input_ch <= 9'd0;
      output_ch <= 9'd0;
      feature_length <= 6'd0;
    end
    else begin
      if (PWRITE & state_enable) begin
        case ({PADDR[31:2], 2'h0})
          /*WRITEIN*/
          3_2'h00000000 : begin
            conv_start <= PWDATA[0]; // PWDATA는 pc에서 전달받은 값
          end
          32'h00000020 : begin
            command <= PWDATA[2:0];
          end
          32'h00000024 : begin
            input_ch <= PWDATA[8:0];
          end
          32'h00000028 : begin
            output_ch <= PWDATA[8:0];
          end
          32'h0000002C : begin
            feature_length <= PWDATA[5:0];
          end
          default: ;
        endcase
      end
    end
  end

endmodule
