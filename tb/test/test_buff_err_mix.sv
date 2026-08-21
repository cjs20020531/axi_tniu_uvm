`ifndef TEST_BUFF_ERR_MIX_SV
`define TEST_BUFF_ERR_MIX_SV
class test_buff_err_mix extends axi_tniu_base_test;
  `uvm_component_utils(test_buff_err_mix)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_testcase();
    seq_buff_err_mix seq = seq_buff_err_mix::type_id::create("seq");
    `uvm_info(
      "TEST_BUFF_ERR_MIX",
      "Run directed ERROR+bufferable WR/WRW pair for both_incr_wr and both_wrap_wr",
      UVM_LOW
    )

    // The sequence deterministically sends one INCR write and one WRAP write;
    // both requests use ST_ERR + EC_ADDR_DEC + AxCACHE[0]=1.
    start_rknp_sequence(seq);
  endtask
endclass : test_buff_err_mix
`endif
