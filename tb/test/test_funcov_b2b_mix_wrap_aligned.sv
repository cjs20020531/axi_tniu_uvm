`ifndef TEST_FUNCOV_B2B_MIX_WRAP_ALIGNED_SV
`define TEST_FUNCOV_B2B_MIX_WRAP_ALIGNED_SV

// =============================================================================
// File        : test_funcov_b2b_mix_wrap_aligned.sv
// Description : Runs the aligned-WRAP adjacent mixed-request matrix, including
//               WRAP_WR->INCR_RD with true HEAD-to-HEAD back-to-back timing.
// =============================================================================

class test_funcov_b2b_mix_wrap_aligned extends axi_tniu_base_test;
  `uvm_component_utils(test_funcov_b2b_mix_wrap_aligned)

  function new(string name = "test_funcov_b2b_mix_wrap_aligned",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    // Keep response-side behavior simple so the request-pair matrix is the
    // dominant variable in this test.
    cfg.axi_ooo_en              = 1'b0;
    cfg.axi_interleave_en       = 1'b0;
    cfg.axi_force_interleave_en = 1'b0;

    cfg.axi_ready_bp_en         = 1'b0;
    cfg.rsp_ready_bp_en         = 1'b0;

    cfg.axi_min_addr_delay      = 0;
    cfg.axi_max_addr_delay      = 0;
    cfg.axi_min_resp_delay      = 0;
    cfg.axi_max_resp_delay      = 0;
    cfg.axi_min_beat_gap        = 0;
    cfg.axi_max_beat_gap        = 0;

    cfg.axi_rsp_user_random_en   = 1'b0;
    cfg.axi_rsp_user_fixed       = '0;

    cfg.axi_error_rsp_en         = 1'b0;
    cfg.axi_error_resp_random_en = 1'b0;

    // Kept at zero for compatibility with any future driver implementation
    // that consumes these request-gap knobs.
    cfg.req_min_gap       = 0;
    cfg.req_max_gap       = 0;
    cfg.rsp_ready_low_pct = 0;

    cfg.rsp_drain_timeout = 500us;
  endfunction

  virtual task run_testcase();
    seq_funcov_b2b_mix_wrap_aligned seq;

    seq = seq_funcov_b2b_mix_wrap_aligned::type_id::create("seq");

    `uvm_info("TEST_B2B_MIX_ALIGN",
              {"Run 15 adjacent mixed-request pairs with all WRAP addresses ",
               "8B aligned; includes WRAP_WR->INCR_RD B2B closure"},
              UVM_LOW)

    start_rknp_sequence(seq);
  endtask

endclass : test_funcov_b2b_mix_wrap_aligned

`endif // TEST_FUNCOV_B2B_MIX_WRAP_ALIGNED_SV
