`ifndef TEST_ERR_WR_SV
`define TEST_ERR_WR_SV
class test_err_wr extends axi_tniu_base_test;
  `uvm_component_utils(test_err_wr)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void configure_cfg(); cfg.num_txn = 4; endfunction
  task run_testcase();
    seq_err_wr seq = seq_err_wr::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_err_wr
`endif
