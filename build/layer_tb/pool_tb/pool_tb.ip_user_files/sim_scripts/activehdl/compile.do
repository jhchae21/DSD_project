transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xpm
vlib activehdl/lib_cdc_v1_0_3
vlib activehdl/lib_pkg_v1_0_4
vlib activehdl/fifo_generator_v13_2_11
vlib activehdl/lib_fifo_v1_0_20
vlib activehdl/blk_mem_gen_v8_4_9
vlib activehdl/lib_bmg_v1_0_18
vlib activehdl/lib_srl_fifo_v1_0_4
vlib activehdl/axi_datamover_v5_1_35
vlib activehdl/axi_vdma_v6_3_21
vlib activehdl/xil_defaultlib
vlib activehdl/axi_interconnect_v1_7_24

vmap xpm activehdl/xpm
vmap lib_cdc_v1_0_3 activehdl/lib_cdc_v1_0_3
vmap lib_pkg_v1_0_4 activehdl/lib_pkg_v1_0_4
vmap fifo_generator_v13_2_11 activehdl/fifo_generator_v13_2_11
vmap lib_fifo_v1_0_20 activehdl/lib_fifo_v1_0_20
vmap blk_mem_gen_v8_4_9 activehdl/blk_mem_gen_v8_4_9
vmap lib_bmg_v1_0_18 activehdl/lib_bmg_v1_0_18
vmap lib_srl_fifo_v1_0_4 activehdl/lib_srl_fifo_v1_0_4
vmap axi_datamover_v5_1_35 activehdl/axi_datamover_v5_1_35
vmap axi_vdma_v6_3_21 activehdl/axi_vdma_v6_3_21
vmap xil_defaultlib activehdl/xil_defaultlib
vmap axi_interconnect_v1_7_24 activehdl/axi_interconnect_v1_7_24

vlog -work xpm  -sv2k12 "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work lib_cdc_v1_0_3 -93  \
"../../ipstatic/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work lib_pkg_v1_0_4 -93  \
"../../ipstatic/hdl/lib_pkg_v1_0_rfs.vhd" \

vlog -work fifo_generator_v13_2_11  -v2k5 "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_11 -93  \
"../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_11  -v2k5 "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vcom -work lib_fifo_v1_0_20 -93  \
"../../ipstatic/hdl/lib_fifo_v1_0_rfs.vhd" \

vlog -work blk_mem_gen_v8_4_9  -v2k5 "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vcom -work lib_bmg_v1_0_18 -93  \
"../../ipstatic/hdl/lib_bmg_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_4 -93  \
"../../ipstatic/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work axi_datamover_v5_1_35 -93  \
"../../ipstatic/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vlog -work axi_vdma_v6_3_21  -v2k5 "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../ipstatic/hdl/axi_vdma_v6_3_rfs.v" \

vcom -work axi_vdma_v6_3_21 -93  \
"../../ipstatic/hdl/axi_vdma_v6_3_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../../../../src/tb/pool/ip/axi_vdma_0/sim/axi_vdma_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../../pool_tb.gen/sources_1/ip/sram_32x131072/sim/sram_32x131072.v" \

vlog -work axi_interconnect_v1_7_24  -v2k5 "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../ipstatic/hdl/axi_interconnect_v1_7_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../../src/tb/pool/ip/axi_vdma_0/hdl" -l xpm -l lib_cdc_v1_0_3 -l lib_pkg_v1_0_4 -l fifo_generator_v13_2_11 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 -l xil_defaultlib -l axi_interconnect_v1_7_24 \
"../../../../../../src/tb/pool/ip/axi_interconnect_0/sim/axi_interconnect_0.v" \
"../../../../../../src/tb/pool/axi_m_interface.v" \
"../../../../../../src/modules/pool_module/pool_module.v" \
"../../../../../../src/tb/pool/top_simulation.v" \
"../../../../../../src/tb/pool/vdma_controller.v" \
"../../../../../../src/tb/pool/tb.v" \

vlog -work xil_defaultlib \
"glbl.v"

