transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {}
vlib activehdl/xpm
vlib activehdl/fifo_generator_v13_2_8
vlib activehdl/axi_interconnect_v1_7_21
vlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 -l xpm -l fifo_generator_v13_2_8 -l axi_interconnect_v1_7_21 -l xil_defaultlib \
"/opt/xilinx/Vivado/2023.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/xilinx/Vivado/2023.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/opt/xilinx/Vivado/2023.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"/opt/xilinx/Vivado/2023.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work fifo_generator_v13_2_8  -v2k5 -l xpm -l fifo_generator_v13_2_8 -l axi_interconnect_v1_7_21 -l xil_defaultlib \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_8 -93  \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_8  -v2k5 -l xpm -l fifo_generator_v13_2_8 -l axi_interconnect_v1_7_21 -l xil_defaultlib \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_interconnect_v1_7_21  -v2k5 -l xpm -l fifo_generator_v13_2_8 -l axi_interconnect_v1_7_21 -l xil_defaultlib \
"../../../ipstatic/hdl/axi_interconnect_v1_7_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 -l xpm -l fifo_generator_v13_2_8 -l axi_interconnect_v1_7_21 -l xil_defaultlib \
"../../../../../../src/common_ip/axi_interconnect_1/sim/axi_interconnect_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

