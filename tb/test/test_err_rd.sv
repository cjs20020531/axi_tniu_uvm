`ifndef TEST_ERR_RD_SV
`define TEST_ERR_RD_SV
class test_err_rd extends axi_tniu_base_test;
  `uvm_component_utils(test_err_rd)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_testcase();
    seq_err_rd seq = seq_err_rd::type_id::create("seq");
    // Sequence selection and configuration belong to this test.
    seq.num_txn = 4;
    start_rknp_sequence(seq);
  endtask
endclass : test_err_rd
`endif
