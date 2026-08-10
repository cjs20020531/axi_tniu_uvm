`ifndef TEST_WATCHDOG_1100_SV
`define TEST_WATCHDOG_1100_SV

class test_watchdog_1100 extends axi_tniu_base_test;
  `uvm_component_utils(test_watchdog_1100)

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
    seq_norm_rd  rd_seq;
    seq_norm_wr  wr_seq;
    seq_norm_rdw rdw_seq;
    seq_norm_wrw wrw_seq;

    rd_seq = seq_norm_rd::type_id::create("rd_seq");
    rd_seq.num_txn = 1;
    start_rknp_sequence(rd_seq);

    // wr_seq = seq_norm_wr::type_id::create("wr_seq");
    // wr_seq.num_txn = 1;
    // start_rknp_sequence(wr_seq);

    // rdw_seq = seq_norm_rdw::type_id::create("rdw_seq");
    // rdw_seq.num_txn = 1;
    // start_rknp_sequence(rdw_seq);

    // wrw_seq = seq_norm_wrw::type_id::create("wrw_seq");
    // wrw_seq.num_txn = 1;
    // start_rknp_sequence(wrw_seq);
  endtask

endclass : test_watchdog_1100

`endif // TEST_WATCHDOG_1100_SV
