`ifndef TEST_TIMEOUT_BUSY_CONTEXT_SAME_AXID_SV
`define TEST_TIMEOUT_BUSY_CONTEXT_SAME_AXID_SV

// =============================================================================
// File        : test_timeout_busy_context_same_axid.sv
// Description : Coverage-directed same-AXID timeout-context test.
//
// Why this test is one-case-per-run:
//   After a DUT watchdog timeout, the real late AXI R/B transaction may no
//   longer complete on the interface.  Therefore traffic_drained() can remain
//   false forever (especially for a timed-out write whose late B never
//   handshakes).  Chaining four timeout blocks in one simulation is unsafe.
//
// This class stays as ONE test class, but selects one of the four missing
// x_busy_context bins with +TIMEOUT_BUSY_CASE=<0..3>.  Run the same test four
// times and merge coverage.
//
// Cases:
//   0 : previous WR response -> current WR timeout -> same AXID
//   1 : previous WR response -> current RD timeout -> same AXID
//   2 : previous RD response -> current WR timeout -> same AXID
//   3 : previous RD response -> current RD timeout -> same AXID
//
// Both requests in the selected case use the same fixed OrderKey, therefore the
// same mapped AXID.  The previous request returns normally.  The current request
// is delayed beyond the watchdog threshold and must produce an RKNP timeout.
//
// IMPORTANT:
//   Once the target timeout response has already been observed and checked, this
//   coverage-only test disables scoreboard leak/drain accounting.  This prevents
//   the intentionally abandoned late AXI response from making base-test
//   traffic_drained() wait forever.  The actual normal response and watchdog
//   timeout response are checked BEFORE checks_enable is disabled.
// =============================================================================

class test_timeout_busy_context_same_axid extends axi_tniu_base_test;
  `uvm_component_utils(test_timeout_busy_context_same_axid)

  localparam axi_tniu_protocol_pkg::ordkey_t FIXED_ORDERKEY = 8'h01;

  localparam int unsigned NORMAL_DELAY = 0;

  // Keep the real AXI completion well beyond both the DUT watchdog point and
  // the base-test's final 10us grace period after the timeout response.
  // TIMOUT_VALUE is currently 10240 cycles.
  localparam int unsigned TIMEOUT_DELAY = 15000;

  int unsigned busy_case = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    int unsigned plusarg_case;

    cfg.axi_ooo_en              = 1'b0;
    cfg.axi_interleave_en       = 1'b0;
    cfg.axi_force_interleave_en = 1'b0;

    cfg.axi_ready_bp_en   = 1'b0;
    cfg.rsp_ready_bp_en   = 1'b0;
    cfg.rsp_ready_low_pct = 0;

    cfg.axi_error_rsp_en = 1'b0;
    cfg.axi_slverr_pct   = 0;

    cfg.req_min_gap = 0;
    cfg.req_max_gap = 0;

    cfg.axi_min_resp_delay = NORMAL_DELAY;
    cfg.axi_max_resp_delay = NORMAL_DELAY;

    cfg.rsp_drain_timeout = 200us;

    if ($value$plusargs("TIMEOUT_BUSY_CASE=%d", plusarg_case))
      busy_case = plusarg_case;

    if (busy_case > 3)
      `uvm_fatal(
        "TIMEOUT_BUSY_CASE",
        $sformatf("TIMEOUT_BUSY_CASE=%0d is illegal; expected 0..3",
                  busy_case)
      )
  endfunction

  protected task wait_for_one_final_rsp(
      int unsigned start_count,
      time         timeout_value,
      string       label);

    bit done;
    done = 1'b0;

    fork : wait_one_rsp
      begin
        wait (env.sb.n_rsp_matched_final >= start_count + 1);
        done = 1'b1;
      end
      begin
        #(timeout_value);
      end
    join_any
    disable wait_one_rsp;

    if (!done)
      `uvm_fatal(
        "TIMEOUT_BUSY_WAIT",
        $sformatf("%s: no matched final RKNP response within %0t",
                  label, timeout_value)
      )
  endtask

  protected function string case_name();
    case (busy_case)
      0: return "WR_rsp_to_WR_timeout";
      1: return "WR_rsp_to_RD_timeout";
      2: return "RD_rsp_to_WR_timeout";
      3: return "RD_rsp_to_RD_timeout";
      default: return "ILLEGAL";
    endcase
  endfunction

  protected function bit prev_is_write();
    return (busy_case == 0) || (busy_case == 1);
  endfunction

  protected function bit timeout_is_write();
    return (busy_case == 0) || (busy_case == 2);
  endfunction

  virtual task run_testcase();
    seq_timeout_busy_context_same_axid prev_seq;
    seq_timeout_busy_context_same_axid timeout_seq;
    axi_tniu_protocol_pkg::axi_id_t    expected_axid;
    int unsigned                       rsp_count;

    expected_axid =
      axi_tniu_protocol_pkg::map_ordkey_to_axid(FIXED_ORDERKEY);

    `uvm_info(
      "TEST_TIMEOUT_BUSY_SAME_AXID",
      $sformatf(
        "case=%0d %s, fixed OrderKey=0x%0h -> AXID=0x%0h",
        busy_case, case_name(), FIXED_ORDERKEY, expected_axid
      ),
      UVM_LOW
    )

    // -------------------------------------------------------------------------
    // 1) Previous request: normal response.
    // -------------------------------------------------------------------------
    cfg.axi_min_resp_delay = NORMAL_DELAY;
    cfg.axi_max_resp_delay = NORMAL_DELAY;

    rsp_count = env.sb.n_rsp_matched_final;

    prev_seq =
      seq_timeout_busy_context_same_axid::type_id::create("prev_seq");

    prev_seq.send_write         = prev_is_write();
    prev_seq.use_fixed_orderkey = 1'b1;
    prev_seq.fixed_orderkey     = FIXED_ORDERKEY;
    prev_seq.iid_value          = 10'h180;
    prev_seq.tid_value          = 10'h080;
    prev_seq.addr_value         = 32'h6800_0000;

    start_rknp_sequence(prev_seq);

    wait_for_one_final_rsp(
      rsp_count,
      30us,
      $sformatf("%s previous normal response", case_name())
    );

    // -------------------------------------------------------------------------
    // 2) Current request: SAME AXID, watchdog timeout.
    //
    // The AXI slave captures this delay when AR handshakes, or after both AW
    // and WLAST have completed.  We do not change the delay again afterwards.
    // -------------------------------------------------------------------------
    cfg.axi_min_resp_delay = TIMEOUT_DELAY;
    cfg.axi_max_resp_delay = TIMEOUT_DELAY;

    rsp_count = env.sb.n_rsp_matched_final;

    timeout_seq =
      seq_timeout_busy_context_same_axid::type_id::create("timeout_seq");

    timeout_seq.send_write         = timeout_is_write();
    timeout_seq.use_fixed_orderkey = 1'b1;
    timeout_seq.fixed_orderkey     = FIXED_ORDERKEY;

    // IID/TID may differ: x_busy_context same-AXID coverage depends on mapped
    // AXID, not on requiring the complete RKNP transaction key to be identical.
    timeout_seq.iid_value          = 10'h181;
    timeout_seq.tid_value          = 10'h081;
    timeout_seq.addr_value         = 32'h6800_1000;

    start_rknp_sequence(timeout_seq);

    wait_for_one_final_rsp(
      rsp_count,
      160us,
      $sformatf("%s current watchdog timeout", case_name())
    );

    // -------------------------------------------------------------------------
    // 3) Coverage target is now sampled and the RKNP timeout response has
    //    already passed scoreboard checking.
    //
    // Do NOT call traffic_drained() here.  A watchdog-abandoned late AXI R/B
    // may never handshake, so traffic_drained() is not a valid completion
    // criterion for this targeted timeout test.
    //
    // Disabling checks at this point makes the inherited base-test drain use
    // n_rsp_final instead of traffic_drained(), and makes check_phase skip AXI
    // leak accounting for the intentionally abandoned late response.
    // -------------------------------------------------------------------------
    cfg.checks_enable = 1'b0;

    `uvm_info(
      "TEST_TIMEOUT_BUSY_SAME_AXID",
      $sformatf(
        "%s target RKNP timeout observed; disabling post-timeout AXI leak/drain checking",
        case_name()
      ),
      UVM_LOW
    )
  endtask

endclass : test_timeout_busy_context_same_axid

`endif // TEST_TIMEOUT_BUSY_CONTEXT_SAME_AXID_SV
