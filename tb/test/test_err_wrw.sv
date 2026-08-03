`ifndef TEST_ERR_WRW_SV
`define TEST_ERR_WRW_SV
class test_err_wrw extends axi_tniu_base_test;
  `uvm_component_utils(test_err_wrw)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void configure_cfg(); cfg.num_txn = 1; endfunction
  task run_testcase();
    seq_err_wrw seq = seq_err_wrw::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_err_wrw
`endif
