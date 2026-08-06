`ifndef TEST_BUFF_WR_SV
`define TEST_BUFF_WR_SV
class test_buff_wr extends axi_tniu_base_test;
  `uvm_component_utils(test_buff_wr)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_testcase();
    seq_buff_wr seq = seq_buff_wr::type_id::create("seq");
    // Sequence selection and configuration belong to this test.
    seq.num_txn = 4;
    start_rknp_sequence(seq);
  endtask
endclass : test_buff_wr
`endif
