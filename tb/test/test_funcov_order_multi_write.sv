`ifndef TEST_FUNCOV_ORDER_MULTI_WRITE_SV
`define TEST_FUNCOV_ORDER_MULTI_WRITE_SV

class test_funcov_order_multi_write extends axi_tniu_base_test;
  `uvm_component_utils(test_funcov_order_multi_write)

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
    cfg.axi_interleave_en       = 1'b0;
    cfg.axi_force_interleave_en = 1'b0;

    cfg.axi_min_resp_delay = 0;
    cfg.axi_max_resp_delay = 48;
    cfg.axi_min_beat_gap   = 0;
    cfg.axi_max_beat_gap   = 0;

    cfg.req_min_gap = 0;
    cfg.req_max_gap = 0;

    cfg.rsp_drain_timeout = 2ms;
  endfunction

  protected task wait_separator();
    repeat (BLOCK_SEPARATOR_CYCLES)
      @(posedge env.rknp_agt.drv.vif.aclk);
  endtask

  protected task run_block(
      string              block_name,
      funcov_write_mode_e mode,
      int unsigned        req_gap);

    seq_funcov_order_multi_write seq;

    cfg.req_min_gap = req_gap;
    cfg.req_max_gap = req_gap;
    cfg.axi_ooo_en              = 1'b1;
    cfg.axi_interleave_en       = 1'b0;
    cfg.axi_force_interleave_en = 1'b0;

    `uvm_info("TEST_ORDER_MULTI_WRITE",
              $sformatf("%s: mode=%0d req_gap=%0d",
                        block_name, mode, req_gap),
              UVM_LOW)

    seq = seq_funcov_order_multi_write::type_id::create(
            $sformatf("seq_%s", block_name));
    seq.mode = mode;
    start_rknp_sequence(seq);
  endtask

  virtual task run_testcase();
    // W1: B2B INCR writes, OOO B responses.
    run_block("W1_incr_b2b_ooo",
              FUNCOV_WRITE_INCR, 0);

    wait_separator();

    // W2: gap N=4 INCR writes, OOO B responses.
    run_block("W2_incr_gap4_ooo",
              FUNCOV_WRITE_INCR, 4);

    wait_separator();

    // W3: B2B WRAP writes, OOO B responses.
    run_block("W3_wrap_b2b_ooo",
              FUNCOV_WRITE_WRAP, 0);

    wait_separator();

    // W4: gap N=4 WRAP writes, OOO B responses.
    run_block("W4_wrap_gap4_ooo",
              FUNCOV_WRITE_WRAP, 4);
  endtask

endclass : test_funcov_order_multi_write

`endif
