sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sv" "-ntb_opts" "uvm-1.2" "-f" "axi_tniu.f" "-top" "tb_top"
debLoadSimResult /home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb
wvCreateWindow
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcHBSelect "tb_top.dut.U_ADDR_MAP" -win $_nTrace1
srcHBSelect "tb_top.dut.U_WREQ_TRANS" -win $_nTrace1
srcHBSelect "tb_top.dut.U_WREQ_TRANS" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave3 {("G1" 0)}
wvOpenFile -win $_nWave3 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave3
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 15 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 2776988.347652 -snap {("U_WREQ_TRANS" 0)}
wvSetCursor -win $_nWave3 2878951.202749 -snap {("U_WREQ_TRANS" 0)}
wvSetCursor -win $_nWave3 2920935.907789 -snap {("U_WREQ_TRANS" 3)}
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 3 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 4 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 6 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 5 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 4 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 3 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 8 )} 
wvSetCursor -win $_nWave3 2936825.702718 -snap {("U_WREQ_TRANS" 6)}
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 6 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 5 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 4 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 3 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 7 )} 
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 13 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 8 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 9 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 10 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 10 )} 
wvSetRadix -win $_nWave3 -format UDec
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 18 )} 
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 24 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 16 )} 
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 9 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 16 )} 
wvSetCursor -win $_nWave3 2934201.658653 -snap {("U_WREQ_TRANS" 6)}
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 8 )} 
srcHBSelect "tb_top.rknp_vif" -win $_nTrace1
srcHBSelect "tb_top.rknp_vif" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave4 {("G1" 0)}
wvOpenFile -win $_nWave4 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave4
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 4 )} 
wvSetCursor -win $_nWave4 0.000000
wvSetCursor -win $_nWave4 2928097.943385 -snap {("rknp_vif(rknp_if)" 4)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvSetCursor -win $_nWave4 2926000.000000
wvSetCursor -win $_nWave4 2926000.000000
wvSetCursor -win $_nWave4 2937960.455674 -snap {("rknp_vif(rknp_if)" 1)}
wvSetCursor -win $_nWave4 2915273.746402 -snap {("rknp_vif(rknp_if)" 1)}
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 3 )} 
wvSetCursor -win $_nWave4 2919432.976435 -snap {("rknp_vif(rknp_if)" 1)}
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 7 )} 
wvSetCursor -win $_nWave4 2930398.219250 -snap {("rknp_vif(rknp_if)" 1)}
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ALIGN" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ALIGN" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave5 {("G1" 0)}
wvOpenFile -win $_nWave5 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave5
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 8 )} 
wvSetCursor -win $_nWave5 2883974.902227 -snap {("U_WRAP_ALIGN" 3)}
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvSetCursor -win $_nWave5 2914617.260024 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave5 2930971.161097 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave5 2940392.430194 -snap {("U_WRAP_ALIGN" 1)}
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ALIGN" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_top.dut.genblk1.U_WRAP_ALIGN" -delim "."
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ALIGN" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "wa2reqo_offset_addr" -line 93 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 10)}
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 9)}
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 8)}
wvAddSignal -win $_nWave5 \
           "/tb_top/dut/genblk1/U_WRAP_ALIGN/wa2reqo_offset_addr\[7:0\]"
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 8)}
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 9)}
wvSetCursor -win $_nWave5 2930971.161097 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave5 2920305.573441 -snap {("U_WRAP_ALIGN" 1)}
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 6 )} 
wvSetCursor -win $_nWave5 2940214.670399 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave5 2892041.766152 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvReloadFile -win $_nWave5
wvSetCursor -win $_nWave5 2945547.464228 -snap {("U_WRAP_ALIGN" 8)}
wvSetCursor -win $_nWave5 2944658.665257 -snap {("U_WRAP_ALIGN" 8)}
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 8 )} 
wvSetCursor -win $_nWave5 2920838.852825 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave5 2930437.881715 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave5 2940570.189989 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave5 2937726.033280 -snap {("U_WRAP_ALIGN" 14)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvReloadFile -win $_nWave5
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 10 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 11 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 12 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 10 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 11 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 12 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 11 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 12 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 11 )} 
wvSetCursor -win $_nWave5 2940392.430195 -snap {("U_WRAP_ALIGN" 1)}
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 13 )} 
wvSetCursor -win $_nWave5 2930437.881715 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave5 2940214.670400 -snap {("U_WRAP_ALIGN" 1)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rknp_xx2wa_head_d" -line 138 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 4)}
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 3)}
wvAddSignal -win $_nWave5 "/tb_top/dut/genblk1/U_WRAP_ALIGN/rknp_xx2wa_head_d"
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 3)}
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 4)}
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave5 2880665.139320 -snap {("U_WRAP_ALIGN" 15)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvReloadFile -win $_nWave5
wvSetCursor -win $_nWave5 2939859.150812 -snap {("U_WRAP_ALIGN" 1)}
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 14 )} 
wvZoomOut -win $_nWave5
wvZoomOut -win $_nWave5
wvZoomOut -win $_nWave5
wvSetCursor -win $_nWave5 3430387.303098 -snap {("U_WRAP_ALIGN" 3)}
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 3 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 4 )} 
wvCut -win $_nWave5
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 4)}
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 3)}
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 3 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 4 )} 
wvSetCursor -win $_nWave5 3430458.407016 -snap {("U_WRAP_ALIGN" 1)}
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 6 )} 
wvSetCursor -win $_nWave5 3439701.916318 -snap {("U_WRAP_ALIGN" 1)}
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 13 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 12 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 10 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 11 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 10 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 8 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 9 )} 
wvCut -win $_nWave5
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 3)}
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 8 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 9 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 8 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 9 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 10 )} 
wvSetCursor -win $_nWave5 3440412.955495 -snap {("U_WRAP_ALIGN" 8)}
wvSetCursor -win $_nWave5 3441123.994672 -snap {("U_WRAP_ALIGN" 1)}
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 10 )} 
wvFitSelected -win $_nWave5
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 3)}
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 10 )} 
wvFitSelected -win $_nWave5
wvSetPosition -win $_nWave5 {("U_WRAP_ALIGN" 3)}
wvSetCursor -win $_nWave5 3318114.217038 -snap {("U_WRAP_ALIGN" 10)}
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 10 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 10 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 10 )} 
wvTpfCloseForm -win $_nWave5
wvGetSignalClose -win $_nWave5
wvCloseWindow -win $_nWave5
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ALIGN" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave6 {("G1" 0)}
wvOpenFile -win $_nWave6 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave6
wvSetCursor -win $_nWave6 3299686.738909 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvReloadFile -win $_nWave6
wvSetCursor -win $_nWave6 3251555.165732 -snap {("U_WRAP_ALIGN" 3)}
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvZoomOut -win $_nWave6
wvZoomOut -win $_nWave6
wvZoomOut -win $_nWave6
wvZoomOut -win $_nWave6
wvZoomOut -win $_nWave6
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvSetCursor -win $_nWave6 3378279.868929 -snap {("U_WRAP_ALIGN" 1)}
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvSetCursor -win $_nWave6 3739795.679604 -snap {("U_WRAP_ALIGN" 2)}
wvZoomOut -win $_nWave6
wvZoomOut -win $_nWave6
wvSetCursor -win $_nWave6 3727522.944926 -snap {("U_WRAP_ALIGN" 3)}
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvSetCursor -win $_nWave6 3736000.000000
wvSetCursor -win $_nWave6 3749365.988724 -snap {("U_WRAP_ALIGN" 1)}
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 3 )} 
wvSetCursor -win $_nWave6 3746023.518365 -snap {("U_WRAP_ALIGN" 1)}
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 7 )} 
wvSetCursor -win $_nWave6 3755382.435372 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave6 3745020.777257 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave6 3750368.729832 -snap {("U_WRAP_ALIGN" 1)}
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 6 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 9 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 11 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 10 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 9 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 10 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 9 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 9 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 10 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 12 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 11 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 10 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 11 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 10 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 9 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 10 )} 
wvSetCursor -win $_nWave6 3795324.956168 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave6 3784963.298053 -snap {("U_WRAP_ALIGN" 2)}
verdiDockWidgetSetCurTab -dock windowDock_nWave_4
verdiDockWidgetSetCurTab -dock windowDock_nWave_6
wvZoomOut -win $_nWave6
wvZoomOut -win $_nWave6
wvZoomOut -win $_nWave6
wvZoomOut -win $_nWave6
wvZoomOut -win $_nWave6
wvSetCursor -win $_nWave6 3240859.260581 -snap {("U_WRAP_ALIGN" 3)}
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvSetCursor -win $_nWave6 3750092.061739 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave6 3760286.596336 -snap {("U_WRAP_ALIGN" 1)}
wvSetCursor -win $_nWave6 3809922.281174 -snap {("U_WRAP_ALIGN" 1)}
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 12 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 8 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 10 )} 
wvSelectSignal -win $_nWave6 {( "U_WRAP_ALIGN" 9 )} 
verdiDockWidgetSetCurTab -dock windowDock_nWave_4
verdiDockWidgetSetCurTab -dock windowDock_nWave_6
verdiDockWidgetSetCurTab -dock windowDock_nWave_3
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 2
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 3758901.221941 -snap {("U_WREQ_TRANS" 4)}
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 3 )} 
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvSetCursor -win $_nWave3 3775882.535676 -snap {("U_WREQ_TRANS" 1)}
wvSetCursor -win $_nWave3 3770259.584108 -snap {("U_WREQ_TRANS" 1)}
wvSetCursor -win $_nWave3 3790502.209753 -snap {("U_WREQ_TRANS" 1)}
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 8 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 12 )} 
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 26 )} 
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 27 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 28 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 30 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 29 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 26 )} 
wvSetCursor -win $_nWave3 3796500.024758 -snap {("U_WREQ_TRANS" 26)}
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 27 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 26 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 27 )} 
wvSelectSignal -win $_nWave3 {( "U_WREQ_TRANS" 26 )} 
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 3826489.099787 -snap {("U_WREQ_TRANS" 30)}
srcHBSelect "tb_top.dut.genblk2.U_RSP_ORDER" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk2.U_RSP_ORDER" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk2.U_RSP_TRANS" -win $_nTrace1
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave6
srcHBSelect "tb_top.dut.genblk2.U_RSP_TRANS" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave7 {("G1" 0)}
wvOpenFile -win $_nWave7 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave7
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 12 )} 
wvScrollDown -win $_nWave7 1
wvScrollDown -win $_nWave7 0
wvScrollDown -win $_nWave7 0
wvScrollDown -win $_nWave7 0
wvScrollDown -win $_nWave7 0
wvScrollUp -win $_nWave7 1
wvScrollUp -win $_nWave7 1
wvScrollUp -win $_nWave7 1
wvScrollDown -win $_nWave7 0
wvScrollDown -win $_nWave7 0
wvSetCursor -win $_nWave7 3916337.403375 -snap {("U_RSP_TRANS" 3)}
wvZoomIn -win $_nWave7
wvZoomIn -win $_nWave7
wvZoomIn -win $_nWave7
wvZoomIn -win $_nWave7
wvSetCursor -win $_nWave7 3795914.309931 -snap {("U_RSP_TRANS" 3)}
wvScrollDown -win $_nWave7 1
wvScrollDown -win $_nWave7 1
wvScrollDown -win $_nWave7 1
wvScrollDown -win $_nWave7 0
wvScrollDown -win $_nWave7 0
wvScrollDown -win $_nWave7 0
wvScrollDown -win $_nWave7 0
wvScrollDown -win $_nWave7 0
wvScrollUp -win $_nWave7 3
wvScrollDown -win $_nWave7 3
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 19 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 20 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 19 )} 
wvScrollUp -win $_nWave7 3
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 12 )} 
wvSetCursor -win $_nWave7 3855858.249779 -snap {("U_RSP_TRANS" 13)}
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
wvScrollDown -win $_nWave7 1
wvScrollDown -win $_nWave7 1
wvScrollDown -win $_nWave7 1
wvScrollDown -win $_nWave7 0
wvSetCursor -win $_nWave7 3868168.165998 -snap {("U_RSP_TRANS" 19)}
wvZoomIn -win $_nWave7
wvZoomIn -win $_nWave7
wvSetCursor -win $_nWave7 3886436.795284 -snap {("U_RSP_TRANS" 3)}
wvSetCursor -win $_nWave7 3866098.672836 -snap {("U_RSP_TRANS" 17)}
wvScrollUp -win $_nWave7 1
wvScrollUp -win $_nWave7 1
wvScrollUp -win $_nWave7 1
wvScrollDown -win $_nWave7 1
wvScrollDown -win $_nWave7 1
wvScrollDown -win $_nWave7 1
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 13 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 10 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 11 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 10 )} 
wvScrollUp -win $_nWave7 1
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 12 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 15 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 16 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 17 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 18 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 19 )} 
wvScrollDown -win $_nWave7 1
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 25 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 18 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 17 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 16 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 14 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 15 )} 
verdiDockWidgetSetCurTab -dock windowDock_nWave_3
verdiDockWidgetSetCurTab -dock windowDock_nWave_4
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvDisplayGridCount -win $_nWave7 -off
wvGetSignalClose -win $_nWave7
wvReloadFile -win $_nWave4
wvSetCursor -win $_nWave4 3825395.259918 -snap {("rknp_vif(rknp_if)" 1)}
wvSetCursor -win $_nWave4 3834469.943627 -snap {("rknp_vif(rknp_if)" 1)}
wvSetCursor -win $_nWave4 3829554.489951 -snap {("rknp_vif(rknp_if)" 1)}
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 8 )} 
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 12 )} 
wvSetCursor -win $_nWave4 3820857.918064 -snap {("rknp_vif(rknp_if)" 1)}
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 8 )} 
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 9 )} 
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 8 )} 
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 12 )} 
wvSetCursor -win $_nWave4 3813673.793461 -snap {("rknp_vif(rknp_if)" 1)}
wvSetCursor -win $_nWave4 3809136.451606 -snap {("rknp_vif(rknp_if)" 1)}
wvSetCursor -win $_nWave4 3820479.806242 -snap {("rknp_vif(rknp_if)" 1)}
wvSetCursor -win $_nWave4 3810648.898891 -snap {("rknp_vif(rknp_if)" 1)}
wvSetCursor -win $_nWave4 3820857.918064 -snap {("rknp_vif(rknp_if)" 1)}
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 8 )} 
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 9 )} 
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 8 )} 
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 9 )} 
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 8 )} 
wvSetCursor -win $_nWave4 3810648.898891 -snap {("rknp_vif(rknp_if)" 1)}
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 12 )} 
wvSetCursor -win $_nWave4 3819723.582600 -snap {("rknp_vif(rknp_if)" 1)}
wvSetCursor -win $_nWave4 3810270.787070 -snap {("rknp_vif(rknp_if)" 1)}
wvSetCursor -win $_nWave4 3820857.918064 -snap {("rknp_vif(rknp_if)" 1)}
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 9 )} 
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 10 )} 
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 11 )} 
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 7 )} 
wvSelectSignal -win $_nWave4 {( "rknp_vif(rknp_if)" 8 )} 
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ADJUST" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ADJUST" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave8 {("G1" 0)}
wvOpenFile -win $_nWave8 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave8
wvSelectSignal -win $_nWave8 {( "U_WRAP_ADJUST" 5 )} 
wvZoomIn -win $_nWave8
wvZoomIn -win $_nWave8
wvZoomIn -win $_nWave8
wvSetCursor -win $_nWave8 3876099.011694 -snap {("U_WRAP_ADJUST" 3)}
wvSetCursor -win $_nWave8 3817161.332028 -snap {("U_WRAP_ADJUST" 10)}
wvZoomIn -win $_nWave8
wvZoomIn -win $_nWave8
wvZoomOut -win $_nWave8
wvSetCursor -win $_nWave8 3820346.348050 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave8 3810821.066488 -snap {("U_WRAP_ADJUST" 1)}
verdiDockWidgetSetCurTab -dock windowDock_nWave_6
verdiDockWidgetSetCurTab -dock windowDock_nWave_7
wvScrollUp -win $_nWave7 3
wvScrollDown -win $_nWave7 3
wvScrollUp -win $_nWave7 1
wvScrollUp -win $_nWave7 1
wvScrollUp -win $_nWave7 1
wvScrollDown -win $_nWave7 0
wvScrollDown -win $_nWave7 1
wvScrollDown -win $_nWave7 1
wvScrollDown -win $_nWave7 1
wvScrollUp -win $_nWave7 3
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 5 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 3 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 4 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 3 )} 
wvSetCursor -win $_nWave7 3795093.648850 -snap {("U_RSP_TRANS" 1)}
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 9 )} 
wvSetCursor -win $_nWave7 3790455.129695 -snap {("U_RSP_TRANS" 1)}
wvScrollDown -win $_nWave7 0
wvScrollDown -win $_nWave7 0
wvScrollDown -win $_nWave7 0
wvScrollDown -win $_nWave7 0
wvSetCursor -win $_nWave7 3791882.366358 -snap {("U_RSP_TRANS" 4)}
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
wvSetCursor -win $_nWave7 3550964.817637 -snap {("U_RSP_TRANS" 2)}
wvSetCursor -win $_nWave7 3796449.523680 -snap {("U_RSP_TRANS" 5)}
wvZoomIn -win $_nWave7
wvZoomIn -win $_nWave7
wvZoomIn -win $_nWave7
wvZoomIn -win $_nWave7
wvZoomIn -win $_nWave7
wvZoomOut -win $_nWave7
wvSetCursor -win $_nWave7 3793733.347550 -snap {("U_RSP_TRANS" 3)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvDisplayGridCount -win $_nWave7 -off
wvGetSignalClose -win $_nWave7
wvDisplayGridCount -win $_nWave8 -off
wvGetSignalClose -win $_nWave8
wvReloadFile -win $_nWave7
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 9 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 3 )} 
wvSelectSignal -win $_nWave7 {( "U_RSP_TRANS" 9 )} 
verdiDockWidgetSetCurTab -dock windowDock_nWave_6
verdiDockWidgetSetCurTab -dock windowDock_nWave_4
verdiDockWidgetSetCurTab -dock windowDock_nWave_3
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
verdiDockWidgetSetCurTab -dock windowDock_nWave_3
srcHBSelect "tb_top.axi_vif" -win $_nTrace1
srcHBSelect "tb_top.axi_vif" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave9 {("G1" 0)}
wvOpenFile -win $_nWave9 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave9
wvSetCursor -win $_nWave9 3814112.279370 -snap {("axi_vif(axi_if)" 21)}
wvSetCursor -win $_nWave9 3878958.083193 -snap {("axi_vif(axi_if)" 22)}
wvZoomIn -win $_nWave9
wvZoomIn -win $_nWave9
wvZoomIn -win $_nWave9
wvZoomIn -win $_nWave9
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 33 )} 
wvSetCursor -win $_nWave9 3845577.190579 -snap {("axi_vif(axi_if)" 22)}
wvSetCursor -win $_nWave9 3854419.800191 -snap {("axi_vif(axi_if)" 23)}
wvScrollDown -win $_nWave9 1
wvSetCursor -win $_nWave9 3835997.696832 -snap {("axi_vif(axi_if)" 28)}
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvSetCursor -win $_nWave9 3757519.536524 -snap {("axi_vif(axi_if)" 27)}
wvSetCursor -win $_nWave9 3757519.536524 -snap {("axi_vif(axi_if)" 26)}
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 40 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 38 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 39 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 44 )} 
wvSetCursor -win $_nWave9 3784784.249495 -snap {("axi_vif(axi_if)" 44)}
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvSetCursor -win $_nWave9 3805417.005257 -snap {("axi_vif(axi_if)" 44)}
wvSetCursor -win $_nWave9 3786258.017764 -snap {("axi_vif(axi_if)" 44)}
verdiDockWidgetSetCurTab -dock windowDock_nWave_8
verdiDockWidgetSetCurTab -dock windowDock_nWave_9
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 0
wvScrollUp -win $_nWave9 4
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 28 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 26 )} 
wvSetCursor -win $_nWave9 3765993.704069 -snap {("axi_vif(axi_if)" 26)}
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 30 )} 
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvSetCursor -win $_nWave9 3786994.901898 -snap {("axi_vif(axi_if)" 38)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvDisplayGridCount -win $_nWave7 -off
wvGetSignalClose -win $_nWave7
wvDisplayGridCount -win $_nWave8 -off
wvGetSignalClose -win $_nWave8
wvDisplayGridCount -win $_nWave9 -off
wvGetSignalClose -win $_nWave9
wvReloadFile -win $_nWave9
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvDisplayGridCount -win $_nWave7 -off
wvGetSignalClose -win $_nWave7
wvDisplayGridCount -win $_nWave8 -off
wvGetSignalClose -win $_nWave8
wvDisplayGridCount -win $_nWave9 -off
wvGetSignalClose -win $_nWave9
wvReloadFile -win $_nWave9
wvSetCursor -win $_nWave9 3799521.932182 -snap {("axi_vif(axi_if)" 38)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvDisplayGridCount -win $_nWave7 -off
wvGetSignalClose -win $_nWave7
wvDisplayGridCount -win $_nWave8 -off
wvGetSignalClose -win $_nWave8
wvDisplayGridCount -win $_nWave9 -off
wvGetSignalClose -win $_nWave9
wvReloadFile -win $_nWave9
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 40 )} 
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
wvSetCursor -win $_nWave9 4418000.590219 -snap {("axi_vif(axi_if)" 40)}
wvZoomIn -win $_nWave9
wvZoomIn -win $_nWave9
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvDisplayGridCount -win $_nWave7 -off
wvGetSignalClose -win $_nWave7
wvDisplayGridCount -win $_nWave8 -off
wvGetSignalClose -win $_nWave8
wvDisplayGridCount -win $_nWave9 -off
wvGetSignalClose -win $_nWave9
wvReloadFile -win $_nWave9
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvSetCursor -win $_nWave9 6375803.695897 -snap {("axi_vif(axi_if)" 3)}
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 3 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 5 )} 
wvSetCursor -win $_nWave9 6425916.821248 -snap {("axi_vif(axi_if)" 3)}
wvSetCursor -win $_nWave9 6447884.218662 -snap {("axi_vif(axi_if)" 4)}
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 18 )} 
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 23 )} 
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvZoomOut -win $_nWave9
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvZoomIn -win $_nWave9
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvSetCursor -win $_nWave9 6384041.469927 -snap {("axi_vif(axi_if)" 4)}
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 7 )} 
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 21 )} 
wvSetCursor -win $_nWave9 6445824.775155 -snap {("axi_vif(axi_if)" 21)}
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 22 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 21 )} 
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 7 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 6 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 8 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 9 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 10 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 11 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 12 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 13 )} 
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 3 )} 
wvSetCursor -win $_nWave9 6427289.783586 -snap {("axi_vif(axi_if)" 15)}
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 15 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 16 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 15 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 16 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 17 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 18 )} 
wvSetCursor -win $_nWave9 6448570.699831 -snap {("axi_vif(axi_if)" 4)}
wvSetCursor -win $_nWave9 6428662.745925 -snap {("axi_vif(axi_if)" 16)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvDisplayGridCount -win $_nWave7 -off
wvGetSignalClose -win $_nWave7
wvDisplayGridCount -win $_nWave8 -off
wvGetSignalClose -win $_nWave8
wvDisplayGridCount -win $_nWave9 -off
wvGetSignalClose -win $_nWave9
wvReloadFile -win $_nWave9
wvScrollDown -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
wvScrollUp -win $_nWave9 5
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 23 )} 
wvSetCursor -win $_nWave9 9193355.817875 -snap {("axi_vif(axi_if)" 22)}
wvSetCursor -win $_nWave9 7183338.954469 -snap {("axi_vif(axi_if)" 26)}
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
srcHBSelect "tb_top.dut.U_REQ_ORDER" -win $_nTrace1
srcHBSelect "tb_top.dut.U_REQ_ORDER" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave10 {("G1" 0)}
wvOpenFile -win $_nWave10 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave10
wvSetCursor -win $_nWave10 2795554.269547 -snap {("U_REQ_ORDER" 31)}
wvSelectSignal -win $_nWave10 {( "U_REQ_ORDER" 33 )} 
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollDown -win $_nWave10 0
wvScrollDown -win $_nWave10 0
wvScrollDown -win $_nWave10 0
wvScrollDown -win $_nWave10 0
wvScrollDown -win $_nWave10 0
wvScrollDown -win $_nWave10 0
wvScrollDown -win $_nWave10 0
wvScrollDown -win $_nWave10 0
wvScrollDown -win $_nWave10 0
wvSetCursor -win $_nWave10 5456921.934156 -snap {("U_REQ_ORDER" 4)}
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollUp -win $_nWave10 1
wvScrollDown -win $_nWave10 0
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 1
wvScrollDown -win $_nWave10 0
wvScrollDown -win $_nWave10 0
srcHBSelect "tb_top.dut.U_RREQ_TRANS" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk2.U_RSP_ORDER" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk2.U_RSP_ORDER" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave11 {("G1" 0)}
wvOpenFile -win $_nWave11 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave11
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 66 )} 
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 0
wvScrollDown -win $_nWave11 0
wvScrollDown -win $_nWave11 0
wvScrollDown -win $_nWave11 0
wvScrollDown -win $_nWave11 0
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvSetCursor -win $_nWave11 5449661.884380 -snap {("U_RSP_ORDER" 46)}
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 56 )} 
wvScrollUp -win $_nWave11 33
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 14 )} 
wvScrollUp -win $_nWave11 5
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 10 )} 
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 10 )} 
wvSetCursor -win $_nWave11 5437578.376876 -snap {("U_RSP_ORDER" 10)}
wvZoomIn -win $_nWave11
wvZoomIn -win $_nWave11
wvZoomIn -win $_nWave11
wvZoomIn -win $_nWave11
wvZoomIn -win $_nWave11
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollDown -win $_nWave11 7
wvScrollDown -win $_nWave11 16
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 32 )} 
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 33 )} 
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 35 )} 
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 36 )} 
wvSetCursor -win $_nWave11 5695438.538966 -snap {("U_RSP_ORDER" 36)}
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 38 )} 
wvSetCursor -win $_nWave11 5704878.779204 -snap {("U_RSP_ORDER" 36)}
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 32 )} 
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 33 )} 
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 34 )} 
wvSetCursor -win $_nWave11 5676746.863296 -snap {("U_RSP_ORDER" 34)}
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 44 )} 
wvSetCursor -win $_nWave11 5736031.571988 -snap {("U_RSP_ORDER" 44)}
wvSetCursor -win $_nWave11 5725269.698117 -snap {("U_RSP_ORDER" 44)}
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvSetCursor -win $_nWave11 5765824.970178 -snap {("U_RSP_ORDER" 36)}
wvScrollUp -win $_nWave11 1
wvScrollDown -win $_nWave11 3
verdiDockWidgetSetCurTab -dock windowDock_nWave_10
verdiDockWidgetSetCurTab -dock windowDock_nWave_9
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
wvScrollDown -win $_nWave9 0
verdiDockWidgetSetCurTab -dock windowDock_nWave_11
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvSetCursor -win $_nWave11 5696184.317946 -snap {("U_RSP_ORDER" 36)}
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvSetCursor -win $_nWave11 5805313.495093 -snap {("U_RSP_ORDER" 44)}
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 36 )} 
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 44 )} 
wvSetCursor -win $_nWave11 5695995.513141 -snap {("U_RSP_ORDER" 36)}
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
wvScrollUp -win $_nWave11 1
verdiDockWidgetSetCurTab -dock windowDock_nWave_10
verdiDockWidgetSetCurTab -dock windowDock_nWave_9
verdiDockWidgetSetCurTab -dock windowDock_nWave_8
verdiDockWidgetSetCurTab -dock windowDock_nWave_7
verdiDockWidgetSetCurTab -dock windowDock_nWave_8
wvTpfCloseForm -win $_nWave8
wvGetSignalClose -win $_nWave8
wvCloseWindow -win $_nWave8
wvSetCursor -win $_nWave9 5700539.629005 -snap {("axi_vif(axi_if)" 3)}
wvZoomIn -win $_nWave9
wvZoomIn -win $_nWave9
wvZoomIn -win $_nWave9
wvZoomIn -win $_nWave9
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
wvZoomIn -win $_nWave9
wvSetCursor -win $_nWave9 5544468.135188 -snap {("axi_vif(axi_if)" 1)}
wvZoomIn -win $_nWave9
wvSetCursor -win $_nWave9 5483371.311130 -snap {("axi_vif(axi_if)" 5)}
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 5 )} 
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 18 )} 
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 23 )} 
wvSetCursor -win $_nWave9 5807459.071107 -snap {("axi_vif(axi_if)" 23)}
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 21 )} 
wvSelectSignal -win $_nWave9 {( "axi_vif(axi_if)" 22 )} 
wvSetCursor -win $_nWave9 6755043.353007 -snap {("axi_vif(axi_if)" 22)}
wvSetCursor -win $_nWave9 6763967.608207 -snap {("axi_vif(axi_if)" 21)}
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollDown -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvScrollUp -win $_nWave9 1
wvZoom -win $_nWave9 6757630.304467 6761749.191482
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
wvZoomOut -win $_nWave9
verdiDockWidgetSetCurTab -dock windowDock_nWave_11
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 36 )} 
wvSetCursor -win $_nWave11 6766254.429362 -snap {("U_RSP_ORDER" 36)}
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvScrollDown -win $_nWave11 1
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 44 )} 
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 45 )} 
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 35 )} 
wvSelectSignal -win $_nWave11 {( "U_RSP_ORDER" 36 )} 
wvSetCursor -win $_nWave11 5806946.656653 -snap {("U_RSP_ORDER" 34)}
