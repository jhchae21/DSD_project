transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+axi_vdma_0  -L xpm -L lib_cdc_v1_0_2 -L lib_pkg_v1_0_2 -L fifo_generator_v13_2_8 -L lib_fifo_v1_0_17 -L blk_mem_gen_v8_4_6 -L lib_bmg_v1_0_15 -L lib_srl_fifo_v1_0_2 -L axi_datamover_v5_1_30 -L axi_vdma_v6_3_16 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O2 xil_defaultlib.axi_vdma_0 xil_defaultlib.glbl

do {axi_vdma_0.udo}

run

endsim

quit -force
