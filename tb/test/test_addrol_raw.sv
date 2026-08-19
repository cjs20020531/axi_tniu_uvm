`ifndef TEST_ADDROL_RAW_SV
`define TEST_ADDROL_RAW_SV

// =============================================================================
// File        : test_addrol_raw.sv
// Description : Runs seq_addrol_raw to close the RAW half of cg_addr_overlap.
// =============================================================================

class test_addrol_raw extends axi_tniu_base_test;
  `uvm_component_utils(test_addrol_raw)

  function new(string name = "test_addrol_raw",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    super.configure_cfg();

    cfg.axi_ooo_en              = 1'b0;
    cfg.axi_interleave_en       = 1'b0;
    cfg.axi_force_interleave_en = 1'b0;

    cfg.axi_ready_bp_en         = 1'b0;
    cfg.rsp_ready_bp_en         = 1'b0;
    cfg.rsp_ready_low_pct       = 0;

    cfg.axi_error_rsp_en         = 1'b0;
    cfg.axi_error_resp_random_en = 1'b0;

    cfg.req_min_gap = 0;
    cfg.req_max_gap = 0;

    cfg.rsp_drain_timeout = 2ms;
  endfunction

  virtual task run_testcase();
    seq_addrol_raw seq;

    seq = seq_addrol_raw::type_id::create("seq");

    `uvm_info(
      "TEST_ADDROL_RAW",
      "Run RAW cg_addr_overlap closure: overlap 1..63 + 4 burst pairs",
      UVM_LOW
    )

    start_rknp_sequence(seq);
  endtask

endclass : test_addrol_raw

`endif // TEST_ADDROL_RAW_SV
