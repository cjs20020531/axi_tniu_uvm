`ifndef TEST_NORM_WRW_SV
`define TEST_NORM_WRW_SV
class test_norm_wrw extends axi_tniu_base_test;
  `uvm_component_utils(test_norm_wrw)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void configure_cfg(); cfg.num_txn = 1; endfunction
  task run_testcase();
    seq_norm_wrw seq = seq_norm_wrw::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_norm_wrw
`endif
