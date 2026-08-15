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
