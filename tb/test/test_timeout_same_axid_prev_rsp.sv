`ifndef TEST_TIMEOUT_SAME_AXID_PREV_RSP_SV
`define TEST_TIMEOUT_SAME_AXID_PREV_RSP_SV

// =============================================================================
// File        : test_timeout_same_axid_prev_rsp.sv
// Coverage target:
//   cg_timeout.cp_same_axid_prev_rsp.same
//
// Stimulus:
//   1) normal READ response on fixed AXID
//   2) READ watchdog timeout on the SAME fixed AXID
//
// The second timed-out read is LEN=7 and 8B aligned, so it also targets:
//   cg_timeout.cp_body_shape.full
// =============================================================================

class test_timeout_same_axid_prev_rsp extends axi_tniu_base_test;
  `uvm_component_utils(test_timeout_same_axid_prev_rsp)

  localparam axi_tniu_protocol_pkg::ordkey_t FIXED_ORDERKEY = 8'h01;
  localparam int unsigned NORMAL_DELAY  = 0;
  localparam int unsigned TIMEOUT_DELAY = 11000;

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

    cfg.axi_error_rsp_en = 1'b0;
    cfg.axi_slverr_pct   = 0;

    cfg.req_min_gap = 0;
    cfg.req_max_gap = 0;

    cfg.axi_min_resp_delay = NORMAL_DELAY;
    cfg.axi_max_resp_delay = NORMAL_DELAY;

    cfg.rsp_drain_timeout = 300us;
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
        "TIMEOUT_COV_WAIT",
        $sformatf("%s: no final RKNP response within %0t",
                  label, timeout_value)
      )
  endtask

  virtual task run_testcase();
    seq_timeout_same_axid_prev_rsp prev_seq;
    seq_timeout_same_axid_prev_rsp timeout_seq;
    int unsigned rsp_count;
    axi_tniu_protocol_pkg::axi_id_t expected_axid;

    expected_axid =
      axi_tniu_protocol_pkg::map_ordkey_to_axid(FIXED_ORDERKEY);

    `uvm_info(
      "TEST_TIMEOUT_SAME_AXID",
      $sformatf("Fixed OrderKey=0x%0h maps to AXID=0x%0h",
                FIXED_ORDERKEY, expected_axid),
      UVM_LOW
    )

    // -------------------------------------------------------------------------
    // Step 1: produce a NORMAL previous RKNP READ response.
    // -------------------------------------------------------------------------
    cfg.axi_min_resp_delay = NORMAL_DELAY;
    cfg.axi_max_resp_delay = NORMAL_DELAY;

    rsp_count = env.sb.n_rsp_matched_final;

    prev_seq = seq_timeout_same_axid_prev_rsp::type_id::create("prev_seq");
    prev_seq.send_write         = 1'b0;
    prev_seq.use_fixed_orderkey = 1'b1;
    prev_seq.fixed_orderkey     = FIXED_ORDERKEY;
    prev_seq.iid_value          = 10'h120;
    prev_seq.tid_value          = 10'h220;
    prev_seq.addr_value         = 32'h6000_0000;

    start_rknp_sequence(prev_seq);
    wait_for_one_final_rsp(rsp_count, 30us, "normal previous READ");

    // -------------------------------------------------------------------------
    // Step 2: use the SAME OrderKey/AXID, but make the AXI response later than
    //         the DUT watchdog threshold.  The current RKNP response must be
    //         EC_TIMEOUT while cp_same_axid_prev_rsp sees "same".
    // -------------------------------------------------------------------------
    cfg.axi_min_resp_delay = TIMEOUT_DELAY;
    cfg.axi_max_resp_delay = TIMEOUT_DELAY;

    rsp_count = env.sb.n_rsp_matched_final;

    timeout_seq =
      seq_timeout_same_axid_prev_rsp::type_id::create("timeout_seq");
    timeout_seq.send_write         = 1'b0;
    timeout_seq.use_fixed_orderkey = 1'b1;
    timeout_seq.fixed_orderkey     = FIXED_ORDERKEY;
    timeout_seq.iid_value          = 10'h121;
    timeout_seq.tid_value          = 10'h221;
    timeout_seq.addr_value         = 32'h6000_1000;

    start_rknp_sequence(timeout_seq);
    wait_for_one_final_rsp(rsp_count, 160us, "same-AXID READ timeout");

    // Base-test drain_responses() will additionally wait for the deliberately
    // late real AXI R completion to retire from the scoreboard.
  endtask

endclass : test_timeout_same_axid_prev_rsp

`endif // TEST_TIMEOUT_SAME_AXID_PREV_RSP_SV
