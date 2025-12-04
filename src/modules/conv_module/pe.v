/*
* pe.v
* Processing Element for Systolic Array
* - Performs MAC (Multiply-Accumulate) operation
* - Passes input data to the next PE (Right/Down)
* - Output Stationary: Accumulates result internally
* - Wavefront Propagation: Passes 'clr' to the right neighbor
*/

module pe 
  (
    input wire clk,
    input wire rstn,
    
    // Control (Flows Left -> Right)
    input wire in_clr,       // 내 리셋 신호 (왼쪽에서 옴)
    output reg out_clr,      // 오른쪽에게 줄 리셋 신호

    // Weight In (From Left) -> Out (To Right)
    input wire signed [7:0] in_weight,  
    output reg signed [7:0] out_weight,

    // Feature In (From Top) -> Out (To Bottom)
    input wire signed [7:0] in_feature,
    output reg signed [7:0] out_feature,
    
    // Result (Accumulator)
    output reg signed [31:0] out_sum
  );

  wire signed [15:0] mult_result;
  // Weight(Left) x Feature(Top)
  assign mult_result = in_weight * in_feature;

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      out_weight  <= 8'd0;
      out_feature <= 8'd0;
      out_sum     <= 32'd0;
      out_clr     <= 1'b0;
    end
    else begin
      // Data Passing (Shift)
      out_weight  <= in_weight;  // Left -> Right
      out_feature <= in_feature; // Top -> Bottom

      // Control Passing (Wavefront)
      out_clr <= in_clr;         // Left -> Right

      // MAC Operation
      if (in_clr) begin
          // 리셋 신호가 오면 기존 값 버리고 새로 시작 (Overwrite)
          out_sum <= {{16{mult_result[15]}}, mult_result}; 
      end
      else begin
          // 아니면 계속 누적 (Accumulate)
          out_sum <= out_sum + mult_result;
      end
    end
  end

endmodule