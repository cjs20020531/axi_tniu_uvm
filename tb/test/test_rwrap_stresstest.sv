`ifndef TEST_RWRAP_STRESSTEST_SV
`define TEST_RWRAP_STRESSTEST_SV

// Read-WRAP pressure test for wrap_align:
//   1. Accumulate four outstanding unaligned RDW requests so rwrap_cnt reaches
//      RWRAP_CNT_MAX (4) and rwrap_full asserts.
//   2. Keep sending RDW requests so a fifth unaligned request observes the
//      full condition and drives rwrap_allow low.
//   3. Let delayed AXI read responses retire requests, exercising the reverse
//      transitions on rwrap_cnt[2], rwrap_full and rwrap_allow.
class test_rwrap_stresstest extends axi_tniu_base_test;
  `uvm_component_utils(test_rwrap_stresstest)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    // Hold read responses long enough for the request side to fill the four
    // unaligned-read-WRAP tracking entries.  This remains far below the DUT
    // watchdog threshold.
    cfg.axi_min_resp_delay = 200;
    cfg.axi_max_resp_delay = 200;

    // Remove unrelated random stalls and response behavior.  The only intended
    // request-side stall is wrap_align back-pressure when rwrap_cnt reaches 4.
    cfg.axi_min_addr_delay = 0;
    cfg.axi_max_addr_delay = 0;
    cfg.axi_min_beat_gap   = 0;
    cfg.axi_max_beat_gap   = 0;
    cfg.axi_ready_bp_en    = 1'b0;
    cfg.rsp_ready_bp_en    = 1'b0;
    cfg.axi_error_rsp_en   = 1'b0;
    cfg.axi_ooo_en         = 1'b1;
    cfg.axi_interleave_en  = 1'b1;
    cfg.req_min_gap        = 0;
    cfg.req_max_gap        = 0;
    cfg.rsp_drain_timeout  = 200us;
    cfg.axi_force_interleave_en = 1'b1;
  endfunction

  virtual task run_testcase();
    seq_norm_rdw seq;

    seq = seq_norm_rdw::type_id::create("seq");

    // WRAP_LEN_FULL guarantees len >= 7, so an unaligned address produces a
    // non-zero wa2reqo_offset_addr and participates in rwrap allocation.
    // force_flit_aligned_addr=0 keeps only the protocol-required 2-byte
    // alignment and therefore allows address offsets 2, 4 and 6.
    seq.num_txn                 = 64;
    seq.wrap_len_mode           = WRAP_LEN_FULL;
    seq.force_flit_aligned_addr = WRAP_ADDR_NOALIGN;
    seq.force_flit_aligned_addr = 1'b0;

    start_rknp_sequence(seq);
  endtask

endclass : test_rwrap_stresstest

`endif // TEST_RWRAP_PRESSURE_SV
