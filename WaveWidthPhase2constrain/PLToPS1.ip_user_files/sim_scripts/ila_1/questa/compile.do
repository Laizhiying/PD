vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm

vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm

vlog -work xil_defaultlib -64 -sv -L smartconnect_v1_0 -L axi_protocol_checker_v2_0_1 -L axi_vip_v1_1_1 -L processing_system7_vip_v1_0_3 -L xil_defaultlib -L xilinx_vip "+incdir+../../../../PLToPS1.srcs/sources_1/ip/ila_1/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/ip/ila_1/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 "+incdir+../../../../PLToPS1.srcs/sources_1/ip/ila_1/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/ip/ila_1/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/ip/ila_1/sim/ila_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

