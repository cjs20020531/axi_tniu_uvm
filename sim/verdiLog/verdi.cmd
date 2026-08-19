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
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
srcHBSelect "tb_top.axi_vif" -win $_nTrace1
srcHBSelect "tb_top.axi_vif" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave4 {("G1" 0)}
wvOpenFile -win $_nWave4 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave4
wvSetCursor -win $_nWave4 1460293.740759 -snap {("axi_vif(axi_if)" 33)}
wvSelectSignal -win $_nWave4 {( "axi_vif(axi_if)" 26 )} 
wvScrollDown -win $_nWave4 1
wvSelectSignal -win $_nWave4 {( "axi_vif(axi_if)" 41 )} 
wvSelectSignal -win $_nWave4 {( "axi_vif(axi_if)" 40 )} 
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 3672981.014354 -snap {("axi_vif(axi_if)" 41)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvSelectSignal -win $_nWave4 {( "axi_vif(axi_if)" 44 )} 
wvSelectSignal -win $_nWave4 {( "axi_vif(axi_if)" 39 )} 
wvSelectSignal -win $_nWave4 {( "axi_vif(axi_if)" 38 )} 
verdiWindowBeWindow -win $_nWave4
wvResizeWindow -win $_nWave4 -10 740 2495 600
wvTpfCloseForm -win $_nWave4
wvGetSignalClose -win $_nWave4
wvCloseWindow -win $_nWave4
srcHBSelect "tb_top.axi_vif" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave5 {("G1" 0)}
wvOpenFile -win $_nWave5 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave5
wvSetCursor -win $_nWave5 554908.457157 -snap {("axi_vif(axi_if)" 37)}
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvSetCursor -win $_nWave5 3785480.363554 -snap {("axi_vif(axi_if)" 41)}
wvSelectSignal -win $_nWave5 {( "axi_vif(axi_if)" 39 )} 
wvZoomOut -win $_nWave5
