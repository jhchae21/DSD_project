/*
* fc_apb.v
*/

module fc_apb
  (
    input wire PCLK,
    input wire PRESETB,        // APB asynchronous reset (0: reset, 1: normal)
    input wire [31:0] PADDR,   // APB address
    input wire PSEL,           // APB select
    input wire PENABLE,        // APB enable
    input wire PWRITE,         // APB write enable
    input wire [31:0] PWDATA,  // APB write data
    output wire [31:0] PRDATA,  // CPU interface out

    input wire [31:0] clk_counter,
    input wire [31:0] max_index,
    input wire [0:0] fc_done,
    output reg [0:0] fc_start,

    //////////////////////////////////////////////////////////////////////////
    // TODO : Add ports as you need
    //////////////////////////////////////////////////////////////////////////
    output reg [2:0] COMMAND,      // fc_module에 내릴 세부 명령 (Load, Calc 등)
    input wire F_writedone,        // Feature Load 완료 여부 (디버깅용)
    input wire B_writedone,        // Bias Load 완료 여부 (디버깅용)
    input wire cal_done,           // 연산 완료 여부 (디버깅용)
    
    // 가변 크기 설정을 위한 레지스터 출력
    output reg [31:0] num_input_words,  // 입력 데이터 길이 (Word 단위)
    output reg [31:0] num_output_words  // 출력 데이터 길이 (Word 단위)
  );

  wire state_enable;
  wire state_enable_pre;
  reg [31:0] prdata_reg;
  
  // state_enable: 실제 데이터 전송이 일어나는 시점 (Enable 단계)
  assign state_enable = PSEL & PENABLE;
  // state_enable_pre: Enable 직전 Setup 단계 (주소 해석용)
  assign state_enable_pre = PSEL & ~PENABLE;
  
  ////////////////////////////////////////////////////////////////////////////
  // TODO : Write your code here
  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  // READ ACCESS (CPU가 FPGA의 상태를 읽을 때)
  ////////////////////////////////////////////////////////////////////////////
  always @(posedge PCLK, negedge PRESETB) begin
    if (PRESETB == 1'b0) begin
      prdata_reg <= 32'h00000000; // 리셋 시 읽기 데이터 초기화
    end
    else begin
      if (~PWRITE & state_enable_pre) begin
        // 주소(PADDR)에 따라 어떤 값을 CPU에게 보여줄지 결정
        case ({PADDR[31:2], 2'h0})
          /* READOUT */
          // 0x00: 현재 시작 상태와 명령어를 확인
          32'h00000000 : prdata_reg <= {28'd0, fc_start, COMMAND};
          
          // 0x04: 디버깅용 진행 상황 플래그 확인
          32'h00000004 : prdata_reg <= {29'd0, cal_done, B_writedone, F_writedone};

          // 0x08: 성능 측정용 클럭 카운터 (수정 금지)
          32'h00000008 : prdata_reg <= clk_counter;
          
          // 0x0C: 작업 완료 신호 (fc_done)
          32'h0000000c : prdata_reg <= {31'd0, fc_done};
          
          // 0x10: 최종 추론 결과 (Max Index)
          32'h00000010 : prdata_reg <= max_index;
          
          // [NEW] 0x14: 현재 설정된 입력 데이터 길이 확인
          32'h00000014 : prdata_reg <= num_input_words;
          
          // [NEW] 0x18: 현재 설정된 출력 데이터 길이 확인
          32'h00000018 : prdata_reg <= num_output_words;
          
          default: prdata_reg <= 32'h0;
        endcase
      end
      else begin
        prdata_reg <= 32'h0;
      end
    end
  end
  
  assign PRDATA = (~PWRITE & state_enable) ? prdata_reg : 32'h00000000;
  
  ////////////////////////////////////////////////////////////////////////////
  // WRITE ACCESS (CPU가 FPGA에 명령/설정을 내릴 때)
  ////////////////////////////////////////////////////////////////////////////
  always @(posedge PCLK, negedge PRESETB) begin
    if (PRESETB == 1'b0) begin
      fc_start <= 1'b0;
      COMMAND  <= 3'b000;
      num_input_words  <= 32'd256; 
      num_output_words <= 32'd64;
    end
    else begin
      // 1. CPU가 APB를 통해 값을 쓸 때
      if (PWRITE & state_enable) begin
        case ({PADDR[31:2], 2'h0})
          /* WRITEIN */
          // 0x00: 명령 레지스터 (Start 및 Command 설정)
          32'h00000000 : begin
            // 하위 3비트를 명령어로 저장 (Load, Calc, Send 등)
            COMMAND <= PWDATA[2:0];
            
            // 0이 아닌 값(유효한 명령)이 들어오면 시작 신호(Start)를 켬
            if(PWDATA[2:0] != 3'b000) begin
              fc_start <= 1'b1;
            end 
            else begin
              // 0을 입력하면 강제 정지
              fc_start <= 1'b0;
            end
          end
          
          // 0x04: (예약됨 - 보통 디버그 상태 읽기 전용이므로 비워둠)
          32'h00000004 : begin
          end
          
          // [NEW] 0x14: 입력 데이터 길이 설정 (FC1=256, FC2=64, FC3=16)
          32'h00000014 : begin
             num_input_words <= PWDATA;
          end
          
          // [NEW] 0x18: 출력 데이터 길이 설정 (FC1=64, FC2=16, FC3=4)
          32'h00000018 : begin
             num_output_words <= PWDATA;
          end
          
          default: ;
        endcase
      end
    end
  end
endmodule
  
