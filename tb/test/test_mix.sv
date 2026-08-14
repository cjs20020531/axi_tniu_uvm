`ifndef TEST_MIX_SV
`define TEST_MIX_SV

class test_mix extends axi_tniu_base_test;
  `uvm_component_utils(test_mix)

  function new(string name = "test_mix", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    // AXI errors are selected independently for each AXI transaction that
    // reaches the slave driver.  The 20% is the combined SLVERR+DECERR rate.
    cfg.axi_error_rsp_en          = 1'b1;
    cfg.axi_error_resp_random_en = 1'b1;
    cfg.axi_error_resp           = AXI_SLVERR;
    cfg.axi_slverr_pct           = 20;
  endfunction

  virtual task run_testcase();
    seq_mix seq;

    seq = seq_mix::type_id::create("seq_mix_inst");
    seq.num_txn = 400;
    start_rknp_sequence(seq);
  endtask

endclass : test_mix

`endif // TEST_MIX_SV
