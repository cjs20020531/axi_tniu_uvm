gui_exclusion -set_force true
gui_assert_mode -mode flat
gui_class_mode -mode hier
gui_excl_mgr_flat_list -on  0
gui_covdetail_select -id  CovDetail.1   -name   Line
verdiWindowWorkMode -win $_vdCoverage_1 -coverageAnalysis
gui_open_cov  -hier cov.vdb -testdir {} -test {cov/test_watchdog_1024_1 cov/test_watchdog_1100_1 cov/test_watchdog_normal_timeout_1 cov/test_watchdog_bufferable_1100_1 cov/test_watchdog_timer_wrap_cov_1 cov/test_norm_mix_stresstest_1 cov/test_rwrap_stresstest_1 cov/test_tag_name_toggle_1 cov/test_err_wr_1 cov/test_err_wrw_1 cov/test_err_mix_fixordkey_1 cov/test_buff_wr_1 cov/test_buff_mix_fixordkey_1 cov/test_buff_err_mix_1 cov/test_axi_rsp_error_mix_1 cov/test_rsp_order_deep_followers_1 cov/test_norm_rd_1 cov/test_norm_wr_1 cov/test_norm_wrw_1 cov/test_watchdog_1023_1 cov/test_err_rd_1 cov/test_err_mix_1 cov/test_buff_wrw_1 cov/test_buff_mix_1 cov/test_addrol_raw_1 cov/test_rsp_order_high_firstflag_1 cov/test_norm_rdw_1 cov/test_norm_wrw_narrow_noalign_1 cov/test_watchdog_multi_timeout_cov_1 cov/test_addrol_waw_1 cov/test_mix_1 cov/test_aresetn_recovery_1 cov/test_norm_rdw_narrow_noalign_1 cov/test_norm_mix_1 cov/test_err_rdw_1} -merge MergedTest -db_max_tests 10 -fsm transition
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WATCHDOG   }
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut.U_WATCHDOG
gui_list_expand -id CoverageTable.1   tb_top.dut.U_WATCHDOG
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_WATCHDOG  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {data_out[4]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {data_out[4]}  {data_out[1:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {data_out[1:0]}  {data_out[4]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {data_out[4]}  {data_out[1:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {data_out[1:0]}  {data_out[4]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {data_out[4]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  {data_in[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_in[5:0]}  {timout_table_index[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {timout_table_index[2:0]}  {timout_table_index_hot[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {timout_table_index_hot[7:0]}  {wd2rspo_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {wd2rspo_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_opc[1:0]}  {timout_table_index[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {timout_table_index[2:0]}  {timout_table_index_hot[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {timout_table_index_hot[7:0]}  {wd2rspo_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_opc[1:0]}  {wd2rspo_axid[3:0]}   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WATCHDOG  tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT  tb_top.dut.U_WATCHDOG   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  {data_in[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_in[5:0]}  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  {rsp_timnot[15:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rsp_timnot[15:0]}  {rsp_timnot_tamp[16:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rsp_timnot_tamp[16:15]}   }
gui_list_select -id CovDetail.1 -list tgl { {rsp_timnot_tamp[16:0]}  {rsp_timnot[15:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rsp_timnot[15:0]}  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  clk   }
gui_list_select -id CovDetail.1 -list tgl { clk  {data_in[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_in[5:0]}  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  {data_in[5:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {data_in[1]}   }
gui_load_kdb -path /home/ICer/RKNoC/axi_tniu_uvm/sim/simv.daidir/kdb.elab++
gui_exclude_conn_signals_begin -signal tb_top.dut.U_WATCHDOG.data_in[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.data_in[1]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT.data_in[1]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {data_in[5:0]}  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {data_out[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  {data_in[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_in[5:0]}  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {data_out[4]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {data_out[4]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  {rsp_timnot[15:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rsp_timnot[15:0]}  {rsp_timnot_tamp[16:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rsp_timnot_tamp[16:0]}  {rsp_timnot[15:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rsp_timnot[15:0]}  {rsp_timnot_tamp[16:0]}   }
gui_exclusion_file -save_all -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el}
gui_exclusion_file -load -file {/home/ICer/RKNoC/axi_tniu_uvm/sim/coverage_exclude.el} -bypass_checks
gui_list_select -id CovDetail.1 -list tgl { {rsp_timnot_tamp[16:0]}  {timout_table_index[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {timout_table_index[2:0]}  {timout_table_index_hot[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {timout_table_index_hot[7:0]}  {wd2rspo_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {timout_table_index_hot[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {timout_table_index_hot[7:0]}  {timout_table_index[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {timout_table_index[2:0]}  {timout_table_index_hot[7:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {timout_table_index_hot[7:0]}  {wd2rspo_axid[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_axid[3:0]}  {wd2rspo_opc[1:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wd2rspo_opc[1:0]}  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  {rsp_timnot[15:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rsp_timnot[15:0]}  {rsp_timnot_tamp[16:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rsp_timnot_tamp[16:0]}  {rsp_timnot[15:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {rsp_timnot[15]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_WATCHDOG.rsp_timnot[15]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.rsp_timnot[15]
gui_exclude_conn_signals_end
gui_list_select -id CovDetail.1 -list tgl { {rsp_timnot[15:0]}  {rsp_timnot_tamp[16:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rsp_timnot_tamp[16:0]}  {timer_cnt[15:0]}   }
gui_list_select -id CovDetail.1 -list tglDetail { {timer_cnt[15]}   }
gui_exclude_conn_signals_begin -signal tb_top.dut.U_WATCHDOG.timer_cnt[15]
gui_exclude_conn_signals_add -signal tb_top.dut.U_WATCHDOG.timer_cnt[15]
gui_exclude_conn_signals_end
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut.U_WATCHDOG  tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tb_top.dut.U_WATCHDOG.U_SYNC_FIFO_TIMOUT  -column {Toggle} 
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  {rd_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr[3:0]}  full   }
gui_list_select -id CovDetail.1 -list tgl { full  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr_true[2:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr_true[2:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  {rd_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr_true[2:0]}  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  {rd_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr[3:0]}  full   }
gui_list_select -id CovDetail.1 -list tgl { full  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  full   }
gui_list_select -id CovDetail.1 -list tgl { full  {rd_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr[3:0]}  {rd_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr_true[2:0]}  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  {rd_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr_true[2:0]}  {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr_true[2:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr_true[2:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr_true[2:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr_true[2:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}  {rd_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr_true[2:0]}  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  {rd_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr[3:0]}  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  {rd_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr_true[2:0]}  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  {rd_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr[3:0]}  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr_true[2:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr_true[2:0]}  wr_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { wr_ptr_msb  {wr_ptr_true[2:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr_true[2:0]}  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  {rd_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr[3:0]}  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  {rd_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {rd_ptr[3:0]}  rd_ptr_msb   }
gui_list_select -id CovDetail.1 -list tgl { rd_ptr_msb  {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_out[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {wr_ptr[3:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_in[5:0]}   }
gui_list_select -id CovDetail.1 -list tgl { {data_in[5:0]}   }
