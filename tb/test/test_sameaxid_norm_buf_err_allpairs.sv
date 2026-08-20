`ifndef TEST_SAMEAXID_NORM_BUF_ERR_ALLPAIRS_SV
`define TEST_SAMEAXID_NORM_BUF_ERR_ALLPAIRS_SV

// =============================================================================
// File        : test_sameaxid_norm_buf_err_allpairs.sv
// Description : Full 4^3 same-AXID triple traversal for cg_special_mix.x_triple.
//
// Traversal:
//   prev2 = 0..3
//     prev = 0..3
//       cur = 0..3
//
// => 64 explicit ordered triples.
//
// IMPORTANT sequencing rule implemented here:
//
//   send combination N's 3 requests
//          |
//          v
//   wait until all 3 final RKNP responses are scoreboard-matched
//          |
//          v
//   wait until scoreboard traffic_drained()==1
//   (important for bufferable writes whose early RKNP response may precede B)
//          |
//          v
//   only then start combination N+1
//
// Therefore no next combination is injected while the previous combination
// still has an outstanding RKNP response or real AXI completion.
// =============================================================================

class test_sameaxid_norm_buf_err_allpairs extends axi_tniu_base_test;
  `uvm_component_utils(test_sameaxid_norm_buf_err_allpairs)

  localparam axi_tniu_protocol_pkg::ordkey_t FIXED_ORDERKEY = 8'h55;

  localparam int unsigned CLASS_COUNT       = 4;
  localparam int unsigned RSP_PER_COMBO     = 3;
  localparam time         COMBO_WAIT_TIMEOUT = 200us;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    // This feature is about same-AXID request-class history, not AXI response
    // reordering/interleaving.  Keep response behavior deterministic.
    cfg.axi_ooo_en              = 1'b0;
    cfg.axi_interleave_en       = 1'b0;
    cfg.axi_force_interleave_en = 1'b0;

    cfg.axi_ready_bp_en   = 1'b0;
    cfg.rsp_ready_bp_en   = 1'b0;
    cfg.rsp_ready_low_pct = 0;

    cfg.axi_min_addr_delay = 0;
    cfg.axi_max_addr_delay = 0;
    cfg.axi_min_resp_delay = 0;
    cfg.axi_max_resp_delay = 0;
    cfg.axi_min_beat_gap   = 0;
    cfg.axi_max_beat_gap   = 0;

    // Request ERROR class is generated directly by ST_ERR/EC_ADDR_DEC.
    // Do not add unrelated AXI-side error injection.
    cfg.axi_error_rsp_en         = 1'b0;
    cfg.axi_error_resp_random_en = 1'b0;
    cfg.axi_slverr_pct           = 0;

    // Keep the three requests of ONE triple adjacent.
    cfg.req_min_gap = 0;
    cfg.req_max_gap = 0;

    // Final base-test drain is only a safety net; every combination is already
    // fully drained inside run_testcase().
    cfg.rsp_drain_timeout = 2ms;
  endfunction

  protected function string class_name(int unsigned cls);
    case (cls)
      0: return "NORMAL";
      1: return "ERROR";
      2: return "BUF";
      3: return "BOTH";
      default: return "ILLEGAL";
    endcase
  endfunction

  // ---------------------------------------------------------------------------
  // Wait for the PREVIOUSLY SENT combination to finish completely.
  //
  // start_rsp is sampled BEFORE sending its 3 requests, so the target is
  // start_rsp+3 even if one or more responses return before seq.start() exits.
  // ---------------------------------------------------------------------------
  protected task wait_combo_complete(
      int unsigned start_rsp,
      int unsigned combo_index,
      int unsigned c0,
      int unsigned c1,
      int unsigned c2);

    bit done;

    done = 1'b0;

    fork : combo_wait
      begin
        // Poll the combined completion condition explicitly.
        //
        // This is important for bufferable writes:
        // RKNP early responses can make n_rsp_matched_final reach the target
        // before the real AXI B responses have drained.
        //
        // Using a direct wait() on traffic_drained() is fragile here because
        // traffic_drained() is a zero-argument function and its real
        // dependencies are scoreboard members hidden inside the function.
        // Instead, re-evaluate both conditions periodically, matching the
        // polling style already used by axi_tniu_base_test::drain_responses().
        forever begin
          if ((env.sb.n_rsp_matched_final >=
               (start_rsp + RSP_PER_COMBO)) &&
              env.sb.traffic_drained()) begin
            done = 1'b1;
            break;
          end

          #10ns;
        end
      end

      begin
        #(COMBO_WAIT_TIMEOUT);
      end
    join_any
    disable combo_wait;

    // If completion and timeout occur in the same time slot, accept the
    // completed scoreboard state rather than reporting a false timeout.
    if (!done &&
        (env.sb.n_rsp_matched_final >=
         (start_rsp + RSP_PER_COMBO)) &&
        env.sb.traffic_drained()) begin
      done = 1'b1;
    end

    if (!done) begin
      `uvm_fatal(
        "TRIPLE_COMBO_WAIT",
        $sformatf(
          {"combo=%0d %s->%s->%s did not complete in %0t; ",
           "matched_final=%0d target=%0d traffic_drained=%0b"},
          combo_index,
          class_name(c0),
          class_name(c1),
          class_name(c2),
          COMBO_WAIT_TIMEOUT,
          env.sb.n_rsp_matched_final,
          start_rsp + RSP_PER_COMBO,
          env.sb.traffic_drained()
        )
      )
    end

    `uvm_info(
      "TRIPLE_COMBO_DONE",
      $sformatf(
        "combo=%0d complete: %s -> %s -> %s; all 3 responses returned and traffic drained",
        combo_index,
        class_name(c0),
        class_name(c1),
        class_name(c2)
      ),
      UVM_MEDIUM
    )
  endtask

  virtual task run_testcase();
    seq_sameaxid_norm_buf_err_allpairs seq;
    axi_tniu_protocol_pkg::axi_id_t    axid;

    int unsigned combo_index;
    int unsigned rsp_start;

    combo_index = 0;

    axid = axi_tniu_protocol_pkg::map_ordkey_to_axid(FIXED_ORDERKEY);

    `uvm_info(
      "TEST_SAMEAXID_TRIPLE",
      $sformatf(
        "Start full 4^3 traversal: 64 triples, fixed OrderKey=0x%0h -> AXID=0x%0h",
        FIXED_ORDERKEY,
        axid
      ),
      UVM_LOW
    )

    for (int unsigned prev2 = 0; prev2 < CLASS_COUNT; prev2++) begin
      for (int unsigned prev = 0; prev < CLASS_COUNT; prev++) begin
        for (int unsigned cur = 0; cur < CLASS_COUNT; cur++) begin

          // The previous combination has already been fully drained here.
          // Snapshot the matched-response count BEFORE sending this combination.
          rsp_start = env.sb.n_rsp_matched_final;

          seq =
            seq_sameaxid_norm_buf_err_allpairs::type_id::create(
              $sformatf("seq_combo_%02d", combo_index));

          seq.use_fixed_orderkey = 1'b1;
          seq.fixed_orderkey     = FIXED_ORDERKEY;
          seq.combo_index        = combo_index;

          seq.class_prev2 =
            sameaxid_triple_class_e'(prev2);
          seq.class_prev =
            sameaxid_triple_class_e'(prev);
          seq.class_cur =
            sameaxid_triple_class_e'(cur);

          `uvm_info(
            "TEST_SAMEAXID_TRIPLE",
            $sformatf(
              "SEND combo=%0d/%0d : %s -> %s -> %s",
              combo_index + 1,
              CLASS_COUNT*CLASS_COUNT*CLASS_COUNT,
              class_name(prev2),
              class_name(prev),
              class_name(cur)
            ),
            UVM_LOW
          )

          // Sends exactly three adjacent requests.
          start_rknp_sequence(seq);

          // Do NOT start the next triple until this one's responses have all
          // returned and its AXI-side traffic is completely drained.
          wait_combo_complete(
            rsp_start,
            combo_index,
            prev2,
            prev,
            cur
          );

          combo_index++;
        end
      end
    end

    if (combo_index != 64)
      `uvm_fatal(
        "TEST_SAMEAXID_TRIPLE",
        $sformatf("Internal traversal error: expected 64 triples, got %0d",
                  combo_index)
      )

    `uvm_info(
      "TEST_SAMEAXID_TRIPLE",
      "Completed all 64 same-AXID ordered triples",
      UVM_LOW
    )
  endtask

endclass : test_sameaxid_norm_buf_err_allpairs

`endif // TEST_SAMEAXID_NORM_BUF_ERR_ALLPAIRS_SV
