`ifndef TEST_WATCHDOG_NORMAL_TIMEOUT_SV
`define TEST_WATCHDOG_NORMAL_TIMEOUT_SV

class test_watchdog_normal_timeout extends axi_tniu_base_test;
  `uvm_component_utils(test_watchdog_normal_timeout)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    cfg.axi_ooo_en          = 1'b0;
    cfg.axi_interleave_en   = 1'b0;
    cfg.axi_ready_bp_en     = 1'b0;
    cfg.rsp_ready_bp_en     = 1'b0;
    cfg.axi_slverr_pct      = 0;
    cfg.axi_min_resp_delay  = 16;
    cfg.axi_max_resp_delay  = 16;
    cfg.rsp_drain_timeout   = 200us;
  endfunction

  virtual task run_testcase();
    seq_norm_rd normal_seq;
    seq_norm_rd timeout_seq;
    int unsigned normal_r_count;

    normal_r_count = env.sb.n_r;

    normal_seq = seq_norm_rd::type_id::create("normal_seq");
    normal_seq.num_txn = 1;
    start_rknp_sequence(normal_seq);

    // Wait until the first normal AXI read response has completed before
    // changing the shared slave response-delay configuration.
    wait (env.sb.n_r >= normal_r_count + 1);

    cfg.axi_min_resp_delay = 1100;
    cfg.axi_max_resp_delay = 1100;

    timeout_seq = seq_norm_rd::type_id::create("timeout_seq");
    timeout_seq.num_txn = 1;
    start_rknp_sequence(timeout_seq);
  endtask

endclass : test_watchdog_normal_timeout

`endif // TEST_WATCHDOG_NORMAL_TIMEOUT_SV
