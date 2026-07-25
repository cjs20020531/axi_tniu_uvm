sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sv" "-ntb_opts" "uvm-1.2" "-f" "axi_tniu.f" "-top" "tb_top"
debLoadSimResult /home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb
wvCreateWindow
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ADJUST" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ALIGN" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ALIGN" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ADJUST" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ADJUST" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave3 {("G1" 0)}
wvOpenFile -win $_nWave3 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave3
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 4 )} 
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ADJUST" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_top.dut.genblk1.U_WRAP_ADJUST" -delim "."
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ADJUST" -win $_nTrace1
wvSetCursor -win $_nWave3 7325568.398606 -snap {("U_WRAP_ADJUST" 7)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_opc" -line 73 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 6)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 5)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 4)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 5)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 6)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 7)}
wvAddSignal -win $_nWave3 "/tb_top/dut/genblk1/U_WRAP_ADJUST/rspo2wad_opc\[1:0\]"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 7)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 8)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_lw" -line 74 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 9)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 8)}
wvAddSignal -win $_nWave3 "/tb_top/dut/genblk1/U_WRAP_ADJUST/rspo2wad_lw"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 8)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 9)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_status" -line 75 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 8)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 9)}
wvAddSignal -win $_nWave3 \
           "/tb_top/dut/genblk1/U_WRAP_ADJUST/rspo2wad_status\[1:0\]"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 9)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 10)}
wvSetCursor -win $_nWave3 7319699.002844 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7330083.318423 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 9 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 16 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 9 )} 
wvSetCursor -win $_nWave3 7320963.180393 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7321414.672374 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 17 )} 
wvSetCursor -win $_nWave3 7329993.020026 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7341280.319568 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7620302.364242 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7630235.187838 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7354825.079018 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7339925.843623 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 9 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 17 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvSetCursor -win $_nWave3 7857109.908629 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7849886.036922 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7859367.368537 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7848983.052959 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7799318.934975 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 17 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 4 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 9 )} 
wvSetCursor -win $_nWave3 7811509.218480 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 17 )} 
wvSetCursor -win $_nWave3 7800673.410920 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7815121.154333 -snap {("U_WRAP_ADJUST" 14)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvSetCursor -win $_nWave3 7801124.902901 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 17 )} 
wvSetCursor -win $_nWave3 7810154.742535 -snap {("U_WRAP_ADJUST" 1)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_lw_d" -line 78 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 8)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 7)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 6)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 7)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 8)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 9)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 10)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 11)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 12)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 13)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 14)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 15)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 16)}
wvAddSignal -win $_nWave3 "/tb_top/dut/genblk1/U_WRAP_ADJUST/rspo2wad_lw_d"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 16)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 17)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_axid_d" -line 79 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "lw_offset_body" -line 227 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 15)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 16)}
wvAddSignal -win $_nWave3 \
           "/tb_top/dut/genblk1/U_WRAP_ADJUST/lw_offset_body\[9:0\]"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 16)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 17)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 17 )} 
wvSetRadix -win $_nWave3 -format UDec
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rwrap_buff_index" -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 1)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 17)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 16)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 15)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 13)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 12)}
wvAddSignal -win $_nWave3 \
           "/tb_top/dut/genblk1/U_WRAP_ADJUST/rwrap_buff_index\[1:0\]"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 12)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 13)}
srcDeselectAll -win $_nTrace1
srcSelect -signal \
          "rwrap_buffer\[rwrap_buff_index\]\[BUFF_BODY_OFFSET +: NBYTEPERWORD*9\]" \
          -line 236 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 0)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 2)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 3)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 17)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 13)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 12)}
wvAddSignal -win $_nWave3 "/tb_top/dut/genblk1/U_WRAP_ADJUST/rwrap_buffer\[3:0\]"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 12)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 13)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 13 )} 
wvExpandBus -win $_nWave3 {("U_WRAP_ADJUST" 13)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 15 )} 
wvSetCursor -win $_nWave3 7638542.640301 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 24 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 18 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 15 )} 
wvSetCursor -win $_nWave3 7319653.853646 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 16 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 17 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 18 )} 
wvSetCursor -win $_nWave3 7337262.040931 -snap {("U_WRAP_ADJUST" 18)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 17 )} 
wvSetCursor -win $_nWave3 7318750.869683 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7315590.425811 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7325071.757426 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7329586.677243 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 18 )} 
wvSetCursor -win $_nWave3 7319202.361664 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 8 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 18 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 12 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rwrap_buff_index_hot" -line 154 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 13)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 12)}
wvAddSignal -win $_nWave3 \
           "/tb_top/dut/genblk1/U_WRAP_ADJUST/rwrap_buff_index_hot\[3:0\]"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 12)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 13)}
srcDeselectAll -win $_nTrace1
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 12 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 13 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "idle_rwrap_buff_index\[j\]" -line 147 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 17)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 12)}
wvAddSignal -win $_nWave3 \
           "/tb_top/dut/genblk1/U_WRAP_ADJUST/idle_rwrap_buff_index\[1:0\]"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 12)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 13)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 14 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 13 )} 
wvSetCursor -win $_nWave3 7325071.757426 -snap {("U_WRAP_ADJUST" 19)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 12 )} 
wvSetCursor -win $_nWave3 7636510.926384 -snap {("U_WRAP_ADJUST" 12)}
wvSetCursor -win $_nWave3 7795887.595914 -snap {("U_WRAP_ADJUST" 10)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 3 )} 
wvSetCursor -win $_nWave3 7646895.241962 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7800854.007712 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7810335.339327 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 26 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 14 )} 
wvSetCursor -win $_nWave3 7647166.137151 -snap {("U_WRAP_ADJUST" 17)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 13 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 3 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 11 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 10 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 12 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 6 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvSetCursor -win $_nWave3 7800673.410920 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 7809703.250553 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 27 )} 
wvSetCursor -win $_nWave3 7636330.329591 -snap {("U_WRAP_ADJUST" 12)}
wvSetCursor -win $_nWave3 7630912.425811 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 9 )} 
wvSetCursor -win $_nWave3 7642199.725353 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 27 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_tail_d" -line 269 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rrsp_head_d" -line 270 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 17)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 26)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 25)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 24)}
wvAddSignal -win $_nWave3 "/tb_top/dut/genblk1/U_WRAP_ADJUST/rrsp_head_d\[83:0\]"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 24)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 25)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_offset_addr_d" -line 269 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 7)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 8)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 9)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 10)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 11)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 17)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 24)}
wvAddSignal -win $_nWave3 \
           "/tb_top/dut/genblk1/U_WRAP_ADJUST/rspo2wad_offset_addr_d\[7:0\]"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 24)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 25)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave3 7636781.821573 -snap {("U_WRAP_ADJUST" 27)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvSetCursor -win $_nWave3 7640393.757426 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollUp -win $_nWave3 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rrsp_head_d" -line 270 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 25 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 28 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 8 28 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 8 11 28 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 8 10 11 28 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 8 10 28 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 8 28 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 8 25 28 )} 
verdiHighlightSignal -sigColor { "tb_top.dut.genblk1.U_WRAP_ADJUST.rspo2wad_opc" \
           N/A } { "tb_top.dut.genblk1.U_WRAP_ADJUST.rspo2wad_offset_addr_d" \
           N/A } { "tb_top.dut.genblk1.U_WRAP_ADJUST.rspo2wad_lw_d" N/A }
verdiHighlightSignal -sigColor { "tb_top.dut.genblk1.U_WRAP_ADJUST.rspo2wad_opc" \
           ID_YELLOW5 } { \
           "tb_top.dut.genblk1.U_WRAP_ADJUST.rspo2wad_offset_addr_d" \
           ID_YELLOW5 } { "tb_top.dut.genblk1.U_WRAP_ADJUST.rspo2wad_lw_d" \
           ID_YELLOW5 }
verdiHighlightSignal -apply
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_opc_d" -line 269 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rrsp_head_d" -line 270 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_head" -line 266 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 6 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 10 )} 
wvSetCursor -win $_nWave3 7637684.805536 -snap {("U_WRAP_ADJUST" 26)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvSetCursor -win $_nWave3 7639942.265444 -snap {("U_WRAP_ADJUST" 1)}
wvScrollUp -win $_nWave3 1
wvSetCursor -win $_nWave3 7635878.837609 -snap {("U_WRAP_ADJUST" 26)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvSetCursor -win $_nWave3 7641296.741389 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ALIGN" -win $_nTrace1
srcHBSelect "tb_top.axi_vif" -win $_nTrace1
srcHBSelect "tb_top.axi_vif" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave4 {("G1" 0)}
wvOpenFile -win $_nWave4 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave4
wvSelectSignal -win $_nWave4 {( "axi_vif(axi_if)" 23 )} 
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvSelectSignal -win $_nWave4 {( "axi_vif(axi_if)" 18 )} 
wvSetCursor -win $_nWave4 4161051.451775 -snap {("axi_vif(axi_if)" 18)}
wvScrollDown -win $_nWave4 0
wvSelectSignal -win $_nWave4 {( "axi_vif(axi_if)" 28 )} 
wvSetCursor -win $_nWave4 7161468.254201 -snap {("axi_vif(axi_if)" 28)}
wvSetCursor -win $_nWave4 7249530.801862 -snap {("axi_vif(axi_if)" 28)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvSetCursor -win $_nWave4 7227790.360408 -snap {("axi_vif(axi_if)" 28)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 3
wvSelectSignal -win $_nWave4 {( "axi_vif(axi_if)" 40 )} 
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 8155120.438181 -snap {("axi_vif(axi_if)" 40)}
wvZoomIn -win $_nWave4
verdiDockWidgetSetCurTab -dock windowDock_nWave_3
wvSetCursor -win $_nWave3 8160512.520313 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 12 )} 
wvSetCursor -win $_nWave3 8176766.231653 -snap {("U_WRAP_ADJUST" 11)}
wvSetCursor -win $_nWave3 8076986.503703 -snap {("U_WRAP_ADJUST" 11)}
wvSetCursor -win $_nWave3 8081049.931538 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 27 )} 
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 12 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 5 )} 
wvSetCursor -win $_nWave3 8178572.199579 -snap {("U_WRAP_ADJUST" 12)}
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8181732.643451 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 30 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 25 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ALIGN" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk1.U_WRAP_ALIGN" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave5 {("G1" 0)}
wvOpenFile -win $_nWave5 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave5
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 8 )} 
wvSetCursor -win $_nWave5 7250984.209669 -snap {("U_WRAP_ALIGN" 3)}
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvSetCursor -win $_nWave5 7147963.751918 -snap {("U_WRAP_ALIGN" 1)}
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvZoomIn -win $_nWave5
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 13 )} 
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 12 )} 
wvZoomOut -win $_nWave5
wvSetCursor -win $_nWave5 7179550.038659 -snap {("U_WRAP_ALIGN" 1)}
wvSelectSignal -win $_nWave5 {( "U_WRAP_ALIGN" 13 )} 
verdiDockWidgetSetCurTab -dock windowDock_nWave_4
verdiDockWidgetSetCurTab -dock windowDock_nWave_5
verdiDockWidgetSetCurTab -dock windowDock_nWave_4
verdiDockWidgetSetCurTab -dock windowDock_nWave_3
wvSetCursor -win $_nWave3 8174960.263726 -snap {("U_WRAP_ADJUST" 25)}
wvSetCursor -win $_nWave3 8178572.199579 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 11 )} 
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 6 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8060281.300381 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8141549.857082 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 7810606.234516 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 30 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvReloadFile -win $_nWave3
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8170445.343909 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 12 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8178572.199579 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 22 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 23 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 24 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 9 )} 
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_offset_addr" -line 266 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 11 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_data\[RSP_USER_OFFSET +: USER_WITH+4\]" -line 267 \
          -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvReloadFile -win $_nWave3
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 9 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 25 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 26 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 27 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 28 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 28 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_lw" -line 274 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 9 )} 
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 9)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 10)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 11)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 12)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 13)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 14)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 15)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 16)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 17)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 18)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 19)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 20)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 21)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 22)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 23)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 24)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 25)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 26)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 27)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 28)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 28)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "wad2rknp_xx_data\[RSP_HEAD_LEN_OFFSET\]" -line 274 -pos 1 -win \
          $_nTrace1
srcDeselectAll -win $_nTrace1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 7 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_offset_addr" -line 266 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 1)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 0)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 25)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 26)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 27)}
wvAddSignal -win $_nWave3 \
           "/tb_top/dut/genblk1/U_WRAP_ADJUST/rspo2wad_offset_addr\[7:0\]"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 27)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 28)}
wvScrollDown -win $_nWave3 4
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_status" -line 266 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 9 )} 
srcDeselectAll -win $_nTrace1
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvReloadFile -win $_nWave3
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 30 )} 
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 3 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 11 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 8 )} 
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
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 30 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 30 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 30 )} 
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 19 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 20 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 22 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 20 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 20 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 20 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSetCursor -win $_nWave3 8172251.311836 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 22 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 20 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 22 )} 
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 30 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 7 )} 
wvScrollUp -win $_nWave3 5
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 11 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8181732.643451 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 8170445.343909 -snap {("U_WRAP_ADJUST" 1)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 7 )} 
srcHBSelect "tb_top.dut.genblk2.U_RSP_ORDER" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk2.U_RSP_TRANS" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk2.U_RSP_TRANS" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave6 {("G1" 0)}
wvOpenFile -win $_nWave6 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave6
wvSetCursor -win $_nWave6 7880608.553001 -snap {("U_RSP_TRANS" 7)}
wvSetCursor -win $_nWave6 0.000000
wvSetCursor -win $_nWave6 8076096.517106 -snap {("U_RSP_TRANS" 3)}
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvZoomIn -win $_nWave6
wvSelectSignal -win $_nWave6 {( "U_RSP_TRANS" 5 )} 
wvSetCursor -win $_nWave6 8147343.101114 -snap {("U_RSP_TRANS" 5)}
wvSelectSignal -win $_nWave6 {( "U_RSP_TRANS" 3 )} 
wvSelectSignal -win $_nWave6 {( "U_RSP_TRANS" 4 )} 
wvSelectSignal -win $_nWave6 {( "U_RSP_TRANS" 5 )} 
wvSelectSignal -win $_nWave6 {( "U_RSP_TRANS" 6 )} 
wvSetCursor -win $_nWave6 8154979.349711 -snap {("U_RSP_TRANS" 5)}
wvSetCursor -win $_nWave6 8146579.476254 -snap {("U_RSP_TRANS" 5)}
wvSetCursor -win $_nWave6 8151924.850272 -snap {("U_RSP_TRANS" 5)}
wvSelectSignal -win $_nWave6 {( "U_RSP_TRANS" 15 )} 
wvSelectSignal -win $_nWave6 {( "U_RSP_TRANS" 16 )} 
wvSelectSignal -win $_nWave6 {( "U_RSP_TRANS" 17 )} 
wvSetCursor -win $_nWave6 8165670.097748 -snap {("U_RSP_TRANS" 19)}
wvSetCursor -win $_nWave6 8157270.224291 -snap {("U_RSP_TRANS" 19)}
wvSetCursor -win $_nWave6 8161851.973450 -snap {("U_RSP_TRANS" 19)}
wvSetCursor -win $_nWave6 8155742.974571 -snap {("U_RSP_TRANS" 19)}
wvSetCursor -win $_nWave6 8164906.472889 -snap {("U_RSP_TRANS" 19)}
wvSelectSignal -win $_nWave6 {( "U_RSP_TRANS" 15 )} 
wvSelectSignal -win $_nWave6 {( "U_RSP_TRANS" 16 )} 
wvSelectSignal -win $_nWave6 {( "U_RSP_TRANS" 17 )} 
verdiDockWidgetSetCurTab -dock windowDock_nWave_5
verdiDockWidgetSetCurTab -dock windowDock_nWave_3
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvSetCursor -win $_nWave3 8175411.755708 -snap {("U_WRAP_ADJUST" 21)}
wvSetCursor -win $_nWave3 8166833.408056 -snap {("U_WRAP_ADJUST" 22)}
wvSetCursor -win $_nWave3 8176314.739671 -snap {("U_WRAP_ADJUST" 21)}
wvSetCursor -win $_nWave3 8167284.900038 -snap {("U_WRAP_ADJUST" 21)}
wvSetCursor -win $_nWave3 8165930.424093 -snap {("U_WRAP_ADJUST" 20)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "wad2rknp_xx_tail" -line 286 -pos 1 -win $_nTrace1
wvScrollDown -win $_nWave3 2
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 23 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_tail_d" -line 286 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 4)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 3)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 2)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 3)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 25)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 24)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 25)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 26)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 27)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 26)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 25)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 24)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 25)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 26)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 27)}
wvAddSignal -win $_nWave3 "/tb_top/dut/genblk1/U_WRAP_ADJUST/rspo2wad_tail_d"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 27)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 28)}
wvScrollDown -win $_nWave3 3
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 8 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_offset_addr_d" -line 286 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 10 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_opc_d" -line 286 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_offset_addr" -line 286 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 24 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 11 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 9 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 10 )} 
verdiHighlightSignal -sigColor { \
           "tb_top.dut.genblk1.U_WRAP_ADJUST.rspo2wad_offset_addr" N/A }
verdiHighlightSignal -sigColor { \
           "tb_top.dut.genblk1.U_WRAP_ADJUST.rspo2wad_offset_addr" ID_RED6 }
verdiHighlightSignal -sigColor { \
           "tb_top.dut.genblk1.U_WRAP_ADJUST.rspo2wad_offset_addr" ID_RED5 }
verdiHighlightSignal -apply
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
wvCut -win $_nWave3
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 28)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 27 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvReloadFile -win $_nWave3
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 20 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 22 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8190762.483085 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 30 )} 
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 27 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 4 )} 
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 27 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvReloadFile -win $_nWave3
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSetCursor -win $_nWave3 8201146.798663 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 30 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 9 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 11 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8179926.675524 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 24 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 30 )} 
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 30)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 29)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 28)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 27)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 26)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 25)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 24)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 23)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 24)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 25)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 24)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 23)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 22)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 21)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 20)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 20)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 21)}
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8186247.563268 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 8192116.959030 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8201598.290645 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8180378.167506 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 26 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 25 )} 
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 26 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8200695.306681 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSetCursor -win $_nWave3 8189859.499121 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvZoomIn -win $_nWave3
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8199905.195713 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 8170332.470914 -snap {("U_WRAP_ADJUST" 1)}
wvSetCursor -win $_nWave3 8181168.278474 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
srcDeselectAll -win $_nTrace1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSetCursor -win $_nWave3 8169655.232941 -snap {("U_WRAP_ADJUST" 2)}
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvSetCursor -win $_nWave3 8083662.113894 -snap {("U_WRAP_ADJUST" 6)}
wvSetCursor -win $_nWave3 8145065.023401 -snap {("U_WRAP_ADJUST" 7)}
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomOut -win $_nWave3
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8178069.087261 -snap {("U_WRAP_ADJUST" 25)}
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSetCursor -win $_nWave3 8179875.055188 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 28 )} 
wvScrollUp -win $_nWave3 5
wvScrollDown -win $_nWave3 5
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_head" -line 266 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_tail_d" -line 269 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_tail_d" -line 269 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 26)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 27)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 28)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 27)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 21)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 5)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 4)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 3)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 2)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 1)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 0)}
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 29 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_opc_d" -line 269 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_offset_addr_d" -line 269 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 25 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 28 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_lw" -line 274 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 4)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 7)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 8)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 9)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 21)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 28)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 29)}
wvAddSignal -win $_nWave3 "/tb_top/dut/genblk1/U_WRAP_ADJUST/rspo2wad_lw"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 29)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 30)}
wvScrollDown -win $_nWave3 2
wvCut -win $_nWave3
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 30)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 29)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 30 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 7 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSetCursor -win $_nWave3 8170393.723573 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 8 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 9 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 10 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 11 )} 
wvScrollDown -win $_nWave3 3
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 12 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 11 )} 
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 26 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 27 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 24 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 22 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 23 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 19 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 20 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 7 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8188904.894821 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8200192.194363 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvSetCursor -win $_nWave3 8188453.402840 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8181229.531133 -snap {("U_WRAP_ADJUST" 2)}
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvSetCursor -win $_nWave3 7174224.942726 -snap {("U_WRAP_ADJUST" 7)}
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8183123.212137 -snap {("U_WRAP_ADJUST" 10)}
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8194704.505093 -snap {("U_WRAP_ADJUST" 9)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 21)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 22)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 23)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 23)}
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8184570.873757 -snap {("U_WRAP_ADJUST" 25)}
wvSetCursor -win $_nWave3 8194704.505093 -snap {("U_WRAP_ADJUST" 25)}
wvSetCursor -win $_nWave3 8186501.089249 -snap {("U_WRAP_ADJUST" 25)}
wvSetCursor -win $_nWave3 8195187.058966 -snap {("U_WRAP_ADJUST" 25)}
wvSetCursor -win $_nWave3 8188431.304742 -snap {("U_WRAP_ADJUST" 25)}
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8176850.011786 -snap {("U_WRAP_ADJUST" 21)}
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvSetCursor -win $_nWave3 8185053.427630 -snap {("U_WRAP_ADJUST" 10)}
wvSetCursor -win $_nWave3 8173954.688548 -snap {("U_WRAP_ADJUST" 10)}
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 8178780.227279 -snap {("U_WRAP_ADJUST" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 25 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 25 26 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 25 26 27 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 25 26 27 28 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 25 26 27 28 29 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 25 26 27 28 29 30 )} 
wvCut -win $_nWave3
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 23)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvReloadFile -win $_nWave3
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 11 )} 
wvSetCursor -win $_nWave3 8194704.505094 -snap {("U_WRAP_ADJUST" 7)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 20 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 21 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_lw_d" -line 235 -pos 1 -win $_nTrace1
srcSelect -win $_nTrace1 -range {235 255 4 1 7 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rspo2wad_lw_d" -line 235 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 19)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 20)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 21)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 22)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 21)}
wvAddSignal -win $_nWave3 "/tb_top/dut/genblk1/U_WRAP_ADJUST/rspo2wad_lw_d"
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 21)}
wvSetPosition -win $_nWave3 {("U_WRAP_ADJUST" 22)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvReloadFile -win $_nWave3
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvReloadFile -win $_nWave3
wvSetCursor -win $_nWave3 7812893.422773 -snap {("U_WRAP_ADJUST" 19)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvReloadFile -win $_nWave3
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvReloadFile -win $_nWave3
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvDisplayGridCount -win $_nWave5 -off
wvGetSignalClose -win $_nWave5
wvDisplayGridCount -win $_nWave6 -off
wvGetSignalClose -win $_nWave6
wvReloadFile -win $_nWave3
wvSetCursor -win $_nWave3 0.001718 -snap {("U_WRAP_ADJUST" 7)}
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvSetCursor -win $_nWave3 8099700.206186 -snap {("U_WRAP_ADJUST" 7)}
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 6 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 24 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 19 )} 
wvSelectSignal -win $_nWave3 {( "U_WRAP_ADJUST" 20 )} 
srcHBSelect "tb_top.dut.genblk2.U_RSP_ORDER" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk2.U_ELY_RSP_DETECT" -win $_nTrace1
srcHBSelect "tb_top.dut.genblk2.U_RSP_TRANS" -win $_nTrace1
srcHBSelect "tb_top.rknp_vif" -win $_nTrace1
srcHBSelect "tb_top.rknp_vif" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave7 {("G1" 0)}
wvOpenFile -win $_nWave7 {/home/ICer/RKNoC/axi_tniu_uvm/sim/wave.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave7
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
wvSelectSignal -win $_nWave7 {( "rknp_vif(rknp_if)" 11 )} 
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
wvZoomOut -win $_nWave7
