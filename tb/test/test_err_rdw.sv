`ifndef TEST_ERR_RDW_SV
`define TEST_ERR_RDW_SV
class test_err_rdw extends axi_tniu_base_test;
  `uvm_component_utils(test_err_rdw)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_testcase();
    seq_err_rdw seq = seq_err_rdw::type_id::create("seq");
    // Sequence selection and configuration belong to this test.
    seq.num_txn                 = 1;
    seq.wrap_len_mode           = WRAP_LEN_FULL;
    seq.force_flit_aligned_addr = 1'b0;
    start_rknp_sequence(seq);
  endtask
endclass : test_err_rdw
`endif
