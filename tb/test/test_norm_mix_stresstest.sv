`ifndef TEST_NORM_MIX_STRESSTEST_SV
`define TEST_NORM_MIX_STRESSTEST_SV
class test_norm_mix_stresstest extends axi_tniu_base_test;
  `uvm_component_utils(test_norm_mix_stresstest)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_testcase();
    seq_norm_mix seq = seq_norm_mix::type_id::create("seq");
    // Sequence selection and configuration belong to this test.
    cfg.axi_min_resp_delay = 100;
    cfg.axi_max_resp_delay = 200;
    cfg.axi_min_beat_gap = 50;
    cfg.axi_max_beat_gap =100;
    seq.use_fixed_orderkey = 1'b0;  // 1：固定，0：随机
    // seq.fixed_orderkey     = 8'h55;
    seq.num_txn = 40;
    start_rknp_sequence(seq);
  endtask
endclass : test_norm_mix_stresstest
`endif
