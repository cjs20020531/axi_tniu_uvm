// =============================================================================
// File        : axi_tniu_tests.sv
// Description : Test library. axi_tniu_base_test builds the environment, creates
//               and publishes the configuration, and provides a common run
//               skeleton. Each derived test selects a virtual sequence and a
//               transaction count. Tests are chosen at run time via
//               +UVM_TESTNAME=<name>.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_TNIU_TESTS_SV
`define AXI_TNIU_TESTS_SV

// -----------------------------------------------------------------------------
// Base test
// -----------------------------------------------------------------------------
class axi_tniu_base_test extends uvm_test;
  `uvm_component_utils(axi_tniu_base_test)

  axi_tniu_env  env;
  axi_tniu_cfg  cfg;
  int unsigned  num_txn = 40;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = axi_tniu_cfg::type_id::create("cfg");
    configure_cfg();                      // hook for derived tests
    uvm_config_db#(axi_tniu_cfg)::set(this, "*", "cfg", cfg);
    env = axi_tniu_env::type_id::create("env", this);
    // allow +num_txn override
    void'($value$plusargs("num_txn=%d", num_txn));
  endfunction

  // Derived tests may tweak the config before it is published.
  virtual function void configure_cfg();
    // This verification configuration: all target modes ON (see cfg defaults).
  endfunction

  // Common run wrapper: raise objection, run the selected vseq, drop.
  virtual task run_vseq(vseq_base vseq);
    int unsigned expected_final_rsp;
    bit          drain_done;

    phase_ph.raise_objection(this);
    vseq.num = num_txn;
    vseq.start(env.vseqr);

    // The sequence has returned only after the driver accepted every request,
    // so the tag manager now holds the exact request count. Do not compare the
    // number of response packets with this value: one request may legally
    // produce several response packets. Instead wait for one LW=1 packet per
    // request, with an independent timeout so a DUT response loss cannot hang
    // the simulation forever.
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

    if (!drain_done) begin
      `uvm_error("RSP_DRAIN_TIMEOUT", $sformatf(
        {"Timed out waiting for final RKNP responses: ",
         "requests=%0d response_packets=%0d final_rsp(LW=1)=%0d timeout=%0t"},
        expected_final_rsp, env.sb.n_rsp, env.sb.n_rsp_final,
        cfg.rsp_drain_timeout))
    end
    else begin
      `uvm_info("RSP_DRAIN", $sformatf(
        "All final RKNP responses received: requests=%0d response_packets=%0d final_rsp=%0d",
        expected_final_rsp, env.sb.n_rsp, env.sb.n_rsp_final), UVM_LOW)
    end

    phase_ph.drop_objection(this);
  endtask

  uvm_phase phase_ph;
  task run_phase(uvm_phase phase);
    // base test runs a light random smoke by default
    vseq_random v = vseq_random::type_id::create("v");
    phase_ph = phase;
    run_vseq(v);
  endtask

  function void report_phase(uvm_phase phase);
    uvm_report_server svr = uvm_report_server::get_server();
    if (svr.get_severity_count(UVM_ERROR) + svr.get_severity_count(UVM_FATAL) == 0)
      `uvm_info("RESULT", "*** TEST PASSED ***", UVM_NONE)
    else
      `uvm_info("RESULT", "*** TEST FAILED ***", UVM_NONE)
  endfunction
endclass


// -----------------------------------------------------------------------------
// Sanity : short mixed smoke test
// -----------------------------------------------------------------------------
class test_sanity extends axi_tniu_base_test;
  `uvm_component_utils(test_sanity)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  task run_phase(uvm_phase phase);
    vseq_mix v = vseq_mix::type_id::create("v");
    phase_ph = phase; num_txn = 10;
    run_vseq(v);
  endtask
endclass


// generic single-feature test macro
`define FEATURE_TEST(TNAME, VNAME)                                          \
class TNAME extends axi_tniu_base_test;                                     \
  `uvm_component_utils(TNAME)                                               \
  function new(string name, uvm_component parent); super.new(name,parent); endfunction \
  task run_phase(uvm_phase phase);                                          \
    VNAME v = VNAME::type_id::create("v");                                 \
    phase_ph = phase;                                                       \
    run_vseq(v);                                                            \
  endtask                                                                   \
endclass

`FEATURE_TEST(test_rd,        vseq_rd)
`FEATURE_TEST(test_wr,        vseq_wr)
`FEATURE_TEST(test_wrap,      vseq_wrap)
`FEATURE_TEST(test_err,       vseq_err)
`FEATURE_TEST(test_same_addr, vseq_same_addr)
`FEATURE_TEST(test_axid,      vseq_axid)
`FEATURE_TEST(test_ely,       vseq_ely)
`FEATURE_TEST(test_mix,       vseq_mix)


// -----------------------------------------------------------------------------
// Stress / random regression : large transaction count, all features on.
// -----------------------------------------------------------------------------
class test_random extends axi_tniu_base_test;
  `uvm_component_utils(test_random)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  task run_phase(uvm_phase phase);
    vseq_random v = vseq_random::type_id::create("v");
    phase_ph = phase; num_txn = 400;
    run_vseq(v);
  endtask
endclass

`endif // AXI_TNIU_TESTS_SV
