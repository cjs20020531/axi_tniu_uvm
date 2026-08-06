`ifndef TEST_ADDROL_RAW_SV
`define TEST_ADDROL_RAW_SV
class test_addrol_raw extends axi_tniu_base_test;
  `uvm_component_utils(test_addrol_raw)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_testcase();
    seq_addrol_raw seq = seq_addrol_raw::type_id::create("seq");
    // Sequence selection and configuration belong to this test.
    seq.num_txn = 2;
    start_rknp_sequence(seq);
  endtask
endclass : test_addrol_raw
`endif
