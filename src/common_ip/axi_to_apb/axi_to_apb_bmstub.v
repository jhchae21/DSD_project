// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// -------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

(* BLOCK_STUB = "true" *)
module axi_to_apb (
  s_axi_aclk,
  s_axi_aresetn,
  s_axi_awaddr,
  s_axi_awvalid,
  s_axi_awready,
  s_axi_wdata,
  s_axi_wvalid,
  s_axi_wready,
  s_axi_bresp,
  s_axi_bvalid,
  s_axi_bready,
  s_axi_araddr,
  s_axi_arvalid,
  s_axi_arready,
  s_axi_rdata,
  s_axi_rresp,
  s_axi_rvalid,
  s_axi_rready,
  m_apb_paddr,
  m_apb_psel,
  m_apb_penable,
  m_apb_pwrite,
  m_apb_pwdata,
  m_apb_pready,
  m_apb_prdata,
  m_apb_pslverr
);

  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 ACLK CLK" *)
  (* X_INTERFACE_MODE = "slave ACLK" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ACLK, ASSOCIATED_BUSIF AXI4_LITE:APB_M:APB_M2:APB_M3:APB_M4:APB_M5:APB_M6:APB_M7:APB_M8:APB_M9:APB_M10:APB_M11:APB_M12:APB_M13:APB_M14:APB_M15:APB_M16, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN , ASSOCIATED_PORT , INSERT_VIP 0" *)
  input s_axi_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ARESETN RST" *)
  (* X_INTERFACE_MODE = "slave ARESETN" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
  input s_axi_aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE AWADDR" *)
  (* X_INTERFACE_MODE = "slave AXI4_LITE" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME AXI4_LITE, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 0, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN , NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
  input [31:0]s_axi_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE AWVALID" *)
  input s_axi_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE AWREADY" *)
  output s_axi_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE WDATA" *)
  input [31:0]s_axi_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE WVALID" *)
  input s_axi_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE WREADY" *)
  output s_axi_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE BRESP" *)
  output [1:0]s_axi_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE BVALID" *)
  output s_axi_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE BREADY" *)
  input s_axi_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE ARADDR" *)
  input [31:0]s_axi_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE ARVALID" *)
  input s_axi_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE ARREADY" *)
  output s_axi_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE RDATA" *)
  output [31:0]s_axi_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE RRESP" *)
  output [1:0]s_axi_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE RVALID" *)
  output s_axi_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_LITE RREADY" *)
  input s_axi_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_M PADDR" *)
  (* X_INTERFACE_MODE = "master APB_M" *)
  output [31:0]m_apb_paddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_M PSEL" *)
  output [0:0]m_apb_psel;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_M PENABLE" *)
  output m_apb_penable;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_M PWRITE" *)
  output m_apb_pwrite;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_M PWDATA" *)
  output [31:0]m_apb_pwdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_M PREADY" *)
  input [0:0]m_apb_pready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_M PRDATA" *)
  input [31:0]m_apb_prdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_M PSLVERR" *)
  input [0:0]m_apb_pslverr;

  // stub module has no contents

endmodule
