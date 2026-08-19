`ifndef TEST_FUNCOV_ORDER_MULTI_READ_SV
`define TEST_FUNCOV_ORDER_MULTI_READ_SV

class test_funcov_order_multi_read extends axi_tniu_base_test;
  `uvm_component_utils(test_funcov_order_multi_read)

  localparam int unsigned BLOCK_SEPARATOR_CYCLES = 10;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    super.configure_cfg();

    cfg.axi_ready_bp_en   = 1'b0;
    cfg.rsp_ready_bp_en   = 1'b0;
    cfg.rsp_ready_low_pct = 0;

    cfg.axi_error_rsp_en         = 1'b0;
    cfg.axi_error_resp_random_en = 1'b0;

    cfg.axi_ooo_en              = 1'b1;
    cfg.axi_interleave_en       = 1'b1;
    cfg.axi_force_interleave_en = 1'b0;

    cfg.axi_min_resp_delay = 24;
    cfg.axi_max_resp_delay = 48;
    cfg.axi_min_beat_gap   = 2;
    cfg.axi_max_beat_gap   = 3;

    cfg.req_min_gap = 0;
    cfg.req_max_gap = 0;

    cfg.rsp_drain_timeout = 2ms;
  endfunction

  protected task wait_separator();
    repeat (BLOCK_SEPARATOR_CYCLES)
      @(posedge env.rknp_agt.drv.vif.aclk);
  endtask

  protected task run_block(
      string             block_name,
      funcov_read_mode_e mode,
      int unsigned       req_gap,
      bit                force_interleave);

    seq_funcov_order_multi_read seq;

    cfg.req_min_gap = req_gap;
    cfg.req_max_gap = req_gap;
    cfg.axi_ooo_en              = 1'b1;
    cfg.axi_interleave_en       = 1'b1;
    cfg.axi_force_interleave_en = force_interleave;

    `uvm_info("TEST_ORDER_MULTI_READ",
              $sformatf("%s: mode=%0d req_gap=%0d force_interleave=%0b",
                        block_name, mode, req_gap, force_interleave),
              UVM_LOW)

    seq = seq_funcov_order_multi_read::type_id::create(
            $sformatf("seq_%s", block_name));
    seq.mode = mode;
    start_rknp_sequence(seq);
  endtask

  virtual task run_testcase();
    // R1: B2B, beat=1, INCR read, OOO + interleave enable.
    run_block("R1_incr_b2b_beat1",
              FUNCOV_READ_INCR_BEAT1, 0, 1'b0);

    wait_separator();

    // R2: gap N=4, multi-beat INCR read, OOO + interleave.
    run_block("R2_incr_gap4_ilv",
              FUNCOV_READ_INCR_MULTI, 4, 1'b0);

    wait_separator();

    // R3: duplicated normal INCR-gap item in the plan; use a second N value.
    run_block("R3_incr_gap8_ilv",
              FUNCOV_READ_INCR_MULTI, 8, 1'b0);

    wait_separator();

    // R4: gap N=4, INCR read, OOO + force interleave requested.
    run_block("R4_incr_gap4_force_ilv",
              FUNCOV_READ_INCR_MULTI, 4, 1'b1);

    wait_separator();

    // R5: B2B WRAP read, OOO + interleave.
    run_block("R5_wrap_b2b_ilv",
              FUNCOV_READ_WRAP_MULTI, 0, 1'b0);

    wait_separator();

    // R6: gap N=4 WRAP read, OOO + interleave.
    run_block("R6_wrap_gap4_ilv",
              FUNCOV_READ_WRAP_MULTI, 4, 1'b0);

    wait_separator();

    // R7: gap N=4 WRAP read, OOO + force interleave requested.
    run_block("R7_wrap_gap4_force_ilv",
              FUNCOV_READ_WRAP_MULTI, 4, 1'b1);
  endtask

endclass : test_funcov_order_multi_read

`endif
