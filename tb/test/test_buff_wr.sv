`ifndef TEST_BUFF_WR_SV
`define TEST_BUFF_WR_SV
class test_buff_wr extends axi_tniu_base_test;
  `uvm_component_utils(test_buff_wr)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void configure_cfg(); cfg.num_txn = 4; endfunction
  task run_testcase();
    seq_buff_wr seq = seq_buff_wr::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_buff_wr
`endif
