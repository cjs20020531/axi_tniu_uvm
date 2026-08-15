`ifndef TEST_WATCHDOG_TIMER_WRAP_COV_SV
`define TEST_WATCHDOG_TIMER_WRAP_COV_SV

class test_watchdog_timer_wrap_cov extends axi_tniu_base_test;
  `uvm_component_utils(test_watchdog_timer_wrap_cov)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    // TIMOUT_VALUE=10240. 9500 keeps each request below timeout while still
    // keeping the 8-entry request buffer occupied long enough to refill it
    // repeatedly and carry timer_cnt across TIMER_CNT_MAX=20480.
    cfg.axi_min_resp_delay = 9500;
    cfg.axi_max_resp_delay = 9500;

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

    cfg.num_txn           = 32;
    cfg.rsp_drain_timeout = 800us;
  endfunction

  virtual task run_testcase();
    seq_norm_rd seq;

    seq = seq_norm_rd::type_id::create("seq");
    seq.num_txn = cfg.num_txn;
    start_rknp_sequence(seq);
  endtask

endclass : test_watchdog_timer_wrap_cov

`endif // TEST_WATCHDOG_TIMER_WRAP_COV_SV
