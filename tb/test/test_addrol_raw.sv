`ifndef TEST_ADDROL_RAW_SV
`define TEST_ADDROL_RAW_SV
class test_addrol_raw extends axi_tniu_base_test;
  `uvm_component_utils(test_addrol_raw)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void configure_cfg(); cfg.num_txn = 2; endfunction
  task run_testcase();
    seq_addrol_raw seq = seq_addrol_raw::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_addrol_raw
`endif
