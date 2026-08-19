`ifndef TEST_ADDROL_WAW_SV
`define TEST_ADDROL_WAW_SV

// =============================================================================
// File        : test_addrol_waw.sv
// Description : Runs seq_addrol_waw to close the WAW half of cg_addr_overlap.
// =============================================================================

class test_addrol_waw extends axi_tniu_base_test;
  `uvm_component_utils(test_addrol_waw)

  function new(string name = "test_addrol_waw",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    super.configure_cfg();

    // Make this a deterministic address-overlap test.  Response-side random
    // features are unnecessary for cg_addr_overlap.
    cfg.axi_ooo_en              = 1'b0;
    cfg.axi_interleave_en       = 1'b0;
    cfg.axi_force_interleave_en = 1'b0;

    cfg.axi_ready_bp_en         = 1'b0;
    cfg.rsp_ready_bp_en         = 1'b0;
    cfg.rsp_ready_low_pct       = 0;

    cfg.axi_error_rsp_en         = 1'b0;
    cfg.axi_error_resp_random_en = 1'b0;

    // Request gap does not affect cg_addr_overlap.  A fixed zero gap keeps the
    // test compact with the gap-aware RKNP driver.
    cfg.req_min_gap = 0;
    cfg.req_max_gap = 0;

    cfg.rsp_drain_timeout = 2ms;
  endfunction

  virtual task run_testcase();
    seq_addrol_waw seq;

    seq = seq_addrol_waw::type_id::create("seq");

    `uvm_info(
      "TEST_ADDROL_WAW",
      "Run WAW cg_addr_overlap closure: overlap 1..63 + 4 burst pairs",
      UVM_LOW
    )

    start_rknp_sequence(seq);
  endtask

endclass : test_addrol_waw

`endif // TEST_ADDROL_WAW_SV
