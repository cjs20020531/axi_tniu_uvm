`ifndef TEST_ERR_MIX_SV
`define TEST_ERR_MIX_SV
class test_err_mix extends axi_tniu_base_test;
  `uvm_component_utils(test_err_mix)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_testcase();
    seq_err_mix seq = seq_err_mix::type_id::create("seq");
    // Sequence selection and configuration belong to this test.
    seq.use_fixed_orderkey = 1'b0;  // 1：固定，0：随机
    // seq.fixed_orderkey     = 8'h55;
    seq.num_txn = 20;
    start_rknp_sequence(seq);
  endtask
endclass : test_err_mix
`endif
