gui_exclusion -set_force true
gui_assert_mode -mode flat
gui_class_mode -mode hier
gui_excl_mgr_flat_list -on  0
gui_covdetail_select -id  CovDetail.1   -name   Line
verdiWindowWorkMode -win $_vdCoverage_1 -coverageAnalysis
gui_open_cov  -hier cov.vdb -testdir {} -test {cov/test_norm_rdw_1 cov/test_norm_wrw_1 cov/test_watchdog_1023_1 cov/test_watchdog_1024_1 cov/test_watchdog_normal_timeout_1 cov/test_tag_name_toggle_1 cov/test_norm_rdw_narrow_noalign_1 cov/test_norm_wrw_narrow_noalign_1 cov/test_watchdog_1100_1 cov/test_norm_mix_stresstest_1 cov/test_err_rd_1 cov/test_err_wr_1 cov/test_err_rdw_1 cov/test_err_wrw_1 cov/test_err_mix_1 cov/test_err_mix_fixordkey_1 cov/test_buff_wr_1 cov/test_buff_wrw_1 cov/test_buff_mix_1 cov/test_buff_mix_fixordkey_1 cov/test_buff_err_mix_1 cov/test_addrol_waw_1 cov/test_addrol_raw_1 cov/test_axi_rsp_error_mix_1 cov/test_mix_1 cov/test_aresetn_recovery_1 cov/test_norm_rd_1 cov/test_norm_wr_1 cov/test_norm_mix_1 cov/test_watchdog_bufferable_1100_1} -merge MergedTest -db_max_tests 10 -fsm transition
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut.U_REQ_ORDER
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_REQ_ORDER   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_REQ_ORDER  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {rknp_xx2reqo_data[174:0]}  {opc[3:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {opc[3]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {opc[3]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {opc[3]}   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_REQ_ORDER  tb_top.rknp_vif   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.rknp_vif  -column {} 
gui_list_select -id CovDetail.1 -list tglDetail { {rxreq_data[48]}   }
gui_list_select -id CovDetail.1 -list tgl { {rxreq_data[174:0]}  rxreq_valid   }
gui_list_select -id CovDetail.1 -list tgl { rxreq_valid  txrsp_head   }
gui_list_select -id CovDetail.1 -list tgl { txrsp_head  {rxreq_data[174:0]}   }
verdiDockWidgetSetCurTab -dock widgetDock_<HvpDetail>
verdiDockWidgetSetCurTab -dock widgetDock_<CovDetail>
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.rknp_vif  tb_top.dut.genblk1.U_WRAP_ADJUST   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ADJUST  tb_top.dut.U_WATCHDOG   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WATCHDOG  tb_top.dut.U_REQ_ORDER   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_REQ_ORDER  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {rknp_xx2reqo_data[174:0]}  {opc[3:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {opc[3]}   }
gui_load_kdb -path /home/ICer/RKNoC/axi_tniu_uvm/sim/simv.daidir/kdb.elab++
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.opc[3]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.opc[3]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.rknp_xx2reqo_data[46]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ALIGN.wa2reqo_data[46]
gui_exclude_conn_signals_add -signal tb_top.dut.rknp_xx2reqo_data[46]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {opc[1]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.genblk24.U_ADDR_BORDER_COUNT_REQ.burst[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.rknp_xx2reqo_data[44]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ALIGN.wa2reqo_data[44]
gui_exclude_conn_signals_add -signal tb_top.dut.rknp_xx2reqo_data[44]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {opc[3:0]}  {reqo2rspo_opc[3:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_opc[3]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_opc[3]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_opc[3]
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.rspo2am_opc[3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_ELY_RSP_DETECT.rspo2erd_opc[3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_opc[3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_opc[3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspo2am_opc[3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspo2erd_opc[3]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_opc[3]
gui_exclude_conn_signals_add -signal tb_top.dut.rspo2am_opc[3]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_opc[1]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.am2rreqt_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.am2wreqt_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.rspo2am_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_RREQ_TRANS.am2rreqt_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WREQ_TRANS.am2wreqt_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.am2rreqt_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.am2wreqt_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_ELY_RSP_DETECT.rspo2erd_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspo2am_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspo2erd_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.rspo2am_opc[1]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {reqo2rspo_opc[3:0]}  {reqo2rspo_rsp_offset_addr[7:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_rsp_offset_addr[7:3]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_rsp_offset_addr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_rsp_offset_addr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.rspo2wad_offset_addr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_rsp_offset_addr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspo2wad_offset_addr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_rsp_offset_addr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.rspo2wad_offset_addr[7:3]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {reqo2rspo_rsp_offset_addr[7:0]}  {reqo2rspo_rsp_ordkey[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {reqo2rspo_rsp_ordkey[7:0]}  {reqo2rspo_rsp_offset_addr[7:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_rsp_offset_addr[0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_rsp_offset_addr[0]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_rsp_offset_addr[0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.rspo2wad_offset_addr[0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_rsp_offset_addr[0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspo2wad_offset_addr[0]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_rsp_offset_addr[0]
gui_exclude_conn_signals_add -signal tb_top.dut.rspo2wad_offset_addr[0]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {reqo2rspo_rsp_offset_addr[7:0]}  {reqo2rspo_status[1:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_status[1]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_status[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_status[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_status[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_status[1]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_status[1]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {reqo2rspo_status[1:0]}  {reqo2rspo_subr[7:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_subr[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_subr[2:0]}  {reqo2rspo_subr[7:3]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_subr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_subr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.U_ADDR_MAP.rspo2am_subr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_subr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspo2am_subr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_subr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.rspo2am_subr[7:3]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {reqo2rspo_subr[7:0]}  reqo2rspo_tail   }
gui_list_select -id CovDetail.1 -list tgl { reqo2rspo_tail  {reqo2rspo_tag_name[55:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_tag_name[51]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[51]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[51]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.tag_name[7][2]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_tag_name[51]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.tag_name[7][2]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_tag_name[51]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_tag_name[44]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[44]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[44]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.tag_name[6][2]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_tag_name[44]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.tag_name[6][2]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_tag_name[44]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_tag_name[37]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[37]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[37]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.tag_name[5][2]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_tag_name[37]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.tag_name[5][2]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_tag_name[37]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_tag_name[30]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[30]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[30]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.tag_name[4][2]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_tag_name[30]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.tag_name[4][2]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_tag_name[30]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_tag_name[23]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[23]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[23]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.tag_name[3][2]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_tag_name[23]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.tag_name[3][2]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_tag_name[23]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_tag_name[16]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[16]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[16]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.tag_name[2][2]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_tag_name[16]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.tag_name[2][2]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_tag_name[16]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_tag_name[9]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[9]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[9]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.tag_name[1][2]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_tag_name[9]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.tag_name[1][2]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_tag_name[9]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2rspo_tag_name[2]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[2]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2rspo_tag_name[2]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.tag_name[0][2]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.reqo2rspo_tag_name[2]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.tag_name[0][2]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2rspo_tag_name[2]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {reqo2rspo_tag_name[55:0]}  reqo2rspo_timout   }
gui_list_select -id CovDetail.1 -list tgl { reqo2rspo_timout  {reqo2wd_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2wd_opc[1]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2wd_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2wd_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.reqo2wd_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.reqo2wd_opc[1]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2wd_opc[1]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {reqo2wd_opc[1:0]}  {reqo2wd_timout_table[79:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2wd_timout_table[75]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[75]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[75]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.head_buffer[7][5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.reqo2wd_timout_table[75]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.timout_table[7][5]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2wd_timout_table[75]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2wd_timout_table[65]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[65]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[65]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.head_buffer[6][5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.reqo2wd_timout_table[65]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.timout_table[6][5]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2wd_timout_table[65]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2wd_timout_table[55]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[55]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[55]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.head_buffer[5][5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.reqo2wd_timout_table[55]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.timout_table[5][5]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2wd_timout_table[55]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2wd_timout_table[45]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[45]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[45]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.head_buffer[4][5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.reqo2wd_timout_table[45]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.timout_table[4][5]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2wd_timout_table[45]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2wd_timout_table[35]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[35]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[35]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.head_buffer[3][5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.reqo2wd_timout_table[35]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.timout_table[3][5]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2wd_timout_table[35]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2wd_timout_table[25]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[25]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[25]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.head_buffer[2][5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.reqo2wd_timout_table[25]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.timout_table[2][5]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2wd_timout_table[25]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2wd_timout_table[15]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[15]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[15]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.head_buffer[1][5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.reqo2wd_timout_table[15]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.timout_table[1][5]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2wd_timout_table[15]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {reqo2wd_timout_table[5]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.reqo2wd_timout_table[5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.addr[5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.len[5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.len_ext[5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.wrap_mask[5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.head_buffer[0][5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.reqo2wd_timout_table[5]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.timout_table[0][5]
gui_exclude_conn_signals_add -signal tb_top.dut.reqo2wd_timout_table[5]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {reqo2wd_timout_table[79:0]}  {rknp_xx2reqo_data[174:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rknp_xx2reqo_data[34:30]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rknp_xx2reqo_data[34:30]}  {rknp_xx2reqo_data[48]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.rknp_xx2reqo_data[48]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.rknp_xx2reqo_data[48]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.status[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.status[1]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ALIGN.wa2reqo_data[48]
gui_exclude_conn_signals_add -signal tb_top.dut.rknp_xx2reqo_data[48]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {rknp_xx2reqo_data[48]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rknp_xx2reqo_data[48]}  {rknp_xx2reqo_data[34:30]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.rknp_xx2reqo_data[34:30]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.rknp_xx2reqo_data[34:30]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.subr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ALIGN.wa2reqo_data[34:30]
gui_exclude_conn_signals_add -signal tb_top.dut.rknp_xx2reqo_data[34:30]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {rknp_xx2reqo_data[174:0]}  {rsp_addr_begin[31:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rsp_addr_begin[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rsp_addr_begin[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rsp_addr_begin[2:0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.rsp_addr_begin[2:0]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.rsp_addr_begin[2:0]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.U_ADDR_BORDER_COUNT_RSP.addr_begin[2:0]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {rsp_addr_begin[31:0]}  {rspo2reqo_head_index[8:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rspo2reqo_head_index[4]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.rspo2reqo_head_index[4]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.rspo2reqo_head_index[4]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.rspo2reqo_head_index[4]
gui_exclude_conn_signals_add -signal tb_top.dut.rspo2reqo_head_index[4]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {rspo2reqo_head_index[8:0]}  {wa2reqo_offset_addr[7:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {wa2reqo_offset_addr[7:3]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.wa2reqo_offset_addr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.wa2reqo_offset_addr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ALIGN.wa2reqo_offset_addr[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.wa2reqo_offset_addr[7:3]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {wa2reqo_offset_addr[0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_REQ_ORDER.wa2reqo_offset_addr[0]
gui_exclude_conn_signals_add -signal tb_top.dut.U_REQ_ORDER.wa2reqo_offset_addr[0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ALIGN.wa2reqo_offset_addr[0]
gui_exclude_conn_signals_add -signal tb_top.dut.wa2reqo_offset_addr[0]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {wa2reqo_offset_addr[7:0]}  {reqo2rspo_urg[6:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {reqo2rspo_urg[6:0]}  reqo2rspo_timout   }
gui_list_select -id CovDetail.1 -list tglDetail { reqo2rspo_timout   }
gui_list_select -id CovDetail.1 -list tglDetail { reqo2rspo_timout   }
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
