`ifndef TEST_NORM_RD_SV
`define TEST_NORM_RD_SV
class test_norm_rd extends axi_tniu_base_test;
  `uvm_component_utils(test_norm_rd)
  function new(string name, uvm_component parent); 
    super.new(name, parent); 
  endfunction

  function void configure_cfg(); 
    cfg.num_txn = 4; 
  endfunction

  task run_testcase();
    seq_norm_rd seq = seq_norm_rd::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask

endclass : test_norm_rd
`endif
