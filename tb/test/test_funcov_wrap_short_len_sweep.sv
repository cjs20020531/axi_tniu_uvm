`ifndef TEST_FUNCOV_WRAP_SHORT_LEN_SWEEP_SV
`define TEST_FUNCOV_WRAP_SHORT_LEN_SWEEP_SV

// =============================================================================
// File        : test_funcov_wrap_short_len_sweep.sv
// Description : Runs RDW/WRW requests for LEN={1,3}, with no extra address
//               requirement beyond native transaction constraints.
// =============================================================================

class test_funcov_wrap_short_len_sweep extends axi_tniu_base_test;
  `uvm_component_utils(test_funcov_wrap_short_len_sweep)

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

    cfg.rsp_drain_timeout       = 200us;
  endfunction

  virtual task run_testcase();
    seq_funcov_wrap_short_len_sweep seq;

    seq = seq_funcov_wrap_short_len_sweep::type_id::create("seq");

    `uvm_info("TEST_WRAP_SHORT_LEN",
              "Run RDW/WRW short-WRAP LEN={1,3}",
              UVM_LOW)

    start_rknp_sequence(seq);
  endtask

endclass : test_funcov_wrap_short_len_sweep

`endif // TEST_FUNCOV_WRAP_SHORT_LEN_SWEEP_SV
