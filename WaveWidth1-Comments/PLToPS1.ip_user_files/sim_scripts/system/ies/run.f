-makelib ies_lib/xil_defaultlib -sv \
  "D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "D:/Software/Xilinx17.4/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/axi_infrastructure_v1_1_0 \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib ies_lib/smartconnect_v1_0 -sv \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/02c8/hdl/sc_util_v1_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/axi_protocol_checker_v2_0_1 -sv \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/3b24/hdl/axi_protocol_checker_v2_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/axi_vip_v1_1_1 -sv \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/a16a/hdl/axi_vip_v1_1_vl_rfs.sv" \
-endlib
-makelib ies_lib/processing_system7_vip_v1_0_3 -sv \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1313/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/system/ip/system_processing_system7_0_0/sim/system_processing_system7_0_0.v" \
-endlib
-makelib ies_lib/lib_pkg_v1_0_2 \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \
-endlib
-makelib ies_lib/lib_srl_fifo_v1_0_2 \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \
-endlib
-makelib ies_lib/emc_common_v3_0_5 \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/d806/hdl/emc_common_v3_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/axi_emc_v3_0_15 \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/187c/hdl/axi_emc_v3_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/system/ip/system_axi_emc_0_0/sim/system_axi_emc_0_0.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/sim/bd_44e3.v" \
-endlib
-makelib ies_lib/smartconnect_v1_0 -sv \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/786b/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_10/sim/bd_44e3_s00a2s_0.sv" \
-endlib
-makelib ies_lib/smartconnect_v1_0 -sv \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/92d2/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_16/sim/bd_44e3_m00s2a_0.sv" \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_23/sim/bd_44e3_m01s2a_0.sv" \
-endlib
-makelib ies_lib/smartconnect_v1_0 -sv \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/258c/hdl/sc_exit_v1_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_29/sim/bd_44e3_m01e_0.sv" \
-endlib
-makelib ies_lib/smartconnect_v1_0 -sv \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/e2dd/hdl/sc_node_v1_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/xil_defaultlib -sv \
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
-endlib
-makelib ies_lib/smartconnect_v1_0 -sv \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/8ad6/hdl/sc_mmu_v1_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_7/sim/bd_44e3_s00mmu_0.sv" \
-endlib
-makelib ies_lib/smartconnect_v1_0 -sv \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/0f5f/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_8/sim/bd_44e3_s00tr_0.sv" \
-endlib
-makelib ies_lib/smartconnect_v1_0 -sv \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/925a/hdl/sc_si_converter_v1_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_9/sim/bd_44e3_s00sic_0.sv" \
-endlib
-makelib ies_lib/smartconnect_v1_0 -sv \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/1b0c/hdl/sc_switchboard_v1_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_2/sim/bd_44e3_arsw_0.sv" \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_3/sim/bd_44e3_rsw_0.sv" \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_4/sim/bd_44e3_awsw_0.sv" \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_5/sim/bd_44e3_wsw_0.sv" \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_6/sim/bd_44e3_bsw_0.sv" \
-endlib
-makelib ies_lib/xlconstant_v1_1_3 \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/0750/hdl/xlconstant_v1_1_vl_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_0/sim/bd_44e3_one_0.v" \
-endlib
-makelib ies_lib/lib_cdc_v1_0_2 \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib ies_lib/proc_sys_reset_v5_0_12 \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/f86a/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/system/ip/system_axi_smc_0/bd_0/ip/ip_1/sim/bd_44e3_psr_aclk_0.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/system/ip/system_axi_smc_0/sim/system_axi_smc_0.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/system/ip/system_rst_ps7_0_100M_0/sim/system_rst_ps7_0_100M_0.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/system/sim/system.v" \
-endlib
-makelib ies_lib/axi_lite_ipif_v3_0_4 \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/cced/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/interrupt_control_v3_1_4 \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/8e66/hdl/interrupt_control_v3_1_vh_rfs.vhd" \
-endlib
-makelib ies_lib/axi_gpio_v2_0_17 \
  "../../../../PLToPS1.srcs/sources_1/bd/system/ipshared/c450/hdl/axi_gpio_v2_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/system/ip/system_axi_gpio_0_0/sim/system_axi_gpio_0_0.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

