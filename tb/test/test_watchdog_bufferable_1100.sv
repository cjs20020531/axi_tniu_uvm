`ifndef TEST_WATCHDOG_BUFFERABLE_1100_SV
`define TEST_WATCHDOG_BUFFERABLE_1100_SV

class test_watchdog_bufferable_1100 extends axi_tniu_base_test;
  `uvm_component_utils(test_watchdog_bufferable_1100)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    cfg.axi_ooo_en          = 1'b0;
    cfg.axi_interleave_en   = 1'b0;
    cfg.axi_ready_bp_en     = 1'b0;
    cfg.rsp_ready_bp_en     = 1'b0;
    cfg.axi_slverr_pct      = 0;
    cfg.axi_min_resp_delay  = 1100;
    cfg.axi_max_resp_delay  = 1100;
    cfg.rsp_drain_timeout   = 200us;
  endfunction

  virtual task run_testcase();
    seq_buff_wr seq;

    seq = seq_buff_wr::type_id::create("seq");
    seq.num_txn = 1;
    start_rknp_sequence(seq);
  endtask

endclass : test_watchdog_bufferable_1100

`endif // TEST_WATCHDOG_BUFFERABLE_1100_SV
