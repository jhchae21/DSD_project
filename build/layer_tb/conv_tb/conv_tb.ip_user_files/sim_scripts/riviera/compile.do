transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/lib_cdc_v1_0_3
vlib riviera/lib_pkg_v1_0_4
vlib riviera/fifo_generator_v13_2_11
vlib riviera/lib_fifo_v1_0_20
vlib riviera/blk_mem_gen_v8_4_9
vlib riviera/lib_bmg_v1_0_18
vlib riviera/lib_srl_fifo_v1_0_4
vlib riviera/axi_datamover_v5_1_35
vlib riviera/axi_vdma_v6_3_21
vlib riviera/xil_defaultlib
vlib riviera/axi_interconnect_v1_7_24

vmap xpm riviera/xpm
vmap lib_cdc_v1_0_3 riviera/lib_cdc_v1_0_3
vmap lib_pkg_v1_0_4 riviera/lib_pkg_v1_0_4
vmap fifo_generator_v13_2_11 riviera/fifo_generator_v13_2_11
vmap lib_fifo_v1_0_20 riviera/lib_fifo_v1_0_20
vmap blk_mem_gen_v8_4_9 riviera/blk_mem_gen_v8_4_9
vmap lib_bmg_v1_0_18 riviera/lib_bmg_v1_0_18
vmap lib_srl_fifo_v1_0_4 riviera/lib_srl_fifo_v1_0_4
vmap axi_datamover_v5_1_35 riviera/axi_datamover_v5_1_35
vmap axi_vdma_v6_3_21 riviera/axi_vdma_v6_3_21
vmap xil_defaultlib riviera/xil_defaultlib
vmap axi_interconnect_v1_7_24 riviera/axi_interconnect_v1_7_24

vlog -work xpm  -incr "+incdir+../../../../../../src/tb/conv/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work lib_cdc_v1_0_3 -93  -incr \
"../../ipstatic/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work lib_pkg_v1_0_4 -93  -incr \
"../../ipstatic/hdl/lib_pkg_v1_0_rfs.vhd" \

vlog -work fifo_generator_v13_2_11  -incr -v2k5 "+incdir+../../../../../../src/tb/conv/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_11 -93  -incr \
"../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_11  -incr -v2k5 "+incdir+../../../../../../src/tb/conv/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vcom -work lib_fifo_v1_0_20 -93  -incr \
"../../ipstatic/hdl/lib_fifo_v1_0_rfs.vhd" \

vlog -work blk_mem_gen_v8_4_9  -incr -v2k5 "+incdir+../../../../../../src/tb/conv/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vcom -work lib_bmg_v1_0_18 -93  -incr \
"../../ipstatic/hdl/lib_bmg_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_4 -93  -incr \
"../../ipstatic/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work axi_datamover_v5_1_35 -93  -incr \
"../../ipstatic/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vlog -work axi_vdma_v6_3_21  -incr -v2k5 "+incdir+../../../../../../src/tb/conv/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../ipstatic/hdl/axi_vdma_v6_3_rfs.v" \

vcom -work axi_vdma_v6_3_21 -93  -incr \
"../../ipstatic/hdl/axi_vdma_v6_3_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../../../../src/tb/conv/ip/axi_vdma_0/sim/axi_vdma_0.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../../../src/tb/conv/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../../conv_tb.gen/sources_1/ip/sram_32x131072/sim/sram_32x131072.v" \

vlog -work axi_interconnect_v1_7_24  -incr -v2k5 "+incdir+../../../../../../src/tb/conv/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../ipstatic/hdl/axi_interconnect_v1_7_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../../../src/tb/conv/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../../../../../src/tb/conv/ip/axi_interconnect_0/sim/axi_interconnect_0.v" \
"../../../../../../src/tb/conv/axi_m_interface.v" \
"../../../../../../src/modules/conv_module/conv_module.v" \
"../../../../../../src/tb/conv/top_simulation.v" \
"../../../../../../src/tb/conv/vdma_controller.v" \
"../../../../../../src/tb/conv/tb.v" \

vlog -work xil_defaultlib \
"glbl.v"

