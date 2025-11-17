transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {/home/hsjang0918/Desktop/2022_dsd_final_project-nexys/build/layer_tb/conv_tb/conv_tb.cache/compile_simlib/riviera}
vlib riviera/xpm
vlib riviera/lib_cdc_v1_0_2
vlib riviera/lib_pkg_v1_0_2
vlib riviera/fifo_generator_v13_2_8
vlib riviera/lib_fifo_v1_0_17
vlib riviera/blk_mem_gen_v8_4_6
vlib riviera/lib_bmg_v1_0_15
vlib riviera/lib_srl_fifo_v1_0_2
vlib riviera/axi_datamover_v5_1_30
vlib riviera/axi_vdma_v6_3_16
vlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../ipstatic/hdl" -l xpm -l lib_cdc_v1_0_2 -l lib_pkg_v1_0_2 -l fifo_generator_v13_2_8 -l lib_fifo_v1_0_17 -l blk_mem_gen_v8_4_6 -l lib_bmg_v1_0_15 -l lib_srl_fifo_v1_0_2 -l axi_datamover_v5_1_30 -l axi_vdma_v6_3_16 -l xil_defaultlib \
"/opt/xilinx/Vivado/2023.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/xilinx/Vivado/2023.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/opt/xilinx/Vivado/2023.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"/opt/xilinx/Vivado/2023.1/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work lib_cdc_v1_0_2 -93  -incr \
"../../../ipstatic/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work lib_pkg_v1_0_2 -93  -incr \
"../../../ipstatic/hdl/lib_pkg_v1_0_rfs.vhd" \

vlog -work fifo_generator_v13_2_8  -incr -v2k5 "+incdir+../../../ipstatic/hdl" -l xpm -l lib_cdc_v1_0_2 -l lib_pkg_v1_0_2 -l fifo_generator_v13_2_8 -l lib_fifo_v1_0_17 -l blk_mem_gen_v8_4_6 -l lib_bmg_v1_0_15 -l lib_srl_fifo_v1_0_2 -l axi_datamover_v5_1_30 -l axi_vdma_v6_3_16 -l xil_defaultlib \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_8 -93  -incr \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_8  -incr -v2k5 "+incdir+../../../ipstatic/hdl" -l xpm -l lib_cdc_v1_0_2 -l lib_pkg_v1_0_2 -l fifo_generator_v13_2_8 -l lib_fifo_v1_0_17 -l blk_mem_gen_v8_4_6 -l lib_bmg_v1_0_15 -l lib_srl_fifo_v1_0_2 -l axi_datamover_v5_1_30 -l axi_vdma_v6_3_16 -l xil_defaultlib \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vcom -work lib_fifo_v1_0_17 -93  -incr \
"../../../ipstatic/hdl/lib_fifo_v1_0_rfs.vhd" \

vlog -work blk_mem_gen_v8_4_6  -incr -v2k5 "+incdir+../../../ipstatic/hdl" -l xpm -l lib_cdc_v1_0_2 -l lib_pkg_v1_0_2 -l fifo_generator_v13_2_8 -l lib_fifo_v1_0_17 -l blk_mem_gen_v8_4_6 -l lib_bmg_v1_0_15 -l lib_srl_fifo_v1_0_2 -l axi_datamover_v5_1_30 -l axi_vdma_v6_3_16 -l xil_defaultlib \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vcom -work lib_bmg_v1_0_15 -93  -incr \
"../../../ipstatic/hdl/lib_bmg_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_2 -93  -incr \
"../../../ipstatic/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work axi_datamover_v5_1_30 -93  -incr \
"../../../ipstatic/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vlog -work axi_vdma_v6_3_16  -incr -v2k5 "+incdir+../../../ipstatic/hdl" -l xpm -l lib_cdc_v1_0_2 -l lib_pkg_v1_0_2 -l fifo_generator_v13_2_8 -l lib_fifo_v1_0_17 -l blk_mem_gen_v8_4_6 -l lib_bmg_v1_0_15 -l lib_srl_fifo_v1_0_2 -l axi_datamover_v5_1_30 -l axi_vdma_v6_3_16 -l xil_defaultlib \
"../../../ipstatic/hdl/axi_vdma_v6_3_rfs.v" \

vcom -work axi_vdma_v6_3_16 -93  -incr \
"../../../ipstatic/hdl/axi_vdma_v6_3_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../../../../../src/tb/conv/ip/axi_vdma_0/sim/axi_vdma_0.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

