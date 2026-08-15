gui_exclusion -set_force true
gui_assert_mode -mode flat
gui_class_mode -mode hier
gui_excl_mgr_flat_list -on  0
gui_covdetail_select -id  CovDetail.1   -name   Line
verdiWindowWorkMode -win $_vdCoverage_1 -coverageAnalysis
gui_open_cov  -hier cov.vdb -testdir {} -test {cov/test_err_rd_1 cov/test_err_wrw_1 cov/test_err_mix_1 cov/test_mix_1 cov/test_norm_rd_1 cov/test_norm_rdw_narrow_noalign_1 cov/test_watchdog_1024_1 cov/test_watchdog_multi_timeout_cov_1 cov/test_rwrap_stresstest_1 cov/test_err_wr_1 cov/test_err_mix_fixordkey_1 cov/test_buff_wr_1 cov/test_buff_wrw_1 cov/test_buff_mix_1 cov/test_norm_wr_1 cov/test_norm_wrw_narrow_noalign_1 cov/test_watchdog_bufferable_1100_1 cov/test_norm_mix_stresstest_1 cov/test_tag_name_toggle_1 cov/test_err_rdw_1 cov/test_aresetn_recovery_1 cov/test_norm_wrw_1 cov/test_watchdog_1023_1 cov/test_watchdog_normal_timeout_1 cov/test_watchdog_fifo_full_cov_1 cov/test_buff_mix_fixordkey_1 cov/test_buff_err_mix_1 cov/test_addrol_waw_1 cov/test_addrol_raw_1 cov/test_axi_rsp_error_mix_1 cov/test_rsp_order_deep_followers_1 cov/test_rsp_order_high_firstflag_1 cov/test_norm_rdw_1 cov/test_norm_mix_1 cov/test_watchdog_1100_1 cov/test_watchdog_timer_wrap_cov_1} -merge MergedTest -db_max_tests 10 -fsm transition
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WATCHDOG   }
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut.U_WATCHDOG
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WATCHDOG  tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT  -column {Toggle} 
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
verdiDockWidgetUndock -dock widgetDock_Message
gui_list_select -id CovDetail.1 -list tgl { {data_in[5:0]}  {rd_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr[3:0]}  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  full   }
gui_list_select -id CovDetail.1 -list tgl { full  {rd_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr[3:0]}  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  {rd_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr_true[2:0]}  {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr[3:0]}   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT  -column {Condition} 
gui_reload_cov 
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut.U_WATCHDOG
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT  -column {Condition} 
gui_list_select -id CovDetail.1 -list vector { 10   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_src_highlight_item -id CovSrc.1 -lfrom 48 -idxfrom 23 -fileIdFrom 0 -lto 48 -idxto 28 -fileIdTo 0 -selection {empty} -selectionId 0 -replace 0
gui_list_select -id CovDetail.1 -list cond { {(rd_en && ((!empty)))}  {(((!full)) && wr_en)}   }
gui_list_select -id CovDetail.1 -list vector { 01   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_list_select -id CovDetail.1 -list cond { {(((!full)) && wr_en)}  {(rd_en && ((!empty)))}   }
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_list_select -id CovDetail.1 -list vector { 10   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_list_select -id CovDetail.1 -list cond { {(rd_en && ((!empty)))}  {(((!full)) && wr_en)}   }
gui_list_select -id CovDetail.1 -list vector { 01   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT  tb_top.dut.genblk1.U_WRAP_ALIGN   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk1.U_WRAP_ALIGN  -column {Condition} 
gui_list_select -id CovDetail.1 -list vector { 1011   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_list_select -id CovDetail.1 -list vector { 1011   }
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ALIGN  tb_top.dut.genblk2.U_ELY_RSP_DETECT   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk2.U_ELY_RSP_DETECT  -column {Branch} 
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_ELY_RSP_DETECT  tb_top.dut.genblk2.U_RSP_ORDER   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_ORDER  tb_top.dut.genblk2.U_RSP_TRANS   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk2.U_RSP_TRANS  -column {FSM} 
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_TRANS  uvm_custom_install_verdi_recording   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { uvm_custom_install_verdi_recording  tb_top.dut.genblk2.U_RSP_ORDER   }
gui_tbl_select -id CovDetail.1   { {2,0,2,0} }
gui_exclude_items -id  CovDetail.1  -table { fsmTable }  -selected
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_ORDER  tb_top.dut.genblk2.U_ELY_RSP_DETECT   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_ELY_RSP_DETECT  tb_top.dut.genblk2.U_RSP_ORDER   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_ORDER  tb_top.dut.genblk2.U_RSP_TRANS   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_TRANS  tb_top.axi_vif   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.axi_vif  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {awaddr[39:0]}  {arlen[7:0]}   }
gui_list_action -id  CovDetail.1 -list {tgl} {arlen[7:0]}
gui_list_select -id CovDetail.1 -list tglDetail { {arlen[7:6]}   }
gui_load_kdb -path /home/ICer/RKNoC/axi_tniu_uvm/sim/simv.daidir/kdb.elab++
gui_exclude_conn_signals_begin -signal tb_top.axi_vif.arlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.arlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.am2rreqt_arlen[7:6]
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
gui_list_select -id CovDetail.1 -list tglDetail { {arlen[7:6]}   }
gui_exclude_conn_signals_begin -signal tb_top.axi_vif.arlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.arlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awlen[7:6]
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.am2rreqt_arlen[7:6]
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
gui_list_select -id CovDetail.1 -list tglDetail { {arlen[7:6]}   }
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected
gui_list_select -id CovDetail.1 -list tgl { {arlen[7:0]}  {araddr[39:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {araddr[39]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {araddr[39]}  {araddr[34:32]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {araddr[34:32]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {araddr[39]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {araddr[39]}  {araddr[34:32]}   }
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected
gui_list_select -id CovDetail.1 -list tglDetail { {araddr[34:32]}  {araddr[39]}   }
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected
gui_list_select -id CovDetail.1 -list tgl { {araddr[39:0]}  {awaddr[39:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {awaddr[39]}   }
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected
gui_list_select -id CovDetail.1 -list tglDetail { {awaddr[39]}  {awaddr[34:32]}   }
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected
gui_list_select -id CovDetail.1 -list tgl { {awaddr[39:0]}  {awlen[7:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {awlen[7:6]}   }
gui_exclude_items -id  CovDetail.1  -list { tglDetail }  -selected
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.axi_vif  uvm_custom_install_verdi_recording   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} uvm_custom_install_verdi_recording  -column {} 
