`ifndef TEST_BUFF_ERR_MIX_SV
`define TEST_BUFF_ERR_MIX_SV
class test_buff_err_mix extends axi_tniu_base_test;
  `uvm_component_utils(test_buff_err_mix)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_testcase();
    seq_buff_err_mix seq = seq_buff_err_mix::type_id::create("seq");
    // This sequence has no configurable parameters; this test selects it.
    start_rknp_sequence(seq);
  endtask
endclass : test_buff_err_mix
`endif
