vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/lib_cdc_v1_0_3
vlib modelsim_lib/msim/lib_pkg_v1_0_4
vlib modelsim_lib/msim/fifo_generator_v13_2_11
vlib modelsim_lib/msim/lib_fifo_v1_0_20
vlib modelsim_lib/msim/blk_mem_gen_v8_4_9
vlib modelsim_lib/msim/lib_bmg_v1_0_18
vlib modelsim_lib/msim/lib_srl_fifo_v1_0_4
vlib modelsim_lib/msim/axi_datamover_v5_1_35
vlib modelsim_lib/msim/axi_vdma_v6_3_21
vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/axi_interconnect_v1_7_24

vmap xpm modelsim_lib/msim/xpm
vmap lib_cdc_v1_0_3 modelsim_lib/msim/lib_cdc_v1_0_3
vmap lib_pkg_v1_0_4 modelsim_lib/msim/lib_pkg_v1_0_4
vmap fifo_generator_v13_2_11 modelsim_lib/msim/fifo_generator_v13_2_11
vmap lib_fifo_v1_0_20 modelsim_lib/msim/lib_fifo_v1_0_20
vmap blk_mem_gen_v8_4_9 modelsim_lib/msim/blk_mem_gen_v8_4_9
vmap lib_bmg_v1_0_18 modelsim_lib/msim/lib_bmg_v1_0_18
vmap lib_srl_fifo_v1_0_4 modelsim_lib/msim/lib_srl_fifo_v1_0_4
vmap axi_datamover_v5_1_35 modelsim_lib/msim/axi_datamover_v5_1_35
vmap axi_vdma_v6_3_21 modelsim_lib/msim/axi_vdma_v6_3_21
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap axi_interconnect_v1_7_24 modelsim_lib/msim/axi_interconnect_v1_7_24

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work lib_cdc_v1_0_3  -93  \
"../../ipstatic/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work lib_pkg_v1_0_4  -93  \
"../../ipstatic/hdl/lib_pkg_v1_0_rfs.vhd" \

vlog -work fifo_generator_v13_2_11  -incr -mfcu  "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" \
"../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_11  -93  \
"../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_11  -incr -mfcu  "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" \
"../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vcom -work lib_fifo_v1_0_20  -93  \
"../../ipstatic/hdl/lib_fifo_v1_0_rfs.vhd" \

vlog -work blk_mem_gen_v8_4_9  -incr -mfcu  "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" \
"../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vcom -work lib_bmg_v1_0_18  -93  \
"../../ipstatic/hdl/lib_bmg_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_4  -93  \
"../../ipstatic/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work axi_datamover_v5_1_35  -93  \
"../../ipstatic/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vlog -work axi_vdma_v6_3_21  -incr -mfcu  "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" \
"../../ipstatic/hdl/axi_vdma_v6_3_rfs.v" \

vcom -work axi_vdma_v6_3_21  -93  \
"../../ipstatic/hdl/axi_vdma_v6_3_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../../../../src/tb/pool/ip/axi_vdma_0/sim/axi_vdma_0.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" \
"../../../pool_tb.gen/sources_1/ip/sram_32x131072/sim/sram_32x131072.v" \

vlog -work axi_interconnect_v1_7_24  -incr -mfcu  "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" \
"../../ipstatic/hdl/axi_interconnect_v1_7_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" \
"../../../../../../src/tb/pool/ip/axi_interconnect_0/sim/axi_interconnect_0.v" \
"../../../../../../src/tb/pool/axi_m_interface.v" \
"../../../../../../src/modules/pool_module/pool_module.v" \
"../../../../../../src/tb/pool/top_simulation.v" \
"../../../../../../src/tb/pool/vdma_controller.v" \
"../../../../../../src/tb/pool/tb.v" \

vlog -work xil_defaultlib \
"glbl.v"

