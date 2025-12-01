transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xpm
vlib activehdl/lib_pkg_v1_0_4
vlib activehdl/axi_apb_bridge_v3_0_20
vlib activehdl/xil_defaultlib
vlib activehdl/generic_baseblocks_v2_1_2
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/axi_register_slice_v2_1_33
vlib activehdl/fifo_generator_v13_2_11
vlib activehdl/axi_data_fifo_v2_1_32
vlib activehdl/axi_crossbar_v2_1_34
vlib activehdl/axi_interconnect_v1_7_24
vlib activehdl/axi_protocol_converter_v2_1_33
vlib activehdl/lib_cdc_v1_0_3
vlib activehdl/lib_fifo_v1_0_20
vlib activehdl/blk_mem_gen_v8_4_9
vlib activehdl/lib_bmg_v1_0_18
vlib activehdl/lib_srl_fifo_v1_0_4
vlib activehdl/axi_datamover_v5_1_35
vlib activehdl/axi_vdma_v6_3_21

vmap xpm activehdl/xpm
vmap lib_pkg_v1_0_4 activehdl/lib_pkg_v1_0_4
vmap axi_apb_bridge_v3_0_20 activehdl/axi_apb_bridge_v3_0_20
vmap xil_defaultlib activehdl/xil_defaultlib
vmap generic_baseblocks_v2_1_2 activehdl/generic_baseblocks_v2_1_2
vmap axi_infrastructure_v1_1_0 activehdl/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_33 activehdl/axi_register_slice_v2_1_33
vmap fifo_generator_v13_2_11 activehdl/fifo_generator_v13_2_11
vmap axi_data_fifo_v2_1_32 activehdl/axi_data_fifo_v2_1_32
vmap axi_crossbar_v2_1_34 activehdl/axi_crossbar_v2_1_34
vmap axi_interconnect_v1_7_24 activehdl/axi_interconnect_v1_7_24
vmap axi_protocol_converter_v2_1_33 activehdl/axi_protocol_converter_v2_1_33
vmap lib_cdc_v1_0_3 activehdl/lib_cdc_v1_0_3
vmap lib_fifo_v1_0_20 activehdl/lib_fifo_v1_0_20
vmap blk_mem_gen_v8_4_9 activehdl/blk_mem_gen_v8_4_9
vmap lib_bmg_v1_0_18 activehdl/lib_bmg_v1_0_18
vmap lib_srl_fifo_v1_0_4 activehdl/lib_srl_fifo_v1_0_4
vmap axi_datamover_v5_1_35 activehdl/axi_datamover_v5_1_35
vmap axi_vdma_v6_3_21 activehdl/axi_vdma_v6_3_21

vlog -work xpm  -sv2k12 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work lib_pkg_v1_0_4 -93  \
"../../ipstatic/hdl/lib_pkg_v1_0_rfs.vhd" \

vcom -work axi_apb_bridge_v3_0_20 -93  \
"../../ipstatic/hdl/axi_apb_bridge_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../../../src/common_ip/axi_to_apb/sim/axi_to_apb.vhd" \

vlog -work generic_baseblocks_v2_1_2  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../ipstatic/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../ipstatic/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_33  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../ipstatic/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work fifo_generator_v13_2_11  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_11 -93  \
"../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_11  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_data_fifo_v2_1_32  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../ipstatic/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_34  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../ipstatic/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../../../../src/common_ip/axi_crossbar_1/sim/axi_crossbar_1.v" \

vlog -work axi_interconnect_v1_7_24  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../ipstatic/hdl/axi_interconnect_v1_7_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../../../../src/common_ip/axi_interconnect_1/sim/axi_interconnect_1.v" \

vlog -work axi_protocol_converter_v2_1_33  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../ipstatic/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../../../../src/common_ip/axi4_32_to_axilite/sim/axi4_32_to_axilite.v" \
"../../../../../src/common_ip/axi_crossbar_0/sim/axi_crossbar_0.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_addr_decode.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_read.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_reg.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_reg_bank.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_top.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_write.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_ar_channel.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_aw_channel.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_b_channel.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_arbiter.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_fsm.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_translator.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_fifo.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_incr_cmd.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_r_channel.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_simple_fifo.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_wrap_cmd.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_wr_cmd_fsm.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_axi_mc_w_channel.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_axic_register_slice.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_axi_register_slice.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_axi_upsizer.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_a_upsizer.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_and.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_latch_and.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_latch_or.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_or.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_command_fifo.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator_sel.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator_sel_static.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_r_upsizer.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/axi/mig_7series_v4_2_ddr_w_upsizer.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/clocking/mig_7series_v4_2_clk_ibuf.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/clocking/mig_7series_v4_2_infrastructure.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/clocking/mig_7series_v4_2_iodelay_ctrl.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/clocking/mig_7series_v4_2_tempmon.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_arb_mux.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_arb_row_col.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_arb_select.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_bank_cntrl.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_bank_common.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_bank_compare.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_bank_mach.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_bank_queue.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_bank_state.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_col_mach.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_mc.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_rank_cntrl.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_rank_common.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_rank_mach.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/controller/mig_7series_v4_2_round_robin_arb.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/ecc/mig_7series_v4_2_ecc_buf.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/ecc/mig_7series_v4_2_ecc_dec_fix.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/ecc/mig_7series_v4_2_ecc_gen.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/ecc/mig_7series_v4_2_ecc_merge_enc.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/ecc/mig_7series_v4_2_fi_xor.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/ip_top/mig_7series_v4_2_memc_ui_top_axi.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/ip_top/mig_7series_v4_2_mem_intfc.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_group_io.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_lane.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_calib_top.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_if_post_fifo.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy_wrapper.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_of_pre_fifo.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_4lanes.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ck_addr_cmd_delay.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal_hr.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_init.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_cntlr.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_data.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_edge.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_lim.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_mux.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_po_cntlr.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_samp.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_oclkdelay_cal.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_prbs_rdlvl.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_rdlvl.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_tempmon.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_top.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrcal.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl_off_delay.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_ddr_prbs_gen.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_poc_cc.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_poc_edge_store.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_poc_meta.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_poc_pd.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_poc_tap_base.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/phy/mig_7series_v4_2_poc_top.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/ui/mig_7series_v4_2_ui_cmd.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/ui/mig_7series_v4_2_ui_rd_data.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/ui/mig_7series_v4_2_ui_top.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/ui/mig_7series_v4_2_ui_wr_data.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/mig_dram_mig_sim.v" \
"../../../../../src/common_ip/mig_dram/mig_dram/user_design/rtl/mig_dram.v" \

vcom -work lib_cdc_v1_0_3 -93  \
"../../ipstatic/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work lib_fifo_v1_0_20 -93  \
"../../ipstatic/hdl/lib_fifo_v1_0_rfs.vhd" \

vlog -work blk_mem_gen_v8_4_9  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vcom -work lib_bmg_v1_0_18 -93  \
"../../ipstatic/hdl/lib_bmg_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_4 -93  \
"../../ipstatic/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work axi_datamover_v5_1_35 -93  \
"../../ipstatic/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vlog -work axi_vdma_v6_3_21  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../ipstatic/hdl/axi_vdma_v6_3_rfs.v" \

vcom -work axi_vdma_v6_3_21 -93  \
"../../ipstatic/hdl/axi_vdma_v6_3_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../../../src/common_ip/axi_vdma_0/sim/axi_vdma_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../ipstatic/hdl" "+incdir+../../../../../src/common_ip/axi_vdma_0/hdl" "+incdir+../../ipstatic" -l xpm -l lib_pkg_v1_0_4 -l axi_apb_bridge_v3_0_20 -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_interconnect_v1_7_24 -l axi_protocol_converter_v2_1_33 -l lib_cdc_v1_0_3 -l lib_fifo_v1_0_20 -l blk_mem_gen_v8_4_9 -l lib_bmg_v1_0_18 -l lib_srl_fifo_v1_0_4 -l axi_datamover_v5_1_35 -l axi_vdma_v6_3_21 \
"../../../../../src/common_ip/clk_gen/clk_gen_clk_wiz.v" \
"../../../../../src/common_ip/clk_gen/clk_gen.v" \
"../../../../../src/modules/provided/ip/uart/rtl/Convert_32to8.v" \
"../../../../../src/modules/provided/ip/uart/rtl/FIFO_64bit.v" \
"../../../../../src/modules/provided/ip/uart/rtl/FIFO_buffer_64bit.v" \
"../../../../../src/modules/provided/ip/axi_crossbar_0/wrapper/axi_crossbar_0_top.v" \
"../../../../../src/modules/provided/ip/axi_crossbar_1/wrapper/axi_crossbar_1_top.v" \
"../../../../../src/modules/provided/ip/host_decoder/rtl/axi_m_interface.v" \
"../../../../../src/modules/provided/system/rtl/axi_subsystem.v" \
"../../../../../src/modules/conv_module/clk_counter.v" \
"../../../../../src/modules/fc_module/clk_counter.v" \
"../../../../../src/modules/pool_module/clk_counter.v" \
"../../../../../src/modules/compute_top.v" \
"../../../../../src/modules/conv_module/conv_apb.v" \
"../../../../../src/modules/conv_module/conv_module.v" \
"../../../../../src/modules/conv_module/conv_top.v" \
"../../../../../src/modules/fc_module/fc_apb.v" \
"../../../../../src/modules/fc_module/fc_module.v" \
"../../../../../src/modules/fc_module/fc_top.v" \
"../../../../../src/modules/provided/ip/host_decoder/rtl/host_decoder.v" \
"../../../../../src/modules/provided/ip/host_decoder/rtl/host_decoder_top.v" \
"../../../../../src/modules/interface_top.v" \
"../../../../../src/modules/pool_module/pool_apb.v" \
"../../../../../src/modules/pool_module/pool_module.v" \
"../../../../../src/modules/pool_module/pool_top.v" \
"../../../../../src/modules/provided/ip/uart/rtl/receive_debouncing.v" \
"../../../../../src/modules/provided/ip/uart/rtl/receiver.v" \
"../../../../../src/modules/provided/ip/uart/rtl/transmit_debouncing.v" \
"../../../../../src/modules/provided/ip/uart/rtl/transmitter.v" \
"../../../../../src/modules/provided/ip/uart/rtl/uart_top.v" \
"../../../../../src/modules/main.v" \

vlog -work xil_defaultlib \
"glbl.v"

