`ifndef TEST_MIX_SV
`define TEST_MIX_SV
class test_mix extends axi_tniu_base_test;
  `uvm_component_utils(test_mix)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_testcase();
    seq_mix seq = seq_mix::type_id::create("seq");
    // Sequence selection and configuration belong to this test.
    seq.num_txn = 1;
    start_rknp_sequence(seq);
  endtask
endclass : test_mix
`endif
