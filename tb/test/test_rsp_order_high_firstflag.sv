`ifndef TEST_RSP_ORDER_HIGH_FIRSTFLAG_SV
`define TEST_RSP_ORDER_HIGH_FIRSTFLAG_SV

// =============================================================================
// Directed toggle-coverage test for rsp_order slot7 first-request logic.
//
// The sequence uses a 256-byte ST_ERR read to hold rsp_order in SPEC_RSP while
// eight distinct first-of-type ERR reads fill special-buffer slots 0..7.
// =============================================================================
class test_rsp_order_high_firstflag extends axi_tniu_base_test;
  `uvm_component_utils(test_rsp_order_high_firstflag)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    super.configure_cfg();

    cfg.req_min_gap             = 0;
    cfg.req_max_gap             = 0;
    cfg.rsp_ready_bp_en         = 1'b0;

    // All directed requests are ST_ERR and therefore do not launch AXI traffic.
    // Keep AXI policy deterministic anyway so this test has no unrelated noise.
    cfg.axi_ready_bp_en         = 1'b0;
    cfg.axi_ooo_en              = 1'b0;
    cfg.axi_interleave_en       = 1'b0;
    cfg.axi_error_rsp_en        = 1'b0;
    cfg.axi_min_addr_delay      = 0;
    cfg.axi_max_addr_delay      = 0;
    cfg.axi_min_resp_delay      = 0;
    cfg.axi_max_resp_delay      = 0;
    cfg.axi_min_beat_gap        = 0;
    cfg.axi_max_beat_gap        = 0;

    cfg.rsp_drain_timeout       = 200us;
    cfg.num_txn                 = 9;
  endfunction

  task run_testcase();
    seq_rsp_order_high_firstflag seq;

    seq = seq_rsp_order_high_firstflag::type_id::create("seq");
    start_rknp_sequence(seq);
  endtask

endclass : test_rsp_order_high_firstflag

`endif // TEST_RSP_ORDER_HIGH_FIRSTFLAG_SV
