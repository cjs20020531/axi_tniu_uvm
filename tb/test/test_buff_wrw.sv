`ifndef TEST_BUFF_WRW_SV
`define TEST_BUFF_WRW_SV
class test_buff_wrw extends axi_tniu_base_test;
  `uvm_component_utils(test_buff_wrw)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_testcase();
    seq_buff_wrw seq = seq_buff_wrw::type_id::create("seq");
    // Sequence selection and configuration belong to this test.
    seq.num_txn                 = 4;
    seq.wrap_len_mode           = WRAP_LEN_FULL;
    seq.force_flit_aligned_addr = 1'b0;
    start_rknp_sequence(seq);
  endtask
endclass : test_buff_wrw
`endif
