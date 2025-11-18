// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// -------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

(* BLOCK_STUB = "true" *)
module axi_vdma_0 (
  s_axi_lite_aclk,
  m_axi_mm2s_aclk,
  m_axis_mm2s_aclk,
  m_axi_s2mm_aclk,
  s_axis_s2mm_aclk,
  axi_resetn,
  s_axi_lite_awvalid,
  s_axi_lite_awready,
  s_axi_lite_awaddr,
  s_axi_lite_wvalid,
  s_axi_lite_wready,
  s_axi_lite_wdata,
  s_axi_lite_bresp,
  s_axi_lite_bvalid,
  s_axi_lite_bready,
  s_axi_lite_arvalid,
  s_axi_lite_arready,
  s_axi_lite_araddr,
  s_axi_lite_rvalid,
  s_axi_lite_rready,
  s_axi_lite_rdata,
  s_axi_lite_rresp,
  mm2s_frame_ptr_out,
  s2mm_frame_ptr_out,
  m_axi_mm2s_araddr,
  m_axi_mm2s_arlen,
  m_axi_mm2s_arsize,
  m_axi_mm2s_arburst,
  m_axi_mm2s_arprot,
  m_axi_mm2s_arcache,
  m_axi_mm2s_arvalid,
  m_axi_mm2s_arready,
  m_axi_mm2s_rdata,
  m_axi_mm2s_rresp,
  m_axi_mm2s_rlast,
  m_axi_mm2s_rvalid,
  m_axi_mm2s_rready,
  m_axis_mm2s_tdata,
  m_axis_mm2s_tkeep,
  m_axis_mm2s_tuser,
  m_axis_mm2s_tvalid,
  m_axis_mm2s_tready,
  m_axis_mm2s_tlast,
  m_axi_s2mm_awaddr,
  m_axi_s2mm_awlen,
  m_axi_s2mm_awsize,
  m_axi_s2mm_awburst,
  m_axi_s2mm_awprot,
  m_axi_s2mm_awcache,
  m_axi_s2mm_awvalid,
  m_axi_s2mm_awready,
  m_axi_s2mm_wdata,
  m_axi_s2mm_wstrb,
  m_axi_s2mm_wlast,
  m_axi_s2mm_wvalid,
  m_axi_s2mm_wready,
  m_axi_s2mm_bresp,
  m_axi_s2mm_bvalid,
  m_axi_s2mm_bready,
  s_axis_s2mm_tdata,
  s_axis_s2mm_tkeep,
  s_axis_s2mm_tuser,
  s_axis_s2mm_tvalid,
  s_axis_s2mm_tready,
  s_axis_s2mm_tlast,
  mm2s_introut,
  s2mm_introut
);

  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S_AXI_LITE_ACLK CLK" *)
  (* X_INTERFACE_MODE = "slave S_AXI_LITE_ACLK" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_LITE_ACLK, ASSOCIATED_BUSIF S_AXI_LITE:M_AXI, ASSOCIATED_RESET axi_resetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN , ASSOCIATED_PORT , INSERT_VIP 0" *)
  input s_axi_lite_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 M_AXI_MM2S_ACLK CLK" *)
  (* X_INTERFACE_MODE = "slave M_AXI_MM2S_ACLK" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_MM2S_ACLK, ASSOCIATED_BUSIF M_AXI_MM2S, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN , ASSOCIATED_PORT , ASSOCIATED_RESET , INSERT_VIP 0" *)
  input m_axi_mm2s_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 M_AXIS_MM2S_ACLK CLK" *)
  (* X_INTERFACE_MODE = "slave M_AXIS_MM2S_ACLK" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS_MM2S_ACLK, ASSOCIATED_BUSIF M_AXIS_MM2S, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN , ASSOCIATED_PORT , ASSOCIATED_RESET , INSERT_VIP 0" *)
  input m_axis_mm2s_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 M_AXI_S2MM_ACLK CLK" *)
  (* X_INTERFACE_MODE = "slave M_AXI_S2MM_ACLK" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_S2MM_ACLK, ASSOCIATED_BUSIF M_AXI_S2MM, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN , ASSOCIATED_PORT , ASSOCIATED_RESET , INSERT_VIP 0" *)
  input m_axi_s2mm_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S_AXIS_S2MM_ACLK CLK" *)
  (* X_INTERFACE_MODE = "slave S_AXIS_S2MM_ACLK" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_S2MM_ACLK, ASSOCIATED_BUSIF S_AXIS_S2MM, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN , ASSOCIATED_PORT , ASSOCIATED_RESET , INSERT_VIP 0" *)
  input s_axis_s2mm_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 AXI_RESETN RST" *)
  (* X_INTERFACE_MODE = "slave AXI_RESETN" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME AXI_RESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
  input axi_resetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE AWVALID" *)
  (* X_INTERFACE_MODE = "slave S_AXI_LITE" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_LITE, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 9, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 0, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN , NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
  input s_axi_lite_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE AWREADY" *)
  output s_axi_lite_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE AWADDR" *)
  input [8:0]s_axi_lite_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WVALID" *)
  input s_axi_lite_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WREADY" *)
  output s_axi_lite_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WDATA" *)
  input [31:0]s_axi_lite_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE BRESP" *)
  output [1:0]s_axi_lite_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE BVALID" *)
  output s_axi_lite_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE BREADY" *)
  input s_axi_lite_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE ARVALID" *)
  input s_axi_lite_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE ARREADY" *)
  output s_axi_lite_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE ARADDR" *)
  input [8:0]s_axi_lite_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RVALID" *)
  output s_axi_lite_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RREADY" *)
  input s_axi_lite_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RDATA" *)
  output [31:0]s_axi_lite_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RRESP" *)
  output [1:0]s_axi_lite_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:signal:video_frame_ptr:1.0 MM2S_FRAME_PTR_OUT FRAME_PTR" *)
  (* X_INTERFACE_MODE = "master MM2S_FRAME_PTR_OUT" *)
  output [5:0]mm2s_frame_ptr_out;
  (* X_INTERFACE_INFO = "xilinx.com:signal:video_frame_ptr:1.0 S2MM_FRAME_PTR_OUT FRAME_PTR" *)
  (* X_INTERFACE_MODE = "master S2MM_FRAME_PTR_OUT" *)
  output [5:0]s2mm_frame_ptr_out;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARADDR" *)
  (* X_INTERFACE_MODE = "master M_AXI_MM2S" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_MM2S, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 2, DATA_WIDTH 64, PROTOCOL AXI4, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_ONLY, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 0, HAS_BRESP 0, HAS_RRESP 1, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN , NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
  output [31:0]m_axi_mm2s_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARLEN" *)
  output [7:0]m_axi_mm2s_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARSIZE" *)
  output [2:0]m_axi_mm2s_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARBURST" *)
  output [1:0]m_axi_mm2s_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARPROT" *)
  output [2:0]m_axi_mm2s_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARCACHE" *)
  output [3:0]m_axi_mm2s_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARVALID" *)
  output m_axi_mm2s_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARREADY" *)
  input m_axi_mm2s_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S RDATA" *)
  input [63:0]m_axi_mm2s_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S RRESP" *)
  input [1:0]m_axi_mm2s_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S RLAST" *)
  input m_axi_mm2s_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S RVALID" *)
  input m_axi_mm2s_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S RREADY" *)
  output m_axi_mm2s_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S TDATA" *)
  (* X_INTERFACE_MODE = "master M_AXIS_MM2S" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS_MM2S, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN , LAYERED_METADATA undef, INSERT_VIP 0" *)
  output [31:0]m_axis_mm2s_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S TKEEP" *)
  output [3:0]m_axis_mm2s_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S TUSER" *)
  output [0:0]m_axis_mm2s_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S TVALID" *)
  output m_axis_mm2s_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S TREADY" *)
  input m_axis_mm2s_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S TLAST" *)
  output m_axis_mm2s_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM AWADDR" *)
  (* X_INTERFACE_MODE = "master M_AXI_S2MM" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_S2MM, SUPPORTS_NARROW_BURST 0, NUM_WRITE_OUTSTANDING 2, DATA_WIDTH 64, PROTOCOL AXI4, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE WRITE_ONLY, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 0, NUM_READ_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN , NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
  output [31:0]m_axi_s2mm_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM AWLEN" *)
  output [7:0]m_axi_s2mm_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM AWSIZE" *)
  output [2:0]m_axi_s2mm_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM AWBURST" *)
  output [1:0]m_axi_s2mm_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM AWPROT" *)
  output [2:0]m_axi_s2mm_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM AWCACHE" *)
  output [3:0]m_axi_s2mm_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM AWVALID" *)
  output m_axi_s2mm_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM AWREADY" *)
  input m_axi_s2mm_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM WDATA" *)
  output [63:0]m_axi_s2mm_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM WSTRB" *)
  output [7:0]m_axi_s2mm_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM WLAST" *)
  output m_axi_s2mm_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM WVALID" *)
  output m_axi_s2mm_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM WREADY" *)
  input m_axi_s2mm_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM BRESP" *)
  input [1:0]m_axi_s2mm_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM BVALID" *)
  input m_axi_s2mm_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_S2MM BREADY" *)
  output m_axi_s2mm_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM TDATA" *)
  (* X_INTERFACE_MODE = "slave S_AXIS_S2MM" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_S2MM, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN , LAYERED_METADATA undef, INSERT_VIP 0" *)
  input [31:0]s_axis_s2mm_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM TKEEP" *)
  input [3:0]s_axis_s2mm_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM TUSER" *)
  input [0:0]s_axis_s2mm_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM TVALID" *)
  input s_axis_s2mm_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM TREADY" *)
  output s_axis_s2mm_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM TLAST" *)
  input s_axis_s2mm_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 MM2S_INTROUT INTERRUPT" *)
  (* X_INTERFACE_MODE = "master MM2S_INTROUT" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME MM2S_INTROUT, SENSITIVITY LEVEL_HIGH, PortWidth 1" *)
  output mm2s_introut;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 S2MM_INTROUT INTERRUPT" *)
  (* X_INTERFACE_MODE = "master S2MM_INTROUT" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S2MM_INTROUT, SENSITIVITY LEVEL_HIGH, PortWidth 1" *)
  output s2mm_introut;

  // stub module has no contents

endmodule
