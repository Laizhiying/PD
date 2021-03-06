vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm
vlib questa_lib/msim/fifo_generator_v13_2_1

vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm
vmap fifo_generator_v13_2_1 questa_lib/msim/fifo_generator_v13_2_1

vlog -work xil_defaultlib -64 -sv -L smartconnect_v1_0 -L axi_protocol_checker_v2_0_1 -L axi_vip_v1_1_1 -L processing_system7_vip_v1_0_3 -L xil_defaultlib -L xilinx_vip "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work fifo_generator_v13_2_1 -64 "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_1 -64 -93 \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_1 -64 "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work xil_defaultlib -64 "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/ip/fifo_generator_0/sim/fifo_generator_0.v" \

vlog -work xil_defaultlib \
"glbl.v"

