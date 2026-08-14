gui_exclusion -set_force true
gui_assert_mode -mode flat
gui_class_mode -mode hier
gui_excl_mgr_flat_list -on  0
gui_covdetail_select -id  CovDetail.1   -name   Line
verdiWindowWorkMode -win $_vdCoverage_1 -coverageAnalysis
gui_open_cov  -hier cov.vdb -testdir {} -test {cov/test_norm_mix_1 cov/test_watchdog_1023_1 cov/test_watchdog_1024_1 cov/test_watchdog_1100_1 cov/test_watchdog_normal_timeout_1 cov/test_watchdog_bufferable_1100_1 cov/test_norm_mix_stresstest_1 cov/test_tag_name_toggle_1 cov/test_err_rd_1 cov/test_err_wr_1 cov/test_err_rdw_1 cov/test_err_wrw_1 cov/test_err_mix_1 cov/test_err_mix_fixordkey_1 cov/test_buff_wr_1 cov/test_buff_wrw_1 cov/test_buff_mix_1 cov/test_buff_mix_fixordkey_1 cov/test_buff_err_mix_1 cov/test_addrol_waw_1 cov/test_addrol_raw_1 cov/test_axi_rsp_error_mix_1 cov/test_mix_1 cov/test_aresetn_recovery_1 cov/test_norm_rd_1 cov/test_norm_wr_1 cov/test_norm_rdw_1 cov/test_norm_rdw_narrow_noalign_1 cov/test_norm_wrw_1 cov/test_norm_wrw_narrow_noalign_1 cov/test_rwrap_stresstest_1} -merge MergedTest -db_max_tests 10 -fsm transition
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ALIGN   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk1.U_WRAP_ALIGN  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {rknp_xx2wa_data[174:0]}  {opc[3:0]}   }
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk1.U_WRAP_ALIGN  -column {Condition} 
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk1.U_WRAP_ALIGN  -column {Branch} 
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk1.U_WRAP_ALIGN  -column {Condition} 
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_src_highlight_item -id CovSrc.1 -lfrom 106 -idxfrom 0 -fileIdFrom 0 -lto 109 -idxto 59 -fileIdTo 0 -selection {assign unaligned_rwrap_head = rknp_xx2wa_valid
                            && rknp_xx2wa_head
                            && (opc == RDW)
                            && (wa2reqo_offset_addr != 8'd0} -selectionId 0 -replace 0
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_src_highlight_item -id CovSrc.1 -lfrom 107 -idxfrom 31 -fileIdFrom 0 -lto 107 -idxto 46 -fileIdTo 0 -selection {rknp_xx2wa_head} -selectionId 0 -replace 0
gui_src_highlight_item -id CovSrc.1 -lfrom 106 -idxfrom 30 -fileIdFrom 0 -lto 106 -idxto 46 -fileIdTo 0 -selection {rknp_xx2wa_valid} -selectionId 0 -replace 0
gui_list_select -id CovDetail.1 -list cond { {(rknp_xx2wa_valid && rknp_xx2wa_head && (opc == RDW) && (wa2reqo_offset_addr != 8'b0))}  {((opc == WRW) && (wa2reqo_offset_addr != 8'b0) && (rknp_xx2wa_head_d == 1'b1))}   }
gui_list_action -id  CovDetail.1 -list {cond} {((opc == WRW) && (wa2reqo_offset_addr != 8'b0) && (rknp_xx2wa_head_d == 1'b1))}
gui_list_select -id CovDetail.1 -list vector { 011   }
gui_list_select -id CovDetail.1 -list cond { {((opc == WRW) && (wa2reqo_offset_addr != 8'b0) && (rknp_xx2wa_head_d == 1'b1))}  {((opc == WRW) && (offset_addr != 8'b0) && (rknp_xx2wa_head_d == 1'b1))}   }
gui_list_select -id CovDetail.1 -list cond { {((opc == WRW) && (offset_addr != 8'b0) && (rknp_xx2wa_head_d == 1'b1))}  {((opc == WRW) && (wa2reqo_offset_addr != 8'b0) && (rknp_xx2wa_head_d == 1'b1))}   }
gui_list_select -id CovDetail.1 -list vector { 011   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_exclude_items -id  CovDetail.1  -list { vector }  -include { 011 }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_annotation_dlg -opt add
gui_set_pref_value -category {Exclusion} -key {favorite_exclude_annotation} -value {{rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}}
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected  -add_annotation   -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list vector { 011  101   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected  -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected  -add_annotation   -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected  -add_annotation   -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list vector { 101   }
gui_list_select -id CovDetail.1 -list vector { 011   }
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_list_select -id CovDetail.1 -list vector { 011   }
gui_list_select -id CovDetail.1 -list vector { 011   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected  -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list vector { 011  101   }
gui_list_select -id CovDetail.1 -list vector { 101  011   }
gui_list_select -id CovDetail.1 -list vector { 011  110   }
gui_list_select -id CovDetail.1 -list vector { 110  101   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected  -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list vector { 101   }
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_list_select -id CovDetail.1 -list cond { {((opc == WRW) && (wa2reqo_offset_addr != 8'b0) && (rknp_xx2wa_head_d == 1'b1))}  {((opc == WRW) && (offset_addr != 8'b0) && (rknp_xx2wa_head_d == 1'b1))}   }
gui_list_select -id CovDetail.1 -list vector { 011   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected  -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list vector { 011  101   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected  -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list vector { 101   }
gui_list_select -id CovDetail.1 -list cond { {((opc == WRW) && (offset_addr != 8'b0) && (rknp_xx2wa_head_d == 1'b1))}  {(rknp_xx2wa_hs && rknp_xx2wa_head && (opc == WRW) && (wa2reqo_offset_addr != 8'b0))}   }
gui_list_select -id CovDetail.1 -list cond { {(rknp_xx2wa_hs && rknp_xx2wa_head && (opc == WRW) && (wa2reqo_offset_addr != 8'b0))}  {(rknp_xx2wa_hs && rknp_xx2wa_head && (opc == RDW) && (wa2reqo_offset_addr != 8'b0))}   }
gui_list_select -id CovDetail.1 -list cond { {(rknp_xx2wa_hs && rknp_xx2wa_head && (opc == RDW) && (wa2reqo_offset_addr != 8'b0))}  {(rknp_xx2wa_valid && rknp_xx2wa_head && (opc == RDW) && (wa2reqo_offset_addr != 8'b0))}   }
gui_list_select -id CovDetail.1 -list vector { 0111   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected  -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list vector { 0111  1011   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected  -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list vector { 1011   }
gui_list_select -id CovDetail.1 -list cond { {(rknp_xx2wa_valid && rknp_xx2wa_head && (opc == RDW) && (wa2reqo_offset_addr != 8'b0))}  {(rknp_xx2wa_hs && rknp_xx2wa_head && (opc == WRW) && (wa2reqo_offset_addr != 8'b0))}   }
gui_list_select -id CovDetail.1 -list cond { {(rknp_xx2wa_hs && rknp_xx2wa_head && (opc == WRW) && (wa2reqo_offset_addr != 8'b0))}  {(rknp_xx2wa_hs && rknp_xx2wa_head && (opc == RDW) && (wa2reqo_offset_addr != 8'b0))}   }
gui_list_select -id CovDetail.1 -list cond { {(rknp_xx2wa_hs && rknp_xx2wa_head && (opc == RDW) && (wa2reqo_offset_addr != 8'b0))}  {(rknp_xx2wa_valid && rknp_xx2wa_head && (opc == RDW) && (wa2reqo_offset_addr != 8'b0))}   }
gui_list_select -id CovDetail.1 -list cond { {(rknp_xx2wa_valid && rknp_xx2wa_head && (opc == RDW) && (wa2reqo_offset_addr != 8'b0))}  {(rknp_xx2wa_valid && wa2rknp_xx_ready)}   }
gui_list_select -id CovDetail.1 -list cond { {(rknp_xx2wa_valid && wa2rknp_xx_ready)}  {(rknp_xx2wa_hs && rknp_xx2wa_head && (opc == RDW) && (wa2reqo_offset_addr != 8'b0))}   }
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut.U_REQ_ORDER
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ALIGN  tb_top.dut.U_ADDR_MAP   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_ADDR_MAP  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tglDetail { {am2rreqt_araddr[39]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {am2rreqt_araddr[39]}  {am2rreqt_araddr[38:35]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {am2rreqt_araddr[38:35]}  {am2rreqt_araddr[39]}   }
gui_load_kdb -path /home/ICer/RKNoC/axi_tniu_uvm/sim/simv.daidir/kdb.elab++
gui_exclude_conn_signals_begin -signal tb_top.dut.U_ADDR_MAP.am2rreqt_araddr[39] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.am2rreqt_araddr[39]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.araddr[39]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.araddr[39]
gui_exclude_conn_signals_add -signal tb_top.dut.U_RREQ_TRANS.am2rreqt_araddr[39]
gui_exclude_conn_signals_add -signal tb_top.dut.U_RREQ_TRANS.axi_m_araddr[39]
gui_exclude_conn_signals_add -signal tb_top.dut.am2rreqt_araddr[39]
gui_exclude_conn_signals_add -signal tb_top.dut.axi_m_araddr[39]
gui_exclude_conn_signals_end
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_ADDR_MAP  tb_top.dut.U_REQ_ORDER   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_REQ_ORDER  -column {Toggle} 
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_REQ_ORDER  tb_top.dut.genblk1.U_WRAP_ALIGN   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk1.U_WRAP_ALIGN  -column {Toggle} 
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ALIGN  tb_top.dut.U_ADDR_MAP   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_ADDR_MAP  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tglDetail { {am2rreqt_araddr[34:32]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_ADDR_MAP.am2rreqt_araddr[34:32] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.am2rreqt_araddr[34:32]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.araddr[34:32]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.araddr[34:32]
gui_exclude_conn_signals_add -signal tb_top.dut.U_RREQ_TRANS.am2rreqt_araddr[34:32]
gui_exclude_conn_signals_add -signal tb_top.dut.U_RREQ_TRANS.axi_m_araddr[34:32]
gui_exclude_conn_signals_add -signal tb_top.dut.am2rreqt_araddr[34:32]
gui_exclude_conn_signals_add -signal tb_top.dut.axi_m_araddr[34:32]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {am2rreqt_araddr[39:0]}  {am2rreqt_arlen[7:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {am2rreqt_arlen[7:6]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_ADDR_MAP.am2rreqt_arlen[7:6] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.am2rreqt_arlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.arlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.arlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.am2wreqt_awlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.beat_count[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.total_flit[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.U_RREQ_TRANS.am2rreqt_arlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.U_RREQ_TRANS.axi_m_arlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WREQ_TRANS.am2wreqt_awlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WREQ_TRANS.axi_m_awlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.am2rreqt_arlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.am2wreqt_awlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.axi_m_arlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.axi_m_awlen[7:6]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {am2rreqt_arlen[7:0]}  {am2wreqt_awaddr[39:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {am2wreqt_awaddr[39]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_ADDR_MAP.am2wreqt_awaddr[39] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.am2wreqt_awaddr[39]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awaddr[39]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awaddr[39]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WREQ_TRANS.am2wreqt_awaddr[39]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WREQ_TRANS.axi_m_awaddr[39]
gui_exclude_conn_signals_add -signal tb_top.dut.am2wreqt_awaddr[39]
gui_exclude_conn_signals_add -signal tb_top.dut.axi_m_awaddr[39]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {am2wreqt_awaddr[34:32]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_ADDR_MAP.am2wreqt_awaddr[34:32] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.am2wreqt_awaddr[34:32]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awaddr[34:32]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awaddr[34:32]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WREQ_TRANS.am2wreqt_awaddr[34:32]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WREQ_TRANS.axi_m_awaddr[34:32]
gui_exclude_conn_signals_add -signal tb_top.dut.am2wreqt_awaddr[34:32]
gui_exclude_conn_signals_add -signal tb_top.dut.axi_m_awaddr[34:32]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {am2wreqt_awaddr[39:0]}  {beat_count[8:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {beat_count[8]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_ADDR_MAP.beat_count[8] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.beat_count[8]
gui_exclude_conn_signals_end
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_ADDR_MAP  tb_top.dut.U_REQ_ORDER   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_REQ_ORDER  tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {burst[1:0]}  {first_byte_addr[32:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {first_byte_addr[32:0]}  {incr_first_addr[31:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {incr_first_addr[31:0]}  {wrap_first_addr[31:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wrap_first_addr[31:0]}  {wrap_mask[31:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wrap_mask[31:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {burst[1:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {burst[1]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.burst[1] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.burst[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.addr[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.len[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.len_ext[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.wrap_mask[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.head_buffer[0][1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.reqo2wd_timout_table[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.timout_table[0][1]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2wd_timout_table[1]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {burst[1:0]}  {first_byte_addr[32:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {first_byte_addr[32:0]}  {addr_begin[31:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {addr_begin[31:0]}  {len_ext[32:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {len_ext[32:0]}  {incr_first_addr[31:0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.incr_first_addr[31:0] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.incr_first_addr[31:0]
gui_exclude_conn_signals_end
gui_exclude_items -id  CovDetail.1  -list { tgl }  -selected  -include
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[2:0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.incr_first_addr[2:0] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.incr_first_addr[2:0]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[31:3]}   }
gui_list_action -id  CovDetail.1 -list {tglDetail} {incr_first_addr[31]}
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[31]}   }
gui_list_action -id  CovDetail.1 -list {tglDetail} {incr_first_addr[31:3]}
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {incr_first_addr[31:0]}  {last_byte_addr[32:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {last_byte_addr[32:0]}  {incr_first_addr[31:0]}   }
gui_covdetail_select -id  CovDetail.1   -name   Line
gui_covdetail_select -id  CovDetail.1   -name   Toggle
gui_list_select -id CovDetail.1 -list tgl { {incr_first_addr[31:0]}  {first_byte_addr[32:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {first_byte_addr[32]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.first_byte_addr[32] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.first_byte_addr[32]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {first_byte_addr[2:0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.first_byte_addr[2:0] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.first_byte_addr[2:0]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {first_byte_addr[32:0]}  {len_ext[32:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {len_ext[32:8]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.len_ext[32:8] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.len_ext[32:8]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {len_ext[32:0]}  {wrap_mask[31:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {wrap_mask[31:8]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.wrap_mask[31:8] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.wrap_mask[31:8]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.len_ext[31:8]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {wrap_mask[31:0]}  {incr_first_addr[31:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[31:3]}   }
gui_list_action -id  CovDetail.1 -list {tglDetail} {incr_first_addr[31]}
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[31]}   }
gui_list_action -id  CovDetail.1 -list {tglDetail} {incr_first_addr[31:3]}
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[31:3]}   }
gui_exclude_items -id  CovDetail.1  -list { tgl }  -selected  -include
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[2:0]}  {incr_first_addr[31:3]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[31:3]}  {incr_first_addr[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {incr_first_addr[2:0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.incr_first_addr[2:0] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.incr_first_addr[2:0]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {incr_first_addr[31:0]}  {addr[31:0]}   }
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_list_select -id CovDetail.1 -list tgl { {addr[31:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {incr_first_addr[31:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {incr_first_addr[31:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {last_byte_addr[32:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {last_byte_addr[32]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.last_byte_addr[32] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.last_byte_addr[32]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {last_byte_addr[32:0]}  {addr_end[31:0]}   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP  -column {Branch} 
gui_list_select -id CovDetail.1 -list branch { Branch0.1  Item0   }
gui_list_select -id CovDetail.1 -list branch { Item0   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {addr_end[31:0]}  {incr_first_addr[31:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {incr_first_addr[31:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {len_ext[32:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {len_ext[32:0]}  {first_byte_addr[32:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {first_byte_addr[32:0]}  {burst[1:0]}   }
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP  tb_top.dut.genblk2.U_RSP_ORDER   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_ORDER  tb_top.dut.genblk2.U_RSP_TRANS   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_TRANS  tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP  tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {wrap_mask[31:0]}  {burst[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {burst[1:0]}  {first_byte_addr[32:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {first_byte_addr[32:0]}  {len_ext[32:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {len_ext[32:8]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ.len_ext[32:8] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ.len_ext[32:8]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {len_ext[32:0]}  {last_byte_addr[32:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {last_byte_addr[32]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ.last_byte_addr[32] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ.last_byte_addr[32]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {last_byte_addr[32:0]}  {first_byte_addr[32:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {first_byte_addr[32]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ.first_byte_addr[32] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ.first_byte_addr[32]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {first_byte_addr[32:0]}  {wrap_mask[31:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {wrap_mask[31:8]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ.wrap_mask[31:8] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ.wrap_mask[31:8]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ.len_ext[31:8]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {wrap_mask[31:0]}   }
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
