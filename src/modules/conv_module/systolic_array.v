/*
* systolic_array.v
* 4x4 Systolic Array with Input Skewing
* - Inputs: Aligned 4xWeight vectors, 4xFeature vectors
* - Internal: Skews inputs to form a diagonal wavefront
* - Outputs: 16 Partial Sums (32-bit each)
*/

module systolic_array 
  #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32,
    parameter ARRAY_SIZE = 4
  )
  (
    input wire clk,
    input wire rstn,
    
    // Control
    input wire start_clr,  // Start Signal (Will be skewed internally)
    
    // Inputs (Packed 1D arrays for easier I/O)
    // w_in[0] is Row 0, w_in[3] is Row 3
    input wire [ARRAY_SIZE*DATA_WIDTH-1:0] w_in, 
    
    // f_in[0] is Col 0, f_in[3] is Col 3
    input wire [ARRAY_SIZE*DATA_WIDTH-1:0] f_in, 
    
    // Outputs (Packed 1D array)
    // result[0] = PE(0,0), result[1] = PE(0,1), ..., result[15] = PE(3,3)
    output wire [ARRAY_SIZE*ARRAY_SIZE*ACC_WIDTH-1:0] pe_results
  );

  // Unpack Inputs
  wire signed [DATA_WIDTH-1:0] w_in_unpacked [0:ARRAY_SIZE-1];
  wire signed [DATA_WIDTH-1:0] f_in_unpacked [0:ARRAY_SIZE-1];
  
  genvar i, j;
  generate
    for (i = 0; i < ARRAY_SIZE; i = i + 1) begin : unpack
        assign w_in_unpacked[i] = w_in[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH];
        assign f_in_unpacked[i] = f_in[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH];
    end
  endgenerate


  // Input Skewing Logic (Shift Registers), Row i is delayed by i cycles, Col j is delayed by j cycles
  reg signed [DATA_WIDTH-1:0] w_skew_regs [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1]; // [Row][Delay]
  reg signed [DATA_WIDTH-1:0] f_skew_regs [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1]; // [Col][Delay]
  reg                         clr_skew_regs [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1]; // [Row][Delay]

  // Wires connecting to PE Array boundary
  wire signed [DATA_WIDTH-1:0] w_to_pe [0:ARRAY_SIZE-1];
  wire signed [DATA_WIDTH-1:0] f_to_pe [0:ARRAY_SIZE-1];
  wire                         clr_to_pe [0:ARRAY_SIZE-1];

  integer r, c, d;
  always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
          for(r=0; r<ARRAY_SIZE; r=r+1) begin
              for(d=0; d<ARRAY_SIZE; d=d+1) begin
                  w_skew_regs[r][d] <= 0;
                  f_skew_regs[r][d] <= 0;
                  clr_skew_regs[r][d] <= 0;
              end
          end
      end else begin
          // Shift register operation for each row/col
          for(r=0; r<ARRAY_SIZE; r=r+1) begin
              // First stage gets input
              w_skew_regs[r][0] <= w_in_unpacked[r];
              f_skew_regs[r][0] <= f_in_unpacked[r];
              clr_skew_regs[r][0] <= start_clr; // Clear signal follows Weight Rows

              // Subsequent stages shift
              for(d=1; d<ARRAY_SIZE; d=d+1) begin
                  w_skew_regs[r][d] <= w_skew_regs[r][d-1];
                  f_skew_regs[r][d] <= f_skew_regs[r][d-1];
                  clr_skew_regs[r][d] <= clr_skew_regs[r][d-1];
              end
          end
      end
  end

  // Assign skewed outputs to PE array inputs (Row 0 -> Delay 0, Row 1 -> Delay 1...)
  generate
      for (i = 0; i < ARRAY_SIZE; i = i + 1) begin : assign_skew
          assign w_to_pe[i]   = w_skew_regs[i][i];
          assign f_to_pe[i]   = f_skew_regs[i][i];
          assign clr_to_pe[i] = clr_skew_regs[i][i];
      end
  endgenerate


  // PE Array Instantiation & Connection
  
  // Wires between PEs
  // Horizontal connections: [Row][Col+1]
  wire signed [DATA_WIDTH-1:0] w_conn [0:ARRAY_SIZE-1][0:ARRAY_SIZE]; 
  wire clr_conn [0:ARRAY_SIZE-1][0:ARRAY_SIZE];
  
  // Vertical connections: [Row+1][Col]
  wire signed [DATA_WIDTH-1:0] f_conn [0:ARRAY_SIZE][0:ARRAY_SIZE-1];
  
  // Result wires
  wire signed [ACC_WIDTH-1:0]  res_conn [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];

  generate
    for (i = 0; i < ARRAY_SIZE; i = i + 1) begin : rows
        
        // Connect boundary inputs
        assign w_conn[i][0]   = w_to_pe[i];   // Left side input
        assign clr_conn[i][0] = clr_to_pe[i]; // Left side control
        assign f_conn[0][i]   = f_to_pe[i];   // Top side input

        for (j = 0; j < ARRAY_SIZE; j = j + 1) begin : cols  
            pe u_pe (
                .clk        (clk),
                .rstn       (rstn),
                
                // Control Flow (Left -> Right)
                .in_clr     (clr_conn[i][j]),
                .out_clr    (clr_conn[i][j+1]),
                
                // Weight Flow (Left -> Right)
                .in_weight  (w_conn[i][j]),
                .out_weight (w_conn[i][j+1]),
                
                // Feature Flow (Top -> Bottom)
                .in_feature (f_conn[i][j]),
                .out_feature(f_conn[i+1][j]),
                
                // Result
                .out_sum    (res_conn[i][j])
            );
            
            // Pack Result to Output Port
            assign pe_results[ ((i*ARRAY_SIZE + j) + 1)*ACC_WIDTH - 1 : (i*ARRAY_SIZE + j)*ACC_WIDTH ] = res_conn[i][j];
        end
    end
  endgenerate

endmodule