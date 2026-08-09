`ifndef TEST_BUFF_MIX_FIXORDKEY_SV
`define TEST_BUFF_MIX_FIXORDKEY_SV
class test_buff_mix_fixordkey extends axi_tniu_base_test;
  `uvm_component_utils(test_buff_mix_fixordkey)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_testcase();
    seq_buff_mix seq = seq_buff_mix::type_id::create("seq");
    // Sequence selection and configuration belong to this test.
    seq.use_fixed_orderkey = 1'b1;  // 1：固定，0：随机
    seq.fixed_orderkey     = 8'h55;  //set orderkey
    seq.num_txn = 40;
    start_rknp_sequence(seq);
  endtask
endclass : test_buff_mix_fixordkey
`endif
