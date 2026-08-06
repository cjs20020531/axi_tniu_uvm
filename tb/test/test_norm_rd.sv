`ifndef TEST_NORM_RD_SV
`define TEST_NORM_RD_SV
class test_norm_rd extends axi_tniu_base_test;
  `uvm_component_utils(test_norm_rd)
  function new(string name, uvm_component parent); 
    super.new(name, parent); 
  endfunction

  task run_testcase();
    seq_norm_rd seq = seq_norm_rd::type_id::create("seq");
    // Sequence selection and configuration belong to this test.
    seq.num_txn = 4;
    start_rknp_sequence(seq);
  endtask

endclass : test_norm_rd
`endif
