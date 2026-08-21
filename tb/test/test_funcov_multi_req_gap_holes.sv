`ifndef TEST_FUNCOV_MULTI_REQ_GAP_HOLES_SV
`define TEST_FUNCOV_MULTI_REQ_GAP_HOLES_SV

// =============================================================================
// File        : test_funcov_multi_req_gap_holes.sv
// Description : Runs deterministic gap_gt10 and gap_1_10 adjacent-request
//               matrices for cg_multi_req.x_pair_gap/x_pair_beat closure.
// =============================================================================

class test_funcov_multi_req_gap_holes extends axi_tniu_base_test;
  `uvm_component_utils(test_funcov_multi_req_gap_holes)

  localparam int unsigned GAP_1_10_VALUE = 4;
  localparam int unsigned GAP_GT10_VALUE = 12;
  localparam int unsigned BLOCK_SEPARATOR_CYCLES = 16;

  function new(string name = "test_funcov_multi_req_gap_holes",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    super.configure_cfg();

    // Remove unrelated response-side randomness so the request-pair matrix and
    // the selected request gap are the only intended variables.
    cfg.axi_ooo_en              = 1'b0;
    cfg.axi_interleave_en       = 1'b0;
    cfg.axi_force_interleave_en = 1'b0;

    cfg.axi_ready_bp_en         = 1'b0;
    cfg.rsp_ready_bp_en         = 1'b0;
    cfg.rsp_ready_low_pct       = 0;

    cfg.axi_min_addr_delay      = 0;
    cfg.axi_max_addr_delay      = 0;
    cfg.axi_min_resp_delay      = 0;
    cfg.axi_max_resp_delay      = 0;
    cfg.axi_min_beat_gap        = 0;
    cfg.axi_max_beat_gap        = 0;

    cfg.axi_rsp_user_random_en  = 1'b0;
    cfg.axi_rsp_user_fixed      = '0;

    cfg.axi_error_rsp_en         = 1'b0;
    cfg.axi_error_resp_random_en = 1'b0;

    // run_block() overwrites these before each sequence starts.
    cfg.req_min_gap = GAP_GT10_VALUE;
    cfg.req_max_gap = GAP_GT10_VALUE;

    cfg.rsp_drain_timeout = 500us;
  endfunction

  protected task wait_separator();
    repeat (BLOCK_SEPARATOR_CYCLES)
      @(posedge env.rknp_agt.drv.vif.aclk);
  endtask

  protected task run_block(
      string                       block_name,
      funcov_multi_req_gap_mode_e  mode,
      int unsigned                 req_gap);

    seq_funcov_multi_req_gap_holes seq;

    cfg.req_min_gap = req_gap;
    cfg.req_max_gap = req_gap;

    `uvm_info("TEST_MULTI_REQ_GAP_HOLES",
              $sformatf("%s: mode=%0d fixed req_gap=%0d",
                        block_name, mode, req_gap),
              UVM_LOW)

    seq = seq_funcov_multi_req_gap_holes::type_id::create(
            $sformatf("seq_%s", block_name));
    seq.mode = mode;
    start_rknp_sequence(seq);
  endtask

  virtual task run_testcase();
    // Run the long-gap block first.  All intended pairs have a fixed gap of 12,
    // which guarantees cg_multi_req.cp_gap.gap_gt10.
    run_block("gap_gt10",
              FUNCOV_MULTI_REQ_GAP_GT10,
              GAP_GT10_VALUE);

    // Let the driver enter its no-item idle path before changing the live cfg.
    // The first request after the separator is not itself a target pair; every
    // target pair gets the new fixed gap between its first and second request.
    wait_separator();

    run_block("gap_1_10",
              FUNCOV_MULTI_REQ_GAP_1_10,
              GAP_1_10_VALUE);
  endtask

endclass : test_funcov_multi_req_gap_holes

`endif // TEST_FUNCOV_MULTI_REQ_GAP_HOLES_SV
