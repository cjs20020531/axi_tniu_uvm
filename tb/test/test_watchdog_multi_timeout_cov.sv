`ifndef TEST_WATCHDOG_MULTI_TIMEOUT_COV_SV
`define TEST_WATCHDOG_MULTI_TIMEOUT_COV_SV

class test_watchdog_multi_timeout_cov extends axi_tniu_base_test;
  `uvm_component_utils(test_watchdog_multi_timeout_cov)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    cfg.axi_min_resp_delay = 11000;
    cfg.axi_max_resp_delay = 11000;

    cfg.axi_min_addr_delay = 0;
    cfg.axi_max_addr_delay = 0;
    cfg.axi_min_beat_gap   = 0;
    cfg.axi_max_beat_gap   = 0;

    cfg.axi_ready_bp_en        = 1'b0;
    cfg.rsp_ready_bp_en        = 1'b0;
    cfg.axi_error_rsp_en       = 1'b0;

    cfg.axi_ooo_en              = 1'b0;
    cfg.axi_interleave_en       = 1'b0;
    cfg.axi_force_interleave_en = 1'b0;

    cfg.req_min_gap = 0;
    cfg.req_max_gap = 0;

    cfg.num_txn           = 8;
    cfg.rsp_drain_timeout = 300us;
  endfunction

  virtual task run_testcase();
    seq_watchdog_multi_timeout_cov seq;

    seq = seq_watchdog_multi_timeout_cov::type_id::create("seq");
    seq.num_txn = 8;
    start_rknp_sequence(seq);
  endtask

endclass : test_watchdog_multi_timeout_cov

`endif // TEST_WATCHDOG_MULTI_TIMEOUT_COV_SV
