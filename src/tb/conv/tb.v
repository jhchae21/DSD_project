`timescale 1ns / 1ps


module tb;
     
    // system parameters
    parameter   CLK_PERIOD          = 2.5;              // 400MHz
    parameter   HALF_CLK_PERIODD    = CLK_PERIOD / 2;
    
    // addresses for vdma registers 
    parameter   S2MM_VDMACR_REG_ADDR        = 32'h00000030;
    parameter   S2MM_START_ADDRESS_REG_ADDR = 32'h000000AC;
    parameter   S2MM_FRMDLY_STRIDE_REG_ADDR = 32'h000000A8;
    parameter   S2MM_HSIZE_REG_ADDR         = 32'h000000A4;
    parameter   S2MM_VSIZE_REG_ADDR         = 32'h000000A0;
    
    parameter   MM2S_VDMACR_REG_ADDR        = 32'h00000000;
    parameter   MM2S_START_ADDRESS_REG_ADDR = 32'h0000005C;
    parameter   MM2S_FRMDLY_STRIDE_REG_ADDR = 32'h00000058;
    parameter   MM2S_HSIZE_REG_ADDR         = 32'h00000054;
    parameter   MM2S_VSIZE_REG_ADDR         = 32'h00000050;
    
    
   
    //** USER PARAMETERS **//
    
    parameter FeatureLength = 32'd8; // 입력 이미지 가로/세로 크기 (8x8)
    parameter InputCh = 32'd3; // 입력 채널 수(3, RGB)
    parameter OutputCh = 32'd8; // 출력 채널 수 (필터 개수 8개)
    
    parameter   FEATURE_BASE_ADDR   = 32'h0000_2000; // SRAM 내 입력 데이터 시작 주소
    parameter   FEATURE_STRIDE_SIZE = FeatureLength*FeatureLength*InputCh; // 입력 이미지 크기 (8*8*3 image)
    parameter   FEATURE_HSIZE       = FeatureLength*FeatureLength*InputCh; 
    parameter   FEATURE_VSIZE       = 32'd1;    
    parameter   BIAS_BASE_ADDR      = 32'h0000_5000; // SRAM 내 Bias 시작 주소
    parameter   BIAS_STRIDE_SIZE    = OutputCh;   // 채널당 1개 Bias(8개)
    parameter   BIAS_HSIZE          = OutputCh;
    parameter   BIAS_VSIZE          = 32'd1;        
    parameter   WEIGHT_BASE_ADDR    = 32'h0000_6000; // SRAM 내 Weight 시작 주소
    parameter   WEIGHT_STRIDE_SIZE  = InputCh*OutputCh*9; // 채널당 3(Input channel 개수)*8(Output channel 개수)*9(각 filter의 weight 3X3개)
    parameter   WEIGHT_HSIZE        = InputCh*OutputCh*9;
    parameter   WEIGHT_VSIZE        = 32'd1;        
    parameter   RESULT_BASE_ADDR    = 32'h0002_0000; // 결과 저장할 주소
    parameter   RESULT_STRIDE_SIZE  = FeatureLength*FeatureLength*OutputCh; // 결과 크기 8*8*8 = 512  
    parameter   RESULT_HSIZE        = FeatureLength*FeatureLength*OutputCh;   
    parameter   RESULT_VSIZE        = 32'd1; 
    
    
    //** USER PARAMETERS **//
    localparam integer  OP_SIZE         = 4;
    localparam integer  ADDR_SIZE       = 28;
    localparam integer  DATA_SIZE       = 32; 
    localparam integer  FEATURE_SIZE    = FEATURE_HSIZE*FEATURE_VSIZE/4; //txt 파일 한 줄에 32bit(4byte)이므로 담을 줄의 크기는 4로 나눈다.
    localparam integer  WEIGHT_SIZE     = WEIGHT_HSIZE*WEIGHT_VSIZE/4;
    localparam integer  BIAS_SIZE       = BIAS_HSIZE*BIAS_VSIZE/4;
    localparam integer  RESULT_SIZE     = RESULT_HSIZE*RESULT_VSIZE/4;
    
    
    //** USER ARRAYS **// 
    // bram write 
    reg [31:0] data_a_32bit [0:FEATURE_SIZE-1];        // data_a(Input.txt 32bit씩 담음)
    reg [31:0] data_b_32bit [0:WEIGHT_SIZE-1];         // data_b(Weight.txt)
    reg [31:0] data_c_32bit [0:BIAS_SIZE-1];           // data_c(Bias.txt)
    
    
    //** USER VARIABLES **//   
    // module_example
    reg [2:0]  COMMAND;    // IDLE : 3'b000  //    Feature receive, 3'b001  // Bias receive :   3'b010 // Calculation start  3'b011 // Data Transmit(결과 전송) 3'b100 //
    reg [8:0]  InCh;        // 모듈에 알려줄 Number of Input Channel -> Maximum : 256
    reg [8:0]  OutCh;       // 모듈에 알려줄 Number of Output Channel -> Maximum : 256
    reg [5:0]  FLength;    // Columb Size of Input Feature Map -> Maximum : 32

    wire F_writedone; // 모듈 -> TB Feature 저장 완료 신호
    wire B_writedone; // 모듈 -> TB Bias 저장 완료 신호
    wire rdy_to_transmit; // 모듈 -> TB 연산 완료 신호
    wire transmit_done; // 모듈 -> TB 결과 전송 완료 신호
    reg  F_writedone_respond;
    reg  B_writedone_respond;
    reg  rdy_to_transmit_respond;
    reg  transmit_done_respond;
    
    // system
    reg clk;
    reg resetn;
    
    // vdma_control
    reg        init_txn;
    reg [31:0] addr;
    reg [31:0] data;
    wire       txn_done;
    
    // axi_m_interface (for read)
    reg         init_read;
    reg [31:0]  r_addr;
    wire [31:0] r_data;
    wire        read_done;  
    
    // For result check
    integer     file;
    reg [31:0]  result_32bit;                           // output result
    reg [31:0]  result_expected_32bit[0:RESULT_SIZE-1]; // expected result
    reg [27:0]  addr_test;
    
    integer i;
    reg     compare_flag;


    // Clock
    initial clk = 1'b1;
    always #HALF_CLK_PERIODD clk = ~clk;
    
    // Test code
    initial begin
        resetn = 1'b0;
        init_txn = 1'b0;
        init_read = 1'b0;
        result_32bit = 0;
        compare_flag = 1'b1;
        
        
        COMMAND = 0;
        InCh = 0;
        OutCh = 0;
        FLength = 0;
        F_writedone_respond = 0;
        B_writedone_respond = 0;
        rdy_to_transmit_respond = 0;
        transmit_done_respond = 0;

        repeat (100)
        @(posedge clk);      

        resetn = 1'b1;   


        //** writing data to BRAM **//     
        repeat (500)
        @(posedge clk);
        $display("- Force write starts -");


        ////////////////////////////////////////////////////////////   INPUT FILES   ///////////////////////////////////////////////////////////
        ///////////////////////////////////  Change file names below if you want to use different input files  /////////////////////////////////
        $readmemb("conv_input_32bits_2s.txt", data_a_32bit);
        $readmemb("conv_weight_32bits_2s.txt", data_b_32bit);
        $readmemb("conv_bias_32bits_2s.txt", data_c_32bit);


        // writing flat.txt
        for (i = 0; i < FEATURE_SIZE; i = i + 1) begin
          force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.ADDRA = (FEATURE_BASE_ADDR + i*4)/4; 
          force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.ENA = 1'b1;
          force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.WEA = 4'b1111;
          @(posedge tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.CLKA);
          //            force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.DINA = data_a_32bit[i];      // non-UART version
          force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.DINA = {data_a_32bit[i][7:0],data_a_32bit[i][15:8],data_a_32bit[i][23:16],data_a_32bit[i][31:24]};   // UART version - big to little

          @(posedge tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.CLKA);
        end 

        // writing fc_b.txt  
        for (i = 0; i < WEIGHT_SIZE; i = i + 1) begin            
          force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.ADDRA = (WEIGHT_BASE_ADDR + i*4)/4; 
          force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.ENA = 1'b1;
          force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.WEA = 4'b1111;
          @(posedge tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.CLKA);
          //            force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.DINA = data_b_32bit[i];      // non-UART version    
          force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.DINA = {data_b_32bit[i][7:0],data_b_32bit[i][15:8],data_b_32bit[i][23:16],data_b_32bit[i][31:24]};   // UART version - big to little                                                  

          @(posedge tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.CLKA);
        end 

        // writing flat.txt  
        for (i = 0; i < BIAS_SIZE; i = i + 1) begin
          force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.ADDRA = (BIAS_BASE_ADDR + i*4)/4;
          force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.ENA = 1'b1;
          force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.WEA = 4'b1111;
          @(posedge tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.CLKA);
          //             force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.DINA = data_b_32bit[i];     // non-UART version    
          force tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.DINA = {data_c_32bit[i][7:0],data_c_32bit[i][15:8],data_c_32bit[i][23:16],data_c_32bit[i][31:24]};  // UART version - big to little

          @(posedge tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.CLKA);
        end

        release tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.ADDRA;
        release tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.ENA;
        release tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.WEA;
        release tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.DINA;
        @(posedge tb.u_top_simulation.u_sram_32x131072.inst.axi_mem_module.blk_mem_gen_v8_4_9_inst.CLKA);

        $display("- Force write is done -\n\n");


        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
        ////////////////////////////////////////////////////////   VDMA control starts   ///////////////////////////////////////////////////////  
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////      
        ////////////////////// You should change the code below if you want to change the size of data that is transmitted /////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

        $display("- VDMA control starts -\n");
        # CLK_PERIOD;

        // S2MM //
        // write result (from FC to memory)
        write_data(S2MM_VDMACR_REG_ADDR, 32'h00010091);                 // control
        write_data(S2MM_START_ADDRESS_REG_ADDR, RESULT_BASE_ADDR);      // start address
        write_data(S2MM_FRMDLY_STRIDE_REG_ADDR, RESULT_STRIDE_SIZE);    // stride
        write_data(S2MM_HSIZE_REG_ADDR, RESULT_HSIZE);                  // hsize (= line size) (Bytes)
        write_data(S2MM_VSIZE_REG_ADDR, RESULT_VSIZE);                  // the number of lines
        $display("VDMA is ready to receive result from FC\n");

        InCh = InputCh; // 모듈에 크기 정보 전달
        OutCh = OutputCh;
        FLength = FeatureLength;

        // MM2S //
        // feature read (from memory to FC) 
        $display("VDMA transmits feature to FC"); // VDMA 켠다
        write_data(MM2S_VDMACR_REG_ADDR, 32'h00010091);                 // control
        write_data(MM2S_START_ADDRESS_REG_ADDR, FEATURE_BASE_ADDR);     // start address
        write_data(MM2S_FRMDLY_STRIDE_REG_ADDR, FEATURE_STRIDE_SIZE);   // stride
        write_data(MM2S_HSIZE_REG_ADDR, FEATURE_HSIZE);                 // hsize (= line size) (Bytes)
        write_data(MM2S_VSIZE_REG_ADDR, FEATURE_VSIZE);                 // the number of lines 

        repeat(100)
        @(posedge clk);

        COMMAND = 1; // 모듈에게 feature data 받으라 명령

        // sending control signals to FC
        $display("CONV starts to read feature");
        wait(F_writedone); // 모듈이 다 받았다고 전달할 때까지 대기
        $display("CONV finishes to read feature\n");
        F_writedone_respond = 1; // tb -> 모듈 핸드셰이크 응답

        repeat(100)                                                     //** Please do not remove this. **//
        @(posedge clk);                                             //** VDMA needs enough time interval between transmissions of the same direction. (this case: MM2S & MM2S) **//

        // MM2S //
        // bias read (from memory to FC) 
        $display("VDMA transmits bias to FC");
        write_data(MM2S_VDMACR_REG_ADDR, 32'h00010091);               // control     
        write_data(MM2S_START_ADDRESS_REG_ADDR, BIAS_BASE_ADDR);       // start address 
        write_data(MM2S_FRMDLY_STRIDE_REG_ADDR, BIAS_STRIDE_SIZE);      // stride 
        write_data(MM2S_HSIZE_REG_ADDR, BIAS_HSIZE);                    // hsize (= line size) (Bytes) 
        write_data(MM2S_VSIZE_REG_ADDR, BIAS_VSIZE);                    // the number of lines 

        repeat(100)
        @(posedge clk);

        COMMAND = 2; // 모듈에게 Bias 데이터 받으라 명령

        // sending control signals to FC
        $display("CONV starts to read bias");
        wait(B_writedone); // 모듈이 다 받았다고 할때까지 대기
        $display("CONV finishes to read bias\n");
        B_writedone_respond = 1;

        repeat(100)                                                     //** Please do not remove this. **//
        @(posedge clk);                                             //** VDMA needs enough time interval between transmissions of the same direction. (this case: MM2S & MM2S) **//

        // MM2S //
        // weight read (from memory to FC) 
        $display("VDMA transmits weight to FC"); //  모듈에게 Weight 전달
        write_data(MM2S_VDMACR_REG_ADDR, 32'h00010091);                 // control     
        write_data(MM2S_START_ADDRESS_REG_ADDR, WEIGHT_BASE_ADDR);      // start address
        write_data(MM2S_FRMDLY_STRIDE_REG_ADDR, WEIGHT_STRIDE_SIZE);    // stride
        write_data(MM2S_HSIZE_REG_ADDR, WEIGHT_HSIZE);                  // hsize (= line size) (Bytes)
        write_data(MM2S_VSIZE_REG_ADDR, WEIGHT_VSIZE);                  // the number of lines

        repeat(100)
        @(posedge clk);   

        COMMAND = 3; // 모듈에게 weight 저장 후 연산 시작 명령

        // sending control signals to FC
        $display("CONV starts to calculate");
        wait(rdy_to_transmit); // 모듈에게 연산 수행 후 결과 output buffer에 저장 명령
        $display("CONV finishes to calculate\n");
        rdy_to_transmit_respond = 1;

        repeat(100)
        @(posedge clk);                 

        COMMAND = 4; // output buffer 값 전달 명령
        $display("CONV starts to send result");
        wait(transmit_done);
        $display("CONV finishes to send result\n");
        transmit_done_respond = 1;    

        COMMAND = 0;

        repeat(100)
        @(posedge clk);   

        write_data(MM2S_VDMACR_REG_ADDR, 32'h00010094);             // vdma reset to flush vdma

        repeat(100)
        @(posedge clk);   


        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
        //////////////////////////////////////////////////////  VDMA control is finished  //////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

        // comparing results
        $display("- Comparing result starts -\n");

        ////////////////////////////////////////////////////////////   RESULT FILE   ///////////////////////////////////////////////////////////
        ///////////////////////////////////  Change file name below if you want to use different result file  //////////////////////////////////        
        import_result_nowrite("conv_output_32bits_2s.txt");          

        addr_test = RESULT_BASE_ADDR;

        for (i = 0; i < RESULT_SIZE; i = i + 1) begin
          read_data (addr_test+i*4, result_32bit);

          $display("Index: %d", i);

          if (result_32bit != {result_expected_32bit[i][7:0], result_expected_32bit[i][15:8], result_expected_32bit[i][23:16],result_expected_32bit[i][31:24]}) begin
            $display("\nResult is different!");
            $display("Expected value: %h", {result_expected_32bit[i][7:0], result_expected_32bit[i][15:8], result_expected_32bit[i][23:16],result_expected_32bit[i][31:24]});
            $display("Output value: %h\n", result_32bit);

            compare_flag = 1'b0;
          end
        end

        if (compare_flag) begin
          $display("\nResult is correct!\n");
        end

        $display("- Comparing result is done!! -\n");
        $finish;
      end



      //-----------------------
      //******** Task ********
      //-----------------------

      task write_data (input [31:0] i_addr, input [31:0] i_data);
        begin   
        addr = i_addr;
        data = i_data;

        init_txn = 1'b1;

        # CLK_PERIOD 
        init_txn = 1'b0;

        wait(txn_done);
        # CLK_PERIOD;
      end
    endtask


    task read_data (input [31:0] i_addr, output reg [31:0] o_data);
      begin
        r_addr = i_addr;

        init_read = 1'b1;

        # CLK_PERIOD 
        init_read = 1'b0;

        wait(read_done);
        # CLK_PERIOD;      

        o_data = r_data;      
      end
    endtask

    task import_result_nowrite(input [128 * 8:0] file_name);
      begin
        file = 0;  
        file = $fopen(file_name,"rb");

        if (!file) begin
          $display("read: Open Error!\n");
          $finish;
        end

        $display("input file : %s\n", file_name);

        $readmemb(file_name, result_expected_32bit);

        $display("import result(no write) is done. \n");

        $fclose(file);
      end
    endtask



    //-----------------------
    //**** Instantiation ****
    //-----------------------

    top_simulation u_top_simulation
    (
      .clk(clk),
      .resetn(resetn),
      .init_txn(init_txn),
      .i_addr(addr),
      .i_data(data),
      .txn_done(txn_done),
      .init_read(init_read),
      .r_addr(r_addr),
      .r_data(r_data),
      .read_done(read_done),


      //** USER PORTS **//
      .F_writedone(F_writedone), 
      .B_writedone(B_writedone), 
      .rdy_to_transmit(rdy_to_transmit), 
      .transmit_done(transmit_done), 
      .COMMAND(COMMAND), 
      .InCh(InCh), 
      .OutCh(OutCh), 
      .FLength(FLength), 
      .F_writedone_respond(F_writedone_respond), 
      .B_writedone_respond(B_writedone_respond), 
      .rdy_to_transmit_respond(rdy_to_transmit_respond), 
      .transmit_done_respond(transmit_done_respond)
    );

endmodule