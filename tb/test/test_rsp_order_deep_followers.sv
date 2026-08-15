`ifndef TEST_RSP_ORDER_DEEP_FOLLOWERS_SV
`define TEST_RSP_ORDER_DEEP_FOLLOWERS_SV

// =============================================================================
// Directed toggle-coverage test for rsp_order slot7 follower logic.
//
// No AXI delay is required: every request in this test is ST_ERR, so rsp_order
// generates the RKNP error response locally.  The first request is intentionally
// 256 bytes long and acts as a 32-flit SPECIAL-response blocker.
// =============================================================================
class test_rsp_order_deep_followers extends axi_tniu_base_test;
  `uvm_component_utils(test_rsp_order_deep_followers)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    super.configure_cfg();

    // Deterministic request/response timing.
    cfg.req_min_gap             = 0;
    cfg.req_max_gap             = 0;
    cfg.rsp_ready_bp_en         = 1'b0;

    // AXI is not used by ST_ERR requests, but keep the slave side deterministic
    // in case the environment performs any incidental activity.
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
    seq_rsp_order_deep_followers seq;

    seq = seq_rsp_order_deep_followers::type_id::create("seq");
    start_rknp_sequence(seq);
  endtask

endclass : test_rsp_order_deep_followers

`endif // TEST_RSP_ORDER_DEEP_FOLLOWERS_SV
