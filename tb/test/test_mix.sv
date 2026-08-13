`ifndef TEST_MIX_SV
`define TEST_MIX_SV
class test_mix extends axi_tniu_base_test;
  `uvm_component_utils(test_mix)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  virtual function void configure_cfg();
    // Add an independent AXI response-error dimension on top of seq_mix's
    // original request mix. Each transaction that actually reaches AXI has a
    // 20% error probability; SLVERR and DECERR are selected 50%/50%.
    cfg.axi_error_rsp_en         = 1'b1;
    cfg.axi_error_resp_random_en = 1'b1;
    cfg.axi_slverr_pct           = 20;
  endfunction

  task run_testcase();
    seq_mix seq = seq_mix::type_id::create("seq");
    // Preserve the original sequence configuration and transaction count.
    seq.num_txn = 400;
    start_rknp_sequence(seq);
  endtask
endclass : test_mix
`endif
