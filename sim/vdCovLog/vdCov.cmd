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
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ  tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {len_ext[32:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {len_ext[32:0]}  {last_byte_addr[32:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {last_byte_addr[32:0]}  {burst[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {burst[1:0]}  {addr_begin[31:0]}   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP  tb_top.rknp_vif   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.rknp_vif  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tglDetail { {rxreq_data[48]}   }
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected  -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list tglDetail { {rxreq_data[48]}  {rxreq_data[46]}   }
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected  -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list tglDetail { {rxreq_data[46]}  {rxreq_data[44]}   }
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected  -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list tglDetail { {rxreq_data[44]}  {rxreq_data[34:30]}   }
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected  -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list tglDetail { {rxreq_data[34:30]}  {rxreq_data[45]}  {rxreq_data[44]}  {rxreq_data[43:35]}  {rxreq_data[34:30]}   }
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_list_select -id CovDetail.1 -list tgl { {rxreq_data[174:0]}  {txrsp_data[156:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {txrsp_data[36]}   }
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected  -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.rknp_vif  tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ  -column {Line} 
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_exclusion_file -load -file {coverage_exclude.el .connSignals1006686177.el .connSignals1010622461.el .connSignals1014625745.el .connSignals1046765657.el .connSignals1078743013.el .connSignals1115184447.el .connSignals1115753520.el .connSignals1143499476.el .connSignals1166389795.el .connSignals1292421808.el .connSignals1293722200.el .connSignals1294069361.el .connSignals1296788351.el .connSignals1298630230.el .connSignals1305053256.el .connSignals1313163521.el .connSignals1399111144.el .connSignals1421824267.el .connSignals1453918509.el .connSignals1485314197.el .connSignals1496562112.el .connSignals159635963.el .connSignals1601115611.el .connSignals1615349831.el .connSignals1622332600.el .connSignals1682385735.el .connSignals1684786614.el .connSignals1695750832.el .connSignals1698180391.el .connSignals1699435425.el .connSignals1722359636.el .connSignals1769553047.el .connSignals1788193191.el .connSignals1819517168.el .connSignals1819690196.el .connSignals1823639081.el .connSignals182426858.el .connSignals1880094534.el .connSignals1880142461.el .connSignals1895244856.el .connSignals195356273.el .connSignals1954627997.el .connSignals196929178.el .connSignals1996413166.el .connSignals2020917137.el .connSignals2051992216.el .connSignals2074427649.el .connSignals2078670452.el .connSignals2094840182.el .connSignals2120106513.el .connSignals2127588586.el .connSignals228320437.el .connSignals233915580.el .connSignals234664663.el .connSignals242521620.el .connSignals270715356.el .connSignals279973506.el .connSignals351437496.el .connSignals353633592.el .connSignals412973044.el .connSignals412980867.el .connSignals463842731.el .connSignals514212549.el .connSignals517773227.el .connSignals529422441.el .connSignals557985589.el .connSignals559769693.el .connSignals580106713.el .connSignals633961862.el .connSignals642637077.el .connSignals64679820.el .connSignals666335051.el .connSignals722241557.el .connSignals755288946.el .connSignals819690795.el .connSignals846614141.el .connSignals848896790.el .connSignals856555309.el .connSignals869657646.el .connSignals903501869.el .connSignals905198030.el .connSignals914248978.el .connSignals942334320.el .connSignals952741852.el .connSignals958878928.el .connSignals962735935.el} -bypass_checks
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ  tb_top.dut.U_RREQ_TRANS   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_RREQ_TRANS  tb_top.dut.U_WATCHDOG   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WATCHDOG  tb_top.dut.U_WREQ_TRANS   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WREQ_TRANS  tb_top.dut.genblk1.U_WRAP_ADJUST   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ADJUST  tb_top.dut.U_WREQ_TRANS   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WREQ_TRANS  tb_top.dut.genblk1.U_WRAP_ALIGN   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ALIGN  tb_top.dut.genblk1.U_WRAP_ADJUST   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ADJUST  tb_top.dut.genblk2.U_ELY_RSP_DETECT   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_ELY_RSP_DETECT  tb_top.dut.genblk2.U_RSP_ORDER   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_ORDER  tb_top.dut.genblk2.U_RSP_TRANS   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk2.U_RSP_TRANS  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {rspt2rspo_opc[1:0]}  {rspt2rspo_data[72:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rspt2rspo_data[72:0]}  {rspt2rspo_errcode[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rspt2rspo_errcode[2:0]}  {rspt2rspo_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rspt2rspo_opc[1:0]}  {rspt2rspo_status[1:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_status[1]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk2.U_RSP_TRANS.rspt2rspo_status[1] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_TRANS.rspt2rspo_status[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_ELY_RSP_DETECT.erd2rspo_status[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_ELY_RSP_DETECT.rspt2erd_status[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspt2rspo_status[1]
gui_exclude_conn_signals_add -signal tb_top.dut.rspt2rspo_status[1]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {rspt2rspo_status[1:0]}  {rspt2rspo_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_opc[1]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk2.U_RSP_TRANS.rspt2rspo_opc[1] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_TRANS.rspt2rspo_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_ELY_RSP_DETECT.erd2rspo_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_ELY_RSP_DETECT.rspt2erd_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspt2rspo_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspt2rspo_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspt2rspo_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspt2rspo_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.rspt2rspo_opc[1]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {rspt2rspo_opc[1:0]}  {rspt2rspo_errcode[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_errcode[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_errcode[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_errcode[2:0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk2.U_RSP_TRANS.rspt2rspo_errcode[2:0] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_TRANS.rspt2rspo_errcode[2:0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_ELY_RSP_DETECT.erd2rspo_errcode[2:0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_ELY_RSP_DETECT.rspt2erd_errcode[2:0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspt2rspo_errcode[2:0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.erd2rspo_errcode[2:0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.rspt2erd_errcode[2:0]
gui_exclude_conn_signals_add -signal tb_top.dut.rspt2rspo_errcode[2:0]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {rspt2rspo_errcode[2:0]}  rspt2rspo_head   }
gui_list_select -id CovDetail.1 -list tgl { rspt2rspo_head  rspt2rspo_lw   }
gui_list_select -id CovDetail.1 -list tgl { rspt2rspo_lw  {rspt2rspo_errcode[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rspt2rspo_errcode[2:0]}  {rspt2rspo_data[72:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_data[0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_data[0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_data[0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_data[0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_data[0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_data[0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_data[0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_data[0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_data[0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk2.U_RSP_TRANS.rspt2rspo_data[0] -annotation rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_TRANS.rspt2rspo_data[0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_ELY_RSP_DETECT.erd2rspo_data[0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_ELY_RSP_DETECT.rspt2erd_data[0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspt2rspo_data[0]
gui_exclude_conn_signals_add -signal tb_top.dut.rspt2rspo_data[0]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_data[0]}   }
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected  -add_annotation   -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected  -add_annotation   -annotation  {rknp_xx2wa_head_d can only be asserted after accepting an
unaligned WRW request. Therefore head_d implies opc==WRW and
wa2reqo_offset_addr!=0. Combinations 0/1/1 and 1/0/1 are unreachable}
gui_list_select -id CovDetail.1 -list tglDetail { {rspt2rspo_data[0]}   }
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_select -id CovDetail.1 -list tgl { {rspt2rspo_data[72:0]}  {rspt2rspo_errcode[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rspt2rspo_errcode[2:0]}  rspt2rspo_lw   }
gui_list_select -id CovDetail.1 -list tgl { rspt2rspo_lw  rspt2rspo_head   }
gui_list_select -id CovDetail.1 -list tgl { rspt2rspo_head  rspt2rspo_lw   }
gui_list_select -id CovDetail.1 -list tgl { rspt2rspo_lw  {rspt2rspo_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rspt2rspo_opc[1:0]}  {rspt2rspo_status[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rspt2rspo_status[1:0]}  rspt2rspo_tail   }
gui_list_select -id CovDetail.1 -list tgl { rspt2rspo_tail  rspt2rspo_valid   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk2.U_RSP_TRANS  -column {Condition} 
gui_list_select -id CovDetail.1 -list cond { {(((!prev_rbeat_seen)) || prev_rbeat_last || (axi_m_rid != prev_rid))}  {(((!prev_rbeat_seen)) || prev_rbeat_last || (axi_m_rid != prev_rid)):1}   }
gui_list_select -id CovDetail.1 -list cond { {(((!prev_rbeat_seen)) || prev_rbeat_last || (axi_m_rid != prev_rid)):1}  {(((!prev_rbeat_seen)) || prev_rbeat_last || (axi_m_rid != prev_rid))}   }
gui_list_select -id CovDetail.1 -list cond { {(((!prev_rbeat_seen)) || prev_rbeat_last || (axi_m_rid != prev_rid))}  {(((!prev_rbeat_seen)) || prev_rbeat_last || (axi_m_rid != prev_rid)):1}   }
gui_reload_cov 
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_TRANS   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk2.U_RSP_TRANS  -column {FSM} 
gui_list_select -id CovDetail.1 -list fsmnames { rbuf_count   }
gui_src_highlight_item -id CovSrc.1 -lfrom 71 -idxfrom 28 -fileIdFrom 0 -lto 71 -idxto 38 -fileIdTo 0 -selection {rbuf_count} -selectionId 0 -replace 0
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk2.U_RSP_TRANS  -column {FSM} 
