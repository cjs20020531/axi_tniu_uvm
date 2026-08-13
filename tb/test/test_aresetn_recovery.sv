`ifndef TEST_ARESETN_RECOVERY_SV
`define TEST_ARESETN_RECOVERY_SV

// Basic warm-reset test:
//   1. complete one normal read before reset;
//   2. pulse aresetn 1->0->1 while the datapaths are idle;
//   3. complete one normal read after reset.
class test_aresetn_recovery extends axi_tniu_base_test;
  `uvm_component_utils(test_aresetn_recovery)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_testcase();
    seq_norm_rd        before_reset_seq;
    seq_aresetn_pulse  reset_seq;
    seq_norm_rd        after_reset_seq;

    before_reset_seq = seq_norm_rd::type_id::create("before_reset_seq");
    before_reset_seq.num_txn = 1;
    start_rknp_sequence(before_reset_seq);

    // Do not reset with an unfinished request in this basic testcase.  That is
    // a separate reset-abort scenario with different scoreboard semantics.
    drain_responses();

    reset_seq            = seq_aresetn_pulse::type_id::create("reset_seq");
    reset_seq.vif        = env.rknp_agt.drv.vif;
    reset_seq.low_cycles = 5;
    reset_seq.start(env.vseqr);

    after_reset_seq = seq_norm_rd::type_id::create("after_reset_seq");
    after_reset_seq.num_txn = 1;
    start_rknp_sequence(after_reset_seq);
  endtask
endclass : test_aresetn_recovery

`endif // TEST_ARESETN_RECOVERY_SV
