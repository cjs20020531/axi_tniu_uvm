sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sv" "-ntb_opts" "uvm-1.2" "-f" "axi_tniu.f" "-top" "tb_top"
nsMsgSwitchTab -tab general
debLoadSimResult /home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb
wvCreateWindow
nsMsgSwitchTab -tab cmpl
debExit
