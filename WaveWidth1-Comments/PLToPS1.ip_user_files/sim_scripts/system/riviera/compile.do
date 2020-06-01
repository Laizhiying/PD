vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/smartconnect_v1_0
vlib riviera/axi_protocol_checker_v2_0_1
vlib riviera/axi_vip_v1_1_1
vlib riviera/processing_system7_vip_v1_0_3
vlib riviera/lib_pkg_v1_0_2
vlib riviera/lib_srl_fifo_v1_0_2
vlib riviera/emc_common_v3_0_5
vlib riviera/axi_emc_v3_0_15
vlib riviera/xlconstant_v1_1_3
vlib riviera/lib_cdc_v1_0_2
vlib riviera/proc_sys_reset_v5_0_12
vlib riviera/axi_lite_ipif_v3_0_4
vlib riviera/interrupt_control_v3_1_4
vlib riviera/axi_gpio_v2_0_17

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap smartconnect_v1_0 riviera/smartconnect_v1_0
vmap axi_protocol_checker_v2_0_1 riviera/axi_protocol_checker_v2_0_1
vmap axi_vip_v1_1_1 riviera/axi_vip_v1_1_1
vmap processing_system7_vip_v1_0_3 riviera/processing_system7_vip_v1_0_3
vmap lib_pkg_v1_0_2 riviera/lib_pkg_v1_0_2
vmap lib_srl_fifo_v1_0_2 riviera/lib_srl_fifo_v1_0_2
vmap emc_common_v3_0_5 riviera/emc_common_v3_0_5
vmap axi_emc_v3_0_15 riviera/axi_emc_v3_0_15
vmap xlconstant_v1_1_3 riviera/xlconstant_v1_1_3
vmap lib_cdc_v1_0_2 riviera/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_12 riviera/proc_sys_reset_v5_0_12
vmap axi_lite_ipif_v3_0_4 riviera/axi_lite_ipif_v3_0_4
vmap interrupt_control_v3_1_4 riviera/interrupt_control_v3_1_4
vmap axi_gpio_v2_0_17 riviera/axi_gpio_v2_0_17

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/sc_util_v1_0_vl_rfs.sv" \

vlog -work axi_protocol_checker_v2_0_1  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/3b24/hdl/axi_protocol_checker_v2_0_vl_rfs.sv" \

vlog -work axi_vip_v1_1_1  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/a16a/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_3  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/ip/system_processing_system7_0_0/sim/system_processing_system7_0_0.v" \

vcom -work lib_pkg_v1_0_2 -93 \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_2 -93 \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work emc_common_v3_0_5 -93 \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/d806/hdl/emc_common_v3_0_vh_rfs.vhd" \

vcom -work axi_emc_v3_0_15 -93 \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/187c/hdl/axi_emc_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/system/ip/system_axi_emc_0_0/sim/system_axi_emc_0_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/sim/bd_44e3.v" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/786b/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_10/sim/bd_44e3_s00a2s_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/92d2/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_16/sim/bd_44e3_m00s2a_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_23/sim/bd_44e3_m01s2a_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/258c/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_29/sim/bd_44e3_m01e_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_24/sim/bd_44e3_m01arn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_25/sim/bd_44e3_m01rn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_26/sim/bd_44e3_m01awn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_27/sim/bd_44e3_m01wn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_28/sim/bd_44e3_m01bn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_22/sim/bd_44e3_m00e_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_17/sim/bd_44e3_m00arn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_18/sim/bd_44e3_m00rn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_19/sim/bd_44e3_m00awn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_20/sim/bd_44e3_m00wn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_21/sim/bd_44e3_m00bn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_11/sim/bd_44e3_sarn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_12/sim/bd_44e3_srn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_13/sim/bd_44e3_sawn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_14/sim/bd_44e3_swn_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_15/sim/bd_44e3_sbn_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/8ad6/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_7/sim/bd_44e3_s00mmu_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/0f5f/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_8/sim/bd_44e3_s00tr_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/925a/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_9/sim/bd_44e3_s00sic_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1b0c/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_2/sim/bd_44e3_arsw_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_3/sim/bd_44e3_rsw_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_4/sim/bd_44e3_awsw_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_5/sim/bd_44e3_wsw_0.sv" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_6/sim/bd_44e3_bsw_0.sv" \

vlog -work xlconstant_v1_1_3  -v2k5 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/0750/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_0/sim/bd_44e3_one_0.v" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_12 -93 \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/f86a/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_1/sim/bd_44e3_psr_aclk_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/ip/system_axi_smc_0/sim/system_axi_smc_0.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system/ip/system_rst_ps7_0_100M_0/sim/system_rst_ps7_0_100M_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl" "+incdir+../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/verilog" "+incdir+D:/Software/Xilinx17.4/Vivado/2017.4/data/xilinx_vip/include" \
"../../../bd/system/sim/system.v" \

vcom -work axi_lite_ipif_v3_0_4 -93 \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/cced/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work interrupt_control_v3_1_4 -93 \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/8e66/hdl/interrupt_control_v3_1_vh_rfs.vhd" \

vcom -work axi_gpio_v2_0_17 -93 \
"../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/c450/hdl/axi_gpio_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/system/ip/system_axi_gpio_0_0/sim/system_axi_gpio_0_0.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

