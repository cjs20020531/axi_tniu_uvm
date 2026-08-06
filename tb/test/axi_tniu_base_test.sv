// =============================================================================
// File        : axi_tniu_base_test.sv
// Description : Common environment setup, sequence launch and response drain.
// =============================================================================
`ifndef AXI_TNIU_BASE_TEST_SV
`define AXI_TNIU_BASE_TEST_SV

class axi_tniu_base_test extends uvm_test;
  `uvm_component_utils(axi_tniu_base_test)

  axi_tniu_env env;
  axi_tniu_cfg cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    int unsigned plusarg_num_txn;

    super.build_phase(phase);
    cfg = axi_tniu_cfg::type_id::create("cfg");
    cfg.num_txn = 1;
    configure_cfg();

    if ($value$plusargs("num_txn=%d", plusarg_num_txn))
      cfg.num_txn = plusarg_num_txn;

    cfg.validate();
    uvm_config_db#(axi_tniu_cfg)::set(this, "*", "cfg", cfg);
    env = axi_tniu_env::type_id::create("env", this);
  endfunction

  virtual function void configure_cfg();
  endfunction

  virtual task run_testcase();
    `uvm_fatal("BASE_TEST",
               "axi_tniu_base_test has no testcase; select a derived test")
  endtask

  // The derived test owns sequence selection and default sequence
  // configuration.  This helper only applies optional command-line overrides
  // and starts the already-configured sequence.
  protected task start_rknp_sequence(rknp_base_seq seq);
    int unsigned plusarg_num_txn;
    int wrap_narrow;
    int wrap_flit_align;

    if (seq == null)
      `uvm_fatal("TEST_NULL_SEQ", "Attempted to start a null RKNP sequence")
    if ((env == null) || (env.rknp_agt == null) ||
        (env.rknp_agt.sqr == null))
      `uvm_fatal("TEST_NO_SQR", "RKNP sequencer is not available")

    if ($value$plusargs("num_txn=%d", plusarg_num_txn))
      seq.num_txn = plusarg_num_txn;
    if ($value$plusargs("wrap_narrow=%d", wrap_narrow))
      seq.wrap_len_mode = wrap_narrow ? WRAP_LEN_NARROW : WRAP_LEN_FULL;
    if ($value$plusargs("wrap_flit_align=%d", wrap_flit_align))
      seq.force_flit_aligned_addr = (wrap_flit_align != 0);

    seq.start(env.rknp_agt.sqr);
  endtask

  protected task drain_responses();
    int unsigned expected_final_rsp;
    bit          drain_done;

    expected_final_rsp = env.tag_mgr.get_allocated_count();
    drain_done         = 1'b0;

    fork : response_drain
      begin
        wait (env.sb.n_rsp_final >= expected_final_rsp);
        drain_done = 1'b1;
      end
      begin
        #(cfg.rsp_drain_timeout);
      end
    join_any
    disable response_drain;

    if (!drain_done)
      `uvm_error("RSP_DRAIN_TIMEOUT", $sformatf(
        {"Timed out waiting for final RKNP responses: requests=%0d ",
         "response_packets=%0d final_rsp(LW=1)=%0d timeout=%0t"},
        expected_final_rsp, env.sb.n_rsp, env.sb.n_rsp_final,
        cfg.rsp_drain_timeout))
    else
      `uvm_info("RSP_DRAIN", $sformatf(
        {"All final RKNP responses received: requests=%0d ",
         "response_packets=%0d final_rsp=%0d"},
        expected_final_rsp, env.sb.n_rsp, env.sb.n_rsp_final), UVM_LOW)
  endtask

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    run_testcase();
    drain_responses();
    phase.drop_objection(this);
  endtask

  function void report_phase(uvm_phase phase);
    uvm_report_server svr;

    super.report_phase(phase);
    svr = uvm_report_server::get_server();
    if ((svr.get_severity_count(UVM_ERROR) +
         svr.get_severity_count(UVM_FATAL)) == 0)
      `uvm_info("RESULT", "*** TEST PASSED ***", UVM_NONE)
    else
      `uvm_info("RESULT", "*** TEST FAILED ***", UVM_NONE)
  endfunction
endclass : axi_tniu_base_test

`endif // AXI_TNIU_BASE_TEST_SV
