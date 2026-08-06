`ifndef TEST_NORM_WRW_SV
`define TEST_NORM_WRW_SV
class test_norm_wrw extends axi_tniu_base_test;
  `uvm_component_utils(test_norm_wrw)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_testcase();
    seq_norm_wrw seq = seq_norm_wrw::type_id::create("seq");
    // Sequence selection and configuration belong to this test.
    seq.num_txn                 = 4;
    seq.wrap_len_mode           = WRAP_LEN_FULL;
    seq.force_flit_aligned_addr = WRAP_ADDR_ALIGN;
    start_rknp_sequence(seq);
  endtask
endclass : test_norm_wrw
`endif
