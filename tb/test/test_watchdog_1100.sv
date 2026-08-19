`ifndef TEST_WATCHDOG_1100_SV
`define TEST_WATCHDOG_1100_SV

// =============================================================================
// Modified coverage-directed watchdog test.
//
// Coverage target added:
//   cg_timeout.x_timeout_mix
//     previous timeout direction = READ
//     current  timeout direction = READ
//
// The existing test used one seq_norm_rd request.  Sending two consecutive
// reads with AXI response delay 11000 (> TIMOUT_VALUE=10240) makes both requests
// expire in the DUT watchdog, giving READ-timeout -> READ-timeout.
// =============================================================================

class test_watchdog_1100 extends axi_tniu_base_test;
  `uvm_component_utils(test_watchdog_1100)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    cfg.axi_ooo_en              = 1'b0;
    cfg.axi_interleave_en       = 1'b0;
    cfg.axi_force_interleave_en = 1'b0;

    cfg.axi_ready_bp_en = 1'b0;
    cfg.rsp_ready_bp_en = 1'b0;
    cfg.rsp_ready_low_pct = 0;

    cfg.axi_slverr_pct          = 0;
    cfg.axi_error_rsp_en        = 1'b0;

    // DUT watchdog threshold is 10240 cycles.  Capture each AR with a response
    // delay beyond that threshold so both reads generate EC_TIMEOUT first.
    cfg.axi_min_resp_delay = 11000;
    cfg.axi_max_resp_delay = 11000;

    // Keep the two timeout requests close together and deterministic.
    cfg.req_min_gap = 0;
    cfg.req_max_gap = 0;

    // Must also allow the deliberately late AXI R completions to drain.
    cfg.rsp_drain_timeout = 250us;
  endfunction

  virtual task run_testcase();
    seq_norm_rd rd_seq;

    rd_seq = seq_norm_rd::type_id::create("rd_seq");

    // ORIGINAL: rd_seq.num_txn = 1;
    //
    // Two consecutive timeout reads are the minimal directed stimulus for:
    //   x_timeout_mix : READ -> READ
    rd_seq.num_txn = 2;

    start_rknp_sequence(rd_seq);
  endtask

endclass : test_watchdog_1100

`endif // TEST_WATCHDOG_1100_SV
