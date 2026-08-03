`ifndef TEST_MIX_SV
`define TEST_MIX_SV
class test_mix extends axi_tniu_base_test;
  `uvm_component_utils(test_mix)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void configure_cfg(); cfg.num_txn = 1; endfunction
  task run_testcase();
    seq_mix seq = seq_mix::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_mix
`endif
