`ifndef TEST_FUNCOV_B2B_MIX_WRAP_UNALIGNED_SV
`define TEST_FUNCOV_B2B_MIX_WRAP_UNALIGNED_SV

// =============================================================================
// File        : test_funcov_b2b_mix_wrap_unaligned.sv
// Description : Runs the non-8-byte-aligned-WRAP adjacent mixed-request matrix.
// =============================================================================

class test_funcov_b2b_mix_wrap_unaligned extends axi_tniu_base_test;
  `uvm_component_utils(test_funcov_b2b_mix_wrap_unaligned)

  function new(string name = "test_funcov_b2b_mix_wrap_unaligned",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
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

    cfg.req_min_gap       = 0;
    cfg.req_max_gap       = 0;
    cfg.rsp_ready_low_pct = 0;

    cfg.rsp_drain_timeout = 500us;
  endfunction

  virtual task run_testcase();
    seq_funcov_b2b_mix_wrap_unaligned seq;

    seq = seq_funcov_b2b_mix_wrap_unaligned::type_id::create("seq");

    `uvm_info("TEST_B2B_MIX_UALIGN",
              {"Run 14 adjacent mixed-request pairs; ",
               "every WRAP operand uses a non-8B-aligned 2B-aligned address"},
              UVM_LOW)

    start_rknp_sequence(seq);
  endtask

endclass : test_funcov_b2b_mix_wrap_unaligned

`endif // TEST_FUNCOV_B2B_MIX_WRAP_UNALIGNED_SV
