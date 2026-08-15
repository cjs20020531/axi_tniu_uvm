gui_exclusion -set_force true
gui_assert_mode -mode flat
gui_class_mode -mode hier
gui_excl_mgr_flat_list -on  0
gui_covdetail_select -id  CovDetail.1   -name   Line
verdiWindowWorkMode -win $_vdCoverage_1 -coverageAnalysis
gui_open_cov  -hier cov.vdb -testdir {} -test {cov/test_buff_wr_1 cov/test_buff_wrw_1 cov/test_buff_mix_1 cov/test_buff_mix_fixordkey_1 cov/test_addrol_waw_1 cov/test_addrol_raw_1 cov/test_axi_rsp_error_mix_1 cov/test_rsp_order_high_firstflag_1 cov/test_aresetn_recovery_1 cov/test_norm_rd_1 cov/test_norm_wr_1 cov/test_norm_rdw_1 cov/test_norm_rdw_narrow_noalign_1 cov/test_norm_wrw_1 cov/test_norm_wrw_narrow_noalign_1 cov/test_norm_mix_1 cov/test_watchdog_1023_1 cov/test_watchdog_1024_1 cov/test_watchdog_1100_1 cov/test_watchdog_normal_timeout_1 cov/test_watchdog_bufferable_1100_1 cov/test_norm_mix_stresstest_1 cov/test_rwrap_stresstest_1 cov/test_tag_name_toggle_1 cov/test_err_rd_1 cov/test_err_wr_1 cov/test_err_wrw_1 cov/test_err_mix_fixordkey_1 cov/test_buff_err_mix_1 cov/test_rsp_order_deep_followers_1 cov/test_err_rdw_1 cov/test_err_mix_1 cov/test_mix_1} -merge MergedTest -db_max_tests 10 -fsm transition
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_ORDER   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk2.U_RSP_ORDER  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {buff_used[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {buff_used[7:0]}  {buffer_fir_falg[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {buffer_fir_falg[7:0]}  {buff_used[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {buff_used[7:0]}  {buffer_fir_falg[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {buffer_fir_falg[7:0]}  {fir_req_buff_index_hot[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {fir_req_buff_index_hot[7:0]}  {follo_req_buff_index_hot[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {follo_req_buff_index_hot[7:0]}  {norm_rsp_head_index[8:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {norm_rsp_head_index[8:0]}  {spec_req_ready_hot[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {spec_req_ready_hot[7:0]}  {wd2rspo_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {wd2rspo_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_opc[1:0]}  {wd2rspo_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {wd2rspo_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_opc[1:0]}  {wd2rspo_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {wd2rspo_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_opc[1:0]}  {wd2rspo_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {wd2rspo_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_opc[1:0]}  {norm_rsp_head_index[8:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {norm_rsp_head_index[4]}   }
gui_load_kdb -path /home/ICer/RKNoC/axi_tniu_uvm/sim/simv.daidir/kdb.elab++
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk2.U_RSP_ORDER.norm_rsp_head_index[4]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.norm_rsp_head_index[4]
gui_exclude_conn_signals_end
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_reload_cov 
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_ORDER   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk2.U_RSP_ORDER  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {buff_index[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {buff_index[2:0]}  {buff_index_d[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {buff_index_d[2:0]}  {buff_index[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {buff_index[2:0]}  {buff_index_d[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {buff_index_d[2:0]}  {buff_index[2:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {buff_index[2]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {buff_index[2]}   }
gui_list_select -id CovDetail.1 -list tgl { {buff_index[2:0]}  {wd2rspo_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {wd2rspo_opc[1:0]}   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk2.U_RSP_ORDER  -column {Branch} 
gui_list_select -id CovDetail.1 -list branch { Branch87.6  Item87   }
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk2.U_RSP_ORDER  -column {Line} 
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk2.U_RSP_ORDER  -column {Condition} 
gui_list_select -id CovDetail.1 -list cond { {((spec_dispatch_en == 1'b1) && (timout_fifo_rden == 1'b0) && (spec_req_ready_en == 1'b1))}  {((rspt2rspo_tail == 1'b1) && (rspt2rspo_valid == 1'b1) && (rspo2rspt_ready == 1'b1))}   }
gui_list_select -id CovDetail.1 -list cond { {((rspt2rspo_tail == 1'b1) && (rspt2rspo_valid == 1'b1) && (rspo2rspt_ready == 1'b1))}  {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1) && (buff_rsp_flag == 1'b0))}   }
gui_list_select -id CovDetail.1 -list cond { {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1) && (buff_rsp_flag == 1'b0))}  {((rspt2rspo_tail == 1'b1) && (rspt2rspo_valid == 1'b1) && (rspo2rspt_ready == 1'b1))}   }
gui_list_select -id CovDetail.1 -list vector { 011   }
gui_list_select -id CovDetail.1 -list cond { {((rspt2rspo_tail == 1'b1) && (rspt2rspo_valid == 1'b1) && (rspo2rspt_ready == 1'b1))}  {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1) && (buff_rsp_flag == 1'b0))}   }
gui_list_select -id CovDetail.1 -list cond { {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1) && (buff_rsp_flag == 1'b0))}  {((spec_dispatch_en == 1'b1) && (timout_fifo_rden == 1'b0) && (spec_req_ready_en == 1'b1))}   }
gui_list_select -id CovDetail.1 -list cond { {((spec_dispatch_en == 1'b1) && (timout_fifo_rden == 1'b0) && (spec_req_ready_en == 1'b1))}  {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1))}   }
gui_list_select -id CovDetail.1 -list cond { {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1))}  {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1) && (buff_rsp_flag == 1'b0))}   }
gui_list_select -id CovDetail.1 -list cond { {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1) && (buff_rsp_flag == 1'b0))}  {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1))}   }
gui_list_select -id CovDetail.1 -list cond { {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1))}  {((spec_dispatch_en == 1'b1) && (timout_fifo_rden == 1'b0) && (spec_req_ready_en == 1'b1))}   }
gui_list_select -id CovDetail.1 -list vector { 110   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_list_select -id CovDetail.1 -list cond { {((spec_dispatch_en == 1'b1) && (timout_fifo_rden == 1'b0) && (spec_req_ready_en == 1'b1))}  {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1))}   }
gui_list_select -id CovDetail.1 -list cond { {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1))}  {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1) && (buff_rsp_flag == 1'b0))}   }
gui_list_select -id CovDetail.1 -list vector { 0111   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_list_select -id CovDetail.1 -list vector { 0111  1110   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_select -id CovDetail.1 -list vector { 1110   }
gui_list_select -id CovDetail.1 -list cond { {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1) && (buff_rsp_flag == 1'b0))}  {((spec_dispatch_en == 1'b1) && (timout_fifo_rden == 1'b0) && (spec_req_ready_en == 1'b1))}   }
gui_list_select -id CovDetail.1 -list cond { {((spec_dispatch_en == 1'b1) && (timout_fifo_rden == 1'b0) && (spec_req_ready_en == 1'b1))}  {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1))}   }
gui_list_select -id CovDetail.1 -list cond { {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1))}  {((rspt2rspo_valid == 1'b1) && (rspt2rspo_lw == 1'b1) && (rspo2rspt_ready == 1'b1) && (buff_rsp_flag == 1'b0))}   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_ORDER  tb_top.dut.U_WATCHDOG   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WATCHDOG  tb_top.dut.U_WREQ_TRANS   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WREQ_TRANS  tb_top.dut.U_REQ_ORDER   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_REQ_ORDER  tb_top.dut.U_RREQ_TRANS   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_RREQ_TRANS  tb_top.dut.U_WREQ_TRANS   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_WREQ_TRANS  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tglDetail { {axi_m_awsize[2:0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_WREQ_TRANS.axi_m_awsize[2:0]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WREQ_TRANS.axi_m_awsize[2:0]
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awsize
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awsize
gui_exclude_conn_signals_add -signal tb_top.axi_vif.awsize[2:0]
gui_exclude_conn_signals_add -signal tb_top.dut.axi_m_awsize[2:0]
gui_exclude_conn_signals_end
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_WREQ_TRANS  -column {Condition} 
gui_list_select -id CovDetail.1 -list vector { 011   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_select -id CovDetail.1 -list vector { 011   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WREQ_TRANS  tb_top.dut.genblk1.U_WRAP_ADJUST   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk1.U_WRAP_ADJUST  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_used[3:0]}  {fir_offset_body[9:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {fir_offset_body[9:0]}  {idle_rwrap_buff_index[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_index[1:0]}  {idle_rwrap_buff_index_hot[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_index_hot[3:0]}  {lw_offset_body[9:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {lw_offset_body[9:0]}  {rwrap_buff_index_hot[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rwrap_buff_index_hot[3:0]}  {rwrap_buff_index[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rwrap_buff_index[1:0]}  {fir_offset_body[9:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {fir_offset_body[9:0]}  {idle_rwrap_buff_index_hot[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_index_hot[3:0]}  {pending_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {pending_axid[3:0]}  {pending_offset[7:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {pending_offset[7:3]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_offset[7:3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_offset[7:3]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {pending_offset[0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_offset[0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_offset[0]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {pending_offset[7:0]}  {pending_rsp_head[83:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[36:35]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_rsp_head[36:35]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_rsp_head[36:35]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {pending_rsp_head[83:0]}  {fir_offset_body[9:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {fir_offset_body[0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.fir_offset_body[0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.fir_offset_body[0]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {fir_offset_body[3]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.fir_offset_body[3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.fir_offset_body[3]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {fir_offset_body[9:6]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.fir_offset_body[9:6]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.fir_offset_body[9:6]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {fir_offset_body[9:0]}  {lw_offset_body[9:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {lw_offset_body[0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.lw_offset_body[0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.lw_offset_body[0]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {lw_offset_body[9:7]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.lw_offset_body[9:7]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.lw_offset_body[9:7]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {lw_offset_body[3]}   }
gui_list_select -id CovDetail.1 -list tgl { {lw_offset_body[9:0]}  {pending_rsp_head[83:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[71]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_rsp_head[71]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_rsp_head[71]
gui_exclude_conn_signals_end
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_select -id CovDetail.1 -list tgl { {pending_rsp_head[83:0]}  {rwrap_buff_index_hot[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rwrap_buff_index_hot[3:0]}  {rwrap_buff_index[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rwrap_buff_index[1:0]}  {rwrap_buff_index_hot[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rwrap_buff_index_hot[3:0]}  {rwrap_buff_index[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rwrap_buff_index[1:0]}  {rwrap_buff_index_hot[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rwrap_buff_index_hot[3:0]}  {rwrap_buff_index[1:0]}   }
gui_reload_cov 
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ADJUST   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk1.U_WRAP_ADJUST  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_used[3:0]}  {idle_rwrap_buff_index[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_index[1:0]}  {idle_rwrap_buff_index_hot[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_index_hot[3:0]}  {idle_rwrap_buff_used[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_used[3:0]}  first_rwrap_hs   }
gui_list_select -id CovDetail.1 -list tgl { first_rwrap_hs  first_wrap_flit   }
gui_list_select -id CovDetail.1 -list tgl { first_wrap_flit  {idle_rwrap_buff_index[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_index[1:0]}  clk   }
gui_list_select -id CovDetail.1 -list tgl { clk  cur_wrap_final_hs   }
gui_list_select -id CovDetail.1 -list tgl { cur_wrap_final_hs  {fir_offset_body[9:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {fir_offset_body[9:0]}  first_wrap_flit   }
gui_list_select -id CovDetail.1 -list tgl { first_wrap_flit  {idle_rwrap_buff_index_hot[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_index_hot[3:0]}  {idle_rwrap_buff_index[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_index[1:0]}  {idle_rwrap_buff_index_hot[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_index_hot[3:0]}  {idle_rwrap_buff_used[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_used[3:0]}  {pending_rsp_head[83:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {pending_rsp_head[83:0]}  {rwrap_buff_index[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rwrap_buff_index[1:0]}  {rwrap_buff_index_hot[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rwrap_buff_index_hot[3:0]}  {idle_rwrap_buff_index[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_index[1:0]}  {idle_rwrap_buff_index_hot[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {idle_rwrap_buff_index_hot[3:0]}  {idle_rwrap_buff_used[3:0]}   }
gui_reload_cov 
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ALIGN   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ALIGN  tb_top.dut.genblk1.U_WRAP_ADJUST   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk1.U_WRAP_ADJUST  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[83:82]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[83:82]}  {pending_rsp_head[41:39]}   }
gui_list_select -id CovDetail.1 -list tgl { {pending_rsp_head[83:0]}  {lw_offset_body[9:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {lw_offset_body[6]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {lw_offset_body[6]}  {lw_offset_body[3]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {lw_offset_body[2:1]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {lw_offset_body[3]}  {lw_offset_body[2:1]}   }
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_select -id CovDetail.1 -list tglDetail { {lw_offset_body[6]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {lw_offset_body[6]}  {lw_offset_body[2:1]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {lw_offset_body[2:1]}  {lw_offset_body[3]}   }
gui_list_select -id CovDetail.1 -list tgl { {lw_offset_body[9:0]}  {pending_rsp_head[83:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[81]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[81]}  {pending_rsp_head[83:82]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_rsp_head[83:82]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_rsp_head[83:82]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[81]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[81]}  {pending_rsp_head[41:39]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[41:39]}  {pending_rsp_head[81]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_rsp_head[81]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_rsp_head[81]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[41:39]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[41:39]}  {pending_rsp_head[37]}   }
gui_list_select -id CovDetail.1 -list tgl { {pending_rsp_head[83:0]}  {lw_offset_body[9:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {lw_offset_body[6]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.lw_offset_body[6]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.lw_offset_body[6]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {lw_offset_body[3]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.lw_offset_body[3]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.lw_offset_body[3]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {lw_offset_body[9:0]}  {pending_rsp_head[83:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[41:39]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[41:39]}  {pending_rsp_head[37]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[37]}  {pending_rsp_head[41:39]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_rsp_head[41:39]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_rsp_head[41:39]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tglDetail { {pending_rsp_head[37]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_rsp_head[37]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk1.U_WRAP_ADJUST.pending_rsp_head[37]
gui_exclude_conn_signals_end
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ADJUST  tb_top.dut.genblk1.U_WRAP_ALIGN   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ALIGN  tb_top.dut.genblk2.U_ELY_RSP_DETECT   }
gui_cov_excl_review -id { CovSrc.1 } -line  130  -insertindex  0
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_ELY_RSP_DETECT  tb_top.dut.genblk1.U_WRAP_ADJUST   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.genblk1.U_WRAP_ADJUST  -column {Condition} 
gui_list_select -id CovDetail.1 -list vector { 0111   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_select -id CovDetail.1 -list cond { {(rspo2wad_valid && rspo2wad_head && (rspo2wad_offset_addr != 8'b0) && (rspo2wad_status != CONT))}  {(rspo2wad_valid && rspo2wad_tail && rspo2wad_lw && (rspo2wad_opc == R) && (rspo2wad_offset_addr != 8'b0))}   }
gui_list_select -id CovDetail.1 -list vector { 01111   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_select -id CovDetail.1 -list cond { {(rspo2wad_valid && rspo2wad_tail && rspo2wad_lw && (rspo2wad_opc == R) && (rspo2wad_offset_addr != 8'b0))}  {((append_hs == 1'b1) && (rwrap_buff_index_hot != 4'b0))}   }
gui_list_select -id CovDetail.1 -list vector { 10   }
gui_exclude_items -id  CovDetail.1  -list { vector }  -selected
gui_exclusion_file -save -file /home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el -module -incremental -format newformat
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ADJUST  tb_top.dut.genblk1.U_WRAP_ALIGN   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk1.U_WRAP_ALIGN  tb_top   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top  tb_top.dut.U_ADDR_MAP   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_ADDR_MAP  tb_top.axi_vif   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.axi_vif  tb_top.dut.U_WATCHDOG   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WATCHDOG  tb_top.dut.genblk2.U_ELY_RSP_DETECT   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_ELY_RSP_DETECT  tb_top.dut.genblk2.U_RSP_ORDER   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_ORDER  tb_top.dut.genblk2.U_ELY_RSP_DETECT   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_ELY_RSP_DETECT  tb_top.dut.genblk2.U_RSP_ORDER   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_ORDER  tb_top.dut.genblk2.U_RSP_TRANS   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.genblk2.U_RSP_TRANS  tb_top.dut.U_WATCHDOG   }
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut.U_WATCHDOG
gui_list_expand -id CoverageTable.1   tb_top.dut.U_WATCHDOG
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_WATCHDOG  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {timout_table_index[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {timout_table_index[2:0]}  {timout_table_index_hot[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {timout_table_index_hot[7:0]}  {wd2rspo_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {wd2rspo_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_opc[1:0]}  {wd2rspo_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {wd2rspo_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_opc[1:0]}  {data_in[5:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {data_in[1]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_WATCHDOG.data_in[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.data_in[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT.data_in[1]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {data_in[5:0]}  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {data_out[1:0]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_WATCHDOG.data_out[1:0]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.data_out[1:0]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT.data_out[1:0]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.wd2rspo_opc[1:0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.wd2rspo_opc[1:0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.wd2rspo_opc[1:0]
gui_exclude_conn_signals_add -signal tb_top.dut.genblk2.U_RSP_ORDER.wd2rspo_opc[1:0]
gui_exclude_conn_signals_add -signal tb_top.dut.wd2rspo_opc[1:0]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  {data_in[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_in[5:0]}  {reqo2wd_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {reqo2wd_axid[3:0]}  {reqo2wd_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {reqo2wd_opc[1:0]}  {reqo2wd_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {reqo2wd_axid[3:0]}  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  {rsp_timnot[15:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rsp_timnot[15]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_WATCHDOG.rsp_timnot[15]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.rsp_timnot[15]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {rsp_timnot[15:0]}  {timout_table_index[2:0]}   }
