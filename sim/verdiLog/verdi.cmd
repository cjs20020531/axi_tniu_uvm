sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sv" "-ntb_opts" "uvm-1.2" "-f" "axi_tniu.f" "-top" "tb_top"
nsMsgSwitchTab -tab general
debLoadSimResult /home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb
wvCreateWindow
nsMsgSwitchTab -tab cmpl
srcHBSelect "tb_top.rknp_vif" -win $_nTrace1
srcHBSelect "tb_top.rknp_vif" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave3 {("G1" 0)}
wvOpenFile -win $_nWave3 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave3
wvSetCursor -win $_nWave3 105041.829710 -snap {("rknp_vif(rknp_if)" 7)}
wvSelectSignal -win $_nWave3 {( "rknp_vif(rknp_if)" 3 )} 
wvSetCursor -win $_nWave3 45499.402174 -snap {("rknp_vif(rknp_if)" 3)}
wvSelectSignal -win $_nWave3 {( "rknp_vif(rknp_if)" 6 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvSelectSignal -win $_nWave3 {( "rknp_vif(rknp_if)" 3 )} 
wvSelectSignal -win $_nWave3 {( "rknp_vif(rknp_if)" 6 )} 
wvSelectSignal -win $_nWave3 {( "rknp_vif(rknp_if)" 3 )} 
