transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+tb  -L xil_defaultlib -L xpm -L lib_cdc_v1_0_3 -L lib_pkg_v1_0_4 -L fifo_generator_v13_2_11 -L lib_fifo_v1_0_20 -L blk_mem_gen_v8_4_9 -L lib_bmg_v1_0_18 -L lib_srl_fifo_v1_0_4 -L axi_datamover_v5_1_35 -L axi_vdma_v6_3_21 -L axi_interconnect_v1_7_24 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.tb xil_defaultlib.glbl

do {tb.udo}

run 1000ns

endsim

quit -force
