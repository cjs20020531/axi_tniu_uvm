// =============================================================================
// File        : test_tag_name_toggle.sv
// Description : Three directed allocation rounds that toggle every reachable
//               AXID/opc/used bit in reqo2rspo_tag_name in both directions.
// =============================================================================
`ifndef TEST_TAG_NAME_TOGGLE_SV
`define TEST_TAG_NAME_TOGGLE_SV

class test_tag_name_toggle extends axi_tniu_base_test;
  `uvm_component_utils(test_tag_name_toggle)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    // Eight one-byte requests must coexist long enough to occupy all eight
    // tag_name entries.  200 cycles is safely below the 1024-cycle watchdog.
    cfg.axi_min_resp_delay = 200;
    cfg.axi_max_resp_delay = 200;
    cfg.req_min_gap        = 0;
    cfg.req_max_gap        = 0;

    // Remove unrelated random timing so entry allocation/reuse is repeatable.
    cfg.axi_ooo_en         = 1'b0;
    cfg.axi_interleave_en  = 1'b0;
    cfg.axi_ready_bp_en    = 1'b0;
    cfg.rsp_ready_bp_en    = 1'b0;
    cfg.axi_error_rsp_en   = 1'b0;
    cfg.rsp_drain_timeout  = 100us;
  endfunction

  protected task run_round(
    string round_name,
    bit    invert_axid,
    bit    send_write
  );
    seq_tag_name_toggle seq;
    int unsigned        expected_final_rsp;
    bit                 round_done;

    expected_final_rsp = env.sb.n_rsp_matched_final + 8;
    seq = seq_tag_name_toggle::type_id::create({"seq_", round_name});
    seq.num_txn     = 8;
    seq.invert_axid = invert_axid;
    seq.send_write  = send_write;

    `uvm_info("TAG_TOGGLE", $sformatf(
      "Start %s: invert_axid=%0b direction=%s",
      round_name, invert_axid, send_write ? "WRITE" : "READ"), UVM_LOW)

    // This is a fixed 8-entry coverage pattern; do not apply the generic
    // +num_txn override used by random tests.
    seq.start(env.rknp_agt.sqr);

    // Start the next round only after all entries from this round have been
    // retired, so the lowest-free-entry allocator reuses slots 0 through 7 in
    // exactly the same order.
    round_done = 1'b0;
    fork : wait_round_done
      begin
        wait (env.sb.n_rsp_matched_final >= expected_final_rsp);
        round_done = 1'b1;
      end
      begin
        #50us;
      end
    join_any
    disable wait_round_done;

    if (!round_done)
      `uvm_fatal("TAG_TOGGLE", $sformatf(
        "%s timed out: expected final_rsp=%0d, observed=%0d",
        round_name, expected_final_rsp, env.sb.n_rsp_matched_final))
  endtask

  virtual task run_testcase();
    // For each physical tag_name entry:
    //   round_a : AXID=i,  opc[2]=1
    //   round_b : AXID=~i, opc[2]=0
    //   round_c : AXID=i,  opc[2]=1
    // Therefore every AXID bit and opc[2] toggles in both directions.
    run_round("round_a_write", 1'b0, 1'b1);
    run_round("round_b_read",  1'b1, 1'b0);
    run_round("round_c_write", 1'b0, 1'b1);
  endtask

endclass : test_tag_name_toggle

`endif // TEST_TAG_NAME_TOGGLE_SV
