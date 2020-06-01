
 add_fsm_encoding \
       {axi_emc_native_interface.emc_addr_ps} \
       { }  \
       {{000 000} {001 010} {010 001} {011 011} {100 100} {110 101} {111 110} }

 add_fsm_encoding \
       {mem_state_machine.crnt_state} \
       { }  \
       {{00000 00000} {00001 00011} {00010 00001} {00011 00010} {00100 01010} {00101 01011} {00110 00100} {00111 01000} {01000 00110} {01001 00101} {01010 01001} {01011 00111} {01100 01101} {01101 01100} {01110 01110} {01111 01111} {10000 10000} }

 add_fsm_encoding \
       {sc_exit_v1_0_6_null_bt_supress.state} \
       { }  \
       {{000 000} {001 011} {010 100} {011 101} {100 001} {101 010} }

 add_fsm_encoding \
       {sc_transaction_regulator_v1_0_6_multithread.state} \
       { }  \
       {{00000000000000000000000000000000 000} {00000000000000000000000000000001 001} {00000000000000000000000000000010 011} {00000000000000000000000000000011 010} {00000000000000000000000000000100 101} {00000000000000000000000000000101 100} }

 add_fsm_encoding \
       {Monopulse_extraction_1.PositionState} \
       { }  \
       {{000 00} {001 01} {010 10} {011 11} }
