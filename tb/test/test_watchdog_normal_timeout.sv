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
    cfg.axi_min_resp_delay  = 11000;
    cfg.axi_max_resp_delay  = 11000;
    cfg.rsp_drain_timeout   = 200us;
  endfunction

  virtual task run_testcase();
    seq_norm_rd timeout_seq;
    seq_norm_rd normal_seq;
    int unsigned first_rsp_count;

    first_rsp_count = env.sb.n_rsp_matched_final;

    // The first request is delayed for 1100 cycles and must therefore receive
    // the DUT-generated watchdog timeout response.
    timeout_seq = seq_norm_rd::type_id::create("timeout_seq");
    timeout_seq.num_txn = 1;
    timeout_seq.start(env.rknp_agt.sqr);

    // Do not send the following requests until the timeout response has
    // actually left the DUT. This keeps only the first request timed out.
    // wait (env.sb.n_rsp_matched_final >= first_rsp_count + 1);
    #100000ns
    // get_resp_delay() for the first AXI request has already captured 1100.
    // New requests use zero delay and return normally after the timeout packet.
    cfg.axi_min_resp_delay = 0;
    cfg.axi_max_resp_delay = 4;
    
    // 等到下降沿后再启动sequence，确保请求在下一个上升沿前稳定。
    @(negedge env.rknp_agt.drv.vif.aclk);
    normal_seq = seq_norm_rd::type_id::create("normal_seq");
    
    normal_seq.num_txn = 20;
    normal_seq.start(env.rknp_agt.sqr);
  endtask

endclass : test_watchdog_normal_timeout

`endif // TEST_WATCHDOG_NORMAL_TIMEOUT_SV
