`ifndef TEST_BUFF_MIX_SV
`define TEST_BUFF_MIX_SV
class test_buff_mix extends axi_tniu_base_test;
  `uvm_component_utils(test_buff_mix)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void configure_cfg(); cfg.num_txn = 10; endfunction
  task run_testcase();
    seq_buff_mix seq = seq_buff_mix::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_buff_mix
`endif
