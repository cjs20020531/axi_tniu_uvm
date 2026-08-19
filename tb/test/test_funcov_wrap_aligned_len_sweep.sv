`ifndef TEST_FUNCOV_WRAP_ALIGNED_LEN_SWEEP_SV
`define TEST_FUNCOV_WRAP_ALIGNED_LEN_SWEEP_SV

// =============================================================================
// File        : test_funcov_wrap_aligned_len_sweep.sv
// Description : Runs 8-byte-aligned RDW/WRW requests for
//               LEN={7,15,31,63,127}.
// =============================================================================

class test_funcov_wrap_aligned_len_sweep extends axi_tniu_base_test;
  `uvm_component_utils(test_funcov_wrap_aligned_len_sweep)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    super.configure_cfg();

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

    cfg.axi_error_rsp_en         = 1'b0;
    cfg.axi_error_resp_random_en = 1'b0;

    cfg.req_min_gap             = 0;
    cfg.req_max_gap             = 0;
    cfg.rsp_ready_low_pct       = 0;

    cfg.rsp_drain_timeout       = 500us;
  endfunction

  virtual task run_testcase();
    seq_funcov_wrap_aligned_len_sweep seq;

    seq = seq_funcov_wrap_aligned_len_sweep::type_id::create("seq");

    `uvm_info("TEST_WRAP_ALIGN_LEN",
              "Run aligned RDW/WRW LEN={7,15,31,63,127}",
              UVM_LOW)

    start_rknp_sequence(seq);
  endtask

endclass : test_funcov_wrap_aligned_len_sweep

`endif // TEST_FUNCOV_WRAP_ALIGNED_LEN_SWEEP_SV
