// =============================================================================
// File        : axi_tniu_tests.sv
// Description : UVM test library.
//
//               Responsibility split:
//                 - rknp_sequence      : generates one transaction stream;
//                 - virtual_sequence   : coordinates multiple sequencers;
//                 - test               : configures the environment and defines
//                                        the testcase scenario.
//
//               Tests are selected with +UVM_TESTNAME=<test_name>.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_TNIU_TESTS_SV
`define AXI_TNIU_TESTS_SV

// -----------------------------------------------------------------------------
// Base test
//
// Derived tests implement run_testcase(). The base test owns environment setup,
// objection handling and the common response-drain policy.
// -----------------------------------------------------------------------------
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

    // Default used by directed tests unless a derived test changes it.
    cfg.num_txn = 40;
    configure_cfg();

    // Command-line configuration has the highest priority.
    if ($value$plusargs("num_txn=%d", plusarg_num_txn))
      cfg.num_txn = plusarg_num_txn;

    cfg.validate();

    uvm_config_db#(axi_tniu_cfg)::set(this, "*", "cfg", cfg);
    env = axi_tniu_env::type_id::create("env", this);
  endfunction

  // Derived tests may configure back-pressure, delay and transaction count.
  virtual function void configure_cfg();
  endfunction

  // Derived tests define their concrete scenario here.
  virtual task run_testcase();
    `uvm_fatal("BASE_TEST",
               "axi_tniu_base_test has no testcase; select a derived test")
  endtask

  // Start one RKNP traffic sequence. The AXI slave agent is reactive, so the
  // current environment does not need a virtual sequence for this operation.
  protected task start_rknp_sequence(rknp_base_seq seq,
                                     int unsigned  transaction_count);
    if (seq == null)
      `uvm_fatal("TEST_NULL_SEQ", "Attempted to start a null RKNP sequence")

    if ((env == null) || (env.rknp_agt == null) ||
        (env.rknp_agt.sqr == null))
      `uvm_fatal("TEST_NO_SQR", "RKNP sequencer is not available")

    seq.num = transaction_count;
    seq.start(env.rknp_agt.sqr);
  endtask

  protected task drain_responses();
    int unsigned expected_final_rsp;
    bit          drain_done;

    // At this point all request sequences have returned, so the tag manager
    // contains the exact number of requests accepted by the driver.
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
        {"All final RKNP responses received: requests=%0d ",
         "response_packets=%0d final_rsp=%0d"},
        expected_final_rsp, env.sb.n_rsp, env.sb.n_rsp_final), UVM_LOW)
    end
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

    if (svr.get_severity_count(UVM_ERROR) +
        svr.get_severity_count(UVM_FATAL) == 0)
      `uvm_info("RESULT", "*** TEST PASSED ***", UVM_NONE)
    else
      `uvm_info("RESULT", "*** TEST FAILED ***", UVM_NONE)
  endfunction
endclass : axi_tniu_base_test


// -----------------------------------------------------------------------------
// Sanity: normal/error INCR/WRAP RD/WR in random order; exact error ratio 30%.
// -----------------------------------------------------------------------------
class test_sanity extends axi_tniu_base_test;
  `uvm_component_utils(test_sanity)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void configure_cfg();
    // Twenty requests gives 14 normal and 6 error requests, while still
    // guaranteeing that all four normal and all four error categories appear.
    cfg.num_txn = 20;
  endfunction

  task run_testcase();
    rknp_mixed_traffic_seq seq;

    seq = rknp_mixed_traffic_seq::type_id::create("seq");
    seq.error_pct = 30;
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_sanity


// -----------------------------------------------------------------------------
// Directed INCR read
// -----------------------------------------------------------------------------
class test_rd extends axi_tniu_base_test;
  `uvm_component_utils(test_rd)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_testcase();
    rknp_rd_seq seq;

    seq = rknp_rd_seq::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_rd


// -----------------------------------------------------------------------------
// Directed INCR write
// -----------------------------------------------------------------------------
class test_wr extends axi_tniu_base_test;
  `uvm_component_utils(test_wr)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_testcase();
    rknp_wr_seq seq;

    seq = rknp_wr_seq::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_wr


// -----------------------------------------------------------------------------
// Directed WRAP read/write
// -----------------------------------------------------------------------------
class test_wrap extends axi_tniu_base_test;
  `uvm_component_utils(test_wrap)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_testcase();
    rknp_wrap_seq seq;

    seq = rknp_wrap_seq::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_wrap


// -----------------------------------------------------------------------------
// Directed request-error traffic
// -----------------------------------------------------------------------------
class test_err extends axi_tniu_base_test;
  `uvm_component_utils(test_err)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_testcase();
    rknp_err_seq seq;

    seq = rknp_err_seq::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_err


// -----------------------------------------------------------------------------
// Same-address ordering and back-pressure
// -----------------------------------------------------------------------------
class test_same_addr extends axi_tniu_base_test;
  `uvm_component_utils(test_same_addr)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_testcase();
    rknp_same_addr_seq seq;

    seq = rknp_same_addr_seq::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_same_addr


// -----------------------------------------------------------------------------
// OrderKey-to-AXID aliasing
// -----------------------------------------------------------------------------
class test_axid extends axi_tniu_base_test;
  `uvm_component_utils(test_axid)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_testcase();
    rknp_axid_seq seq;

    seq = rknp_axid_seq::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_axid


// -----------------------------------------------------------------------------
// Bufferable and early-response traffic
// -----------------------------------------------------------------------------
class test_ely extends axi_tniu_base_test;
  `uvm_component_utils(test_ely)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_testcase();
    rknp_ely_seq seq;

    seq = rknp_ely_seq::type_id::create("seq");
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_ely


// -----------------------------------------------------------------------------
// Composite directed testcase.
//
// The complete scenario is intentionally visible in this test rather than in
// virtual_sequences.sv. Each sequence contributes cfg.num_txn requests.
// -----------------------------------------------------------------------------
class test_mix extends axi_tniu_base_test;
  `uvm_component_utils(test_mix)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void configure_cfg();
    cfg.num_txn = 20;
  endfunction

  task run_testcase();
    rknp_rd_seq   rd_seq;
    rknp_wr_seq   wr_seq;
    rknp_wrap_seq wrap_seq;
    rknp_err_seq  err_seq;

    rd_seq   = rknp_rd_seq  ::type_id::create("rd_seq");
    wr_seq   = rknp_wr_seq  ::type_id::create("wr_seq");
    wrap_seq = rknp_wrap_seq::type_id::create("wrap_seq");
    err_seq  = rknp_err_seq ::type_id::create("err_seq");

    start_rknp_sequence(rd_seq,   cfg.num_txn);
    start_rknp_sequence(wr_seq,   cfg.num_txn);
    start_rknp_sequence(wrap_seq, cfg.num_txn);
    start_rknp_sequence(err_seq,  cfg.num_txn);
  endtask
endclass : test_mix


// -----------------------------------------------------------------------------
// Large constrained-random regression with an exact 30% request-error ratio.
// -----------------------------------------------------------------------------
class test_random extends axi_tniu_base_test;
  `uvm_component_utils(test_random)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void configure_cfg();
    cfg.num_txn = 400;
  endfunction

  task run_testcase();
    rknp_mixed_traffic_seq seq;

    seq = rknp_mixed_traffic_seq::type_id::create("seq");
    seq.error_pct = 30;
    start_rknp_sequence(seq, cfg.num_txn);
  endtask
endclass : test_random

`endif // AXI_TNIU_TESTS_SV
