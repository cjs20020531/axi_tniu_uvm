`ifndef TEST_WATCHDOG_FIFO_FULL_COV_SV
`define TEST_WATCHDOG_FIFO_FULL_COV_SV

// =============================================================================
// File        : test_watchdog_fifo_full_cov.sv
// Description : Directed coverage test for watchdog timeout FIFO.
//
// Coverage intent:
//   round 1 : FIFO write 8 -> full -> drain 8
//             wr_ptr/rd_ptr MSB : 0 -> 1
//
//   round 2 : WITHOUT reset, repeat FIFO write 8 -> full -> drain 8
//             wr_ptr/rd_ptr MSB : 1 -> 0
//
// This test reuses seq_watchdog_fifo_full_cov and does not require a new seq.
// =============================================================================

class test_watchdog_fifo_full_cov extends axi_tniu_base_test;

  `uvm_component_utils(test_watchdog_fifo_full_cov)

  // Keep this consistent with the watchdog parameter used by the DUT build.
  localparam int unsigned WATCHDOG_TIMEOUT_CYCLES = 10240;

  // The sequence has already completed request injection when this wait starts,
  // so this margin only needs to cover pipeline/skew between the 8 requests.
  localparam int unsigned TIMEOUT_MARGIN_CYCLES   = 256;

  // Two rounds are required for the 4-bit FIFO pointer MSB to see both:
  //   round 1 : 0 -> 1
  //   round 2 : 1 -> 0
  localparam int unsigned NUM_FIFO_ROUNDS         = 2;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // ---------------------------------------------------------------------------
  // Test configuration
  // ---------------------------------------------------------------------------
  virtual function void configure_cfg();

    // Keep AXI request acceptance deterministic.
    cfg.axi_ooo_en          = 1'b0;
    cfg.axi_interleave_en   = 1'b0;
    cfg.axi_ready_bp_en     = 1'b0;

    // This test needs deterministic RKNP response blocking.
    //
    // Prerequisite:
    // rknp_driver::rsp_ready_gen() must use cfg.rsp_ready_low_pct:
    //
    //   vif.txrsp_ready <=
    //       ($urandom_range(99, 0) >= cfg.rsp_ready_low_pct);
    //
    // Therefore:
    //   100 -> txrsp_ready always 0
    //     0 -> txrsp_ready always 1
    cfg.rsp_ready_bp_en     = 1'b1;
    cfg.rsp_ready_low_pct   = 100;

    // The 8 normal writes must timeout before their AXI B responses return.
    cfg.axi_min_resp_delay  = 13000;
    cfg.axi_max_resp_delay  = 13000;

    cfg.axi_min_beat_gap    = 0;
    cfg.axi_max_beat_gap    = 0;

    // Do not mix AXI response-error injection into this FIFO coverage test.
    cfg.axi_error_rsp_en    = 1'b0;
    cfg.axi_slverr_pct      = 0;

    // Inject the directed requests as tightly as possible.
    cfg.req_min_gap         = 0;
    cfg.req_max_gap         = 0;

    // Allow enough time for late AXI responses to drain after each timeout round.
    cfg.rsp_drain_timeout   = 500us;

  endfunction

  // ---------------------------------------------------------------------------
  // Run one complete:
  //
  //   block RKNP response
  //       -> send blocker + 8 timeout writes
  //       -> wait until all 8 watchdog entries timeout
  //       -> timeout FIFO becomes FULL
  //       -> release RKNP response
  //       -> drain FIFO completely
  //
  // IMPORTANT:
  // There is intentionally NO reset between rounds.
  // ---------------------------------------------------------------------------
  protected task run_one_full_drain_round(int unsigned round_no);

    seq_watchdog_fifo_full_cov seq;

    `uvm_info(
      "WD_FIFO_COV",
      $sformatf(
        "Round %0d/%0d: force txrsp_ready LOW and start one 8-entry FIFO fill",
        round_no, NUM_FIFO_ROUNDS
      ),
      UVM_LOW
    )

    // Re-arm the response blocker before creating the next batch.
    cfg.rsp_ready_bp_en   = 1'b1;
    cfg.rsp_ready_low_pct = 100;

    // Give rsp_ready_gen() several clocks to observe the runtime cfg change.
    repeat (4) @(posedge env.rknp_agt.drv.vif.aclk);

    // Reuse the existing directed sequence.
    // It is expected to generate:
    //   1 x special ERR read response used as the response-path blocker
    //   8 x normal writes whose AXI B responses are delayed past watchdog timeout
    seq = seq_watchdog_fifo_full_cov::type_id::create(
            $sformatf("seq_watchdog_fifo_full_cov_round_%0d", round_no)
          );

    seq.start(env.rknp_agt.sqr);

    // seq.start() returns after all requests have been driven.
    // Keep txrsp_ready LOW long enough for even the LAST of the 8 writes
    // to cross the watchdog timeout point.
    repeat (WATCHDOG_TIMEOUT_CYCLES + TIMEOUT_MARGIN_CYCLES)
      @(posedge env.rknp_agt.drv.vif.aclk);

    `uvm_info(
      "WD_FIFO_COV",
      $sformatf(
        "Round %0d: timeout window complete; release txrsp_ready so FIFO can drain",
        round_no
      ),
      UVM_LOW
    )

    // Release response path. The full FIFO should now be read out.
    cfg.rsp_ready_low_pct = 0;

    repeat (4) @(posedge env.rknp_agt.drv.vif.aclk);

    // Wait not only for the 8 timeout responses, but also for any late AXI
    // traffic belonging to this round. This guarantees the next round starts
    // from an empty protocol state while preserving FIFO pointer history.
    drain_responses();

    `uvm_info(
      "WD_FIFO_COV",
      $sformatf(
        "Round %0d complete: FIFO drained. No reset is applied before next round.",
        round_no
      ),
      UVM_LOW
    )

    // Small clean separation between rounds; this does NOT reset the DUT.
    repeat (16) @(posedge env.rknp_agt.drv.vif.aclk);

  endtask

  // ---------------------------------------------------------------------------
  // Main testcase
  // ---------------------------------------------------------------------------
  virtual task run_testcase();

    for (int unsigned round = 1; round <= NUM_FIFO_ROUNDS; round++) begin
      run_one_full_drain_round(round);
    end

    // Leave DUT in normal "always ready" state.
    cfg.rsp_ready_low_pct = 0;

    `uvm_info(
      "WD_FIFO_COV",
      {"Completed two FIFO full/drain rounds without reset. ",
       "Expected pointer-MSB transitions: 0->1 in round 1 and 1->0 in round 2."},
      UVM_LOW
    )

  endtask

endclass : test_watchdog_fifo_full_cov

`endif // TEST_WATCHDOG_FIFO_FULL_COV_SV
