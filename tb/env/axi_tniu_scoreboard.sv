// =============================================================================
// File        : axi_tniu_scoreboard.sv
// Description : End-to-end scoreboard for axi_tniu.
//
//               Important implementation detail for AXI write checking:
//               AW and W are independent AXI channels. Their monitor callbacks
//               may therefore arrive in either order, including in the same
//               simulation cycle. The scoreboard must not assume write_aw()
//               executes before write_w().
//
//               This version removes two independent callback-order races:
//
//               1) RKNP request prediction versus AXI AW/AR observation
//                  AW/AR may be observed before the RKNP request monitor has
//                  completed and published the source packet. Therefore AW and
//                  AR observations are cached per AxID and matched later.
//
//               2) AXI AW versus AXI W observation
//                  AW and W are independent AXI channels. Expected W bursts and
//                  observed W bursts are held in separate FIFO queues and are
//                  compared only when both sides are available.
//
//               No callback is treated as "unexpected" merely because its
//               counterpart has not arrived yet. Truly unmatched transactions
//               are reported in check_phase(), after traffic has drained.
//
// Project      : RKNoC - AXI Target NIU verification
// =============================================================================
`ifndef AXI_TNIU_SCOREBOARD_SV
`define AXI_TNIU_SCOREBOARD_SV

// Separate analysis imports so one component can receive many streams.
`uvm_analysis_imp_decl(_req)
`uvm_analysis_imp_decl(_rsp)
`uvm_analysis_imp_decl(_aw)
`uvm_analysis_imp_decl(_ar)
`uvm_analysis_imp_decl(_w)
`uvm_analysis_imp_decl(_b)
`uvm_analysis_imp_decl(_r)

class axi_tniu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_tniu_scoreboard)

  // ---------------------------------------------------------------------------
  // Analysis imports
  // ---------------------------------------------------------------------------
  uvm_analysis_imp_req #(rknp_seq_item, axi_tniu_scoreboard) req_imp;
  uvm_analysis_imp_rsp #(rknp_seq_item, axi_tniu_scoreboard) rsp_imp;
  uvm_analysis_imp_aw  #(axi_seq_item,  axi_tniu_scoreboard) aw_imp;
  uvm_analysis_imp_ar  #(axi_seq_item,  axi_tniu_scoreboard) ar_imp;
  uvm_analysis_imp_w   #(axi_seq_item,  axi_tniu_scoreboard) w_imp;
  uvm_analysis_imp_b   #(axi_seq_item,  axi_tniu_scoreboard) b_imp;
  uvm_analysis_imp_r   #(axi_seq_item,  axi_tniu_scoreboard) r_imp;

  axi_tniu_cfg      cfg;
  axi_tniu_refmodel refm;

  // ---------------------------------------------------------------------------
  // Expectation queues
  // ---------------------------------------------------------------------------

  // AXI address expectations are held per AxID.
  // Read and write transactions can use the same AxID, while AR and AW are
  // independent channels. find_axi_expectation() therefore searches for the
  // oldest expectation with the requested direction instead of blindly
  // popping the queue head.
  axi_tniu_expect exp_axi_q [axi_tniu_protocol_pkg::axi_id_t][$];

  // RKNP responses are matched by the complete RKNP transaction key.
  axi_tniu_expect exp_rsp_q [axi_tniu_protocol_pkg::rknp_txn_key_t][$];

  // AR-matched read expectations waiting for their complete AXI R burst.
  // AXI guarantees order for transactions with the same ID; different IDs
  // can legally be reordered or interleaved.
  axi_tniu_expect pending_r_q [axi_tniu_protocol_pkg::axi_id_t][$];

  // AW-matched write expectations waiting for B. This association is needed
  // to distinguish a normal write completion from the late real B response of
  // a bufferable write whose RKNP early response has already been emitted.
  axi_tniu_expect pending_b_q [axi_tniu_protocol_pkg::axi_id_t][$];

  // Observed AXI address transactions are cached per AxID. These queues solve
  // the case where the DUT emits AW/AR before the RKNP request monitor has
  // finished collecting and broadcasting the corresponding source packet.
  //
  // AW and AR use separate queues because they are independent AXI channels.
  axi_seq_item obs_aw_q [axi_tniu_protocol_pkg::axi_id_t][$];
  axi_seq_item obs_ar_q [axi_tniu_protocol_pkg::axi_id_t][$];

  // AXI4 W has no transaction ID. Expected and observed write-data bursts are
  // paired strictly in FIFO order, but either side is allowed to arrive first.
  axi_tniu_expect exp_w_q[$];
  axi_seq_item    obs_w_q[$];

  // Pending write-side SLVERR/DECERR flags captured on B and consumed at the
  // final RKNP write response. Read-side errors are stored directly in the
  // corresponding axi_tniu_expect because an interleaved read can finish with
  // ST_CONT rather than repeating ST_ERR on its final packet.
  bit err_pending [axi_tniu_protocol_pkg::axi_id_t][$];

  // Expected address of the next RKNP response packet for each source
  // transaction.  Response interleaving can split one read transaction into
  // several packets, so checking only the first packet leaves continuation
  // address updates (including WRAP rollover) completely unverified.
  logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0]
    next_rsp_addr_by_txn [int unsigned];

  // ---------------------------------------------------------------------------
  // Statistics
  // ---------------------------------------------------------------------------
  int unsigned n_req, n_rsp, n_rsp_final, n_rsp_matched_final;
  int unsigned n_exp_rsp_body, n_rsp_body_checked;
  int unsigned n_aw, n_ar, n_w, n_b, n_r;
  int unsigned n_exp_b, n_exp_r;
  int unsigned n_err_req, n_slverr, n_wrap, n_buf;
  int unsigned n_pass, n_fail;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    req_imp = new("req_imp", this);
    rsp_imp = new("rsp_imp", this);
    aw_imp  = new("aw_imp",  this);
    ar_imp  = new("ar_imp",  this);
    w_imp   = new("w_imp",   this);
    b_imp   = new("b_imp",   this);
    r_imp   = new("r_imp",   this);

    if (!uvm_config_db#(axi_tniu_cfg)::get(this, "", "cfg", cfg))
      `uvm_fatal("SB", "axi_tniu_cfg not found")

    refm = axi_tniu_refmodel::type_id::create("refm", this);
  endfunction

  // ===========================================================================
  // RKNP request: predict and enqueue expectations
  // ===========================================================================
  function void write_req(rknp_seq_item t);
    axi_tniu_expect                              e;
    axi_tniu_protocol_pkg::rknp_txn_key_t        key;

    if (!cfg.checks_enable)
      return;

    n_req++;

    e = refm.predict(t);
    if (e == null) begin
      `uvm_error("SB", $sformatf(
        "Reference model returned null for request No.%0d", t.txn_no))
      n_fail++;
      return;
    end

    key = axi_tniu_protocol_pkg::make_rknp_txn_key(
            t.iid, t.tid, t.orderkey);

    next_rsp_addr_by_txn[e.txn_no] = t.addr;

    // Only requests marked AXI-valid by the reference model are expected to
    // launch an AXI address transaction. Protocol-error requests may generate
    // an RKNP error response without any AW/AR transfer.
    if (e.axi_valid) begin
      exp_axi_q[e.axid].push_back(e);

      if (e.dir == AXI_WRITE)
        n_exp_b++;
      else
        n_exp_r++;

      // An AW/AR observation may already be waiting because the DUT can emit
      // the AXI address before the RKNP request monitor publishes this request.
      try_match_axi(e.axid, e.dir);
    end

    // Every request is expected to produce one final RKNP response.
    // Only the complete key is used; do not enqueue a duplicate by OrderKey.
    exp_rsp_q[key].push_back(e);

    if (e.rsp_opc == axi_tniu_protocol_pkg::RSP_OPC_RD)
      n_exp_rsp_body++;

    if (t.status == axi_tniu_protocol_pkg::ST_ERR)
      n_err_req++;
    if (t.is_wrap())
      n_wrap++;
    if (t.bufferable)
      n_buf++;
  endfunction

  // ===========================================================================
  // AXI AW / AR: cache first, then match when both sides are available
  // ===========================================================================

  // AW may arrive before or after the RKNP request prediction. Always cache the
  // observation first; try_match_axi() performs comparison only when a matching
  // expected AXI_WRITE transaction exists on the same AxID.
  function void write_aw(axi_seq_item t);
    if (!cfg.checks_enable)
      return;

    n_aw++;

    if (t == null) begin
      `uvm_error("C-CONV-01", "Observed null AXI AW transaction")
      n_fail++;
      return;
    end

    obs_aw_q[t.id].push_back(t);
    try_match_axi(t.id, AXI_WRITE);
  endfunction

  // AR uses the same deferred-matching mechanism as AW.
  function void write_ar(axi_seq_item t);
    if (!cfg.checks_enable)
      return;

    n_ar++;

    if (t == null) begin
      `uvm_error("C-CONV-01", "Observed null AXI AR transaction")
      n_fail++;
      return;
    end

    obs_ar_q[t.id].push_back(t);
    try_match_axi(t.id, AXI_READ);
  endfunction

  // Return the queue index of the oldest expected transaction with the
  // requested direction on this AxID. Read and write expectations may coexist
  // because AW and AR are independent channels.
  function int find_axi_expectation(
    axi_tniu_protocol_pkg::axi_id_t id,
    axi_dir_e                       dir
  );
    if (exp_axi_q.exists(id)) begin
      foreach (exp_axi_q[id][i]) begin
        if (exp_axi_q[id][i] != null &&
            exp_axi_q[id][i].dir == dir)
          return i;
      end
    end

    return -1;
  endfunction

  // Match every currently available AW/AR observation against the oldest
  // same-direction expectation on the same AxID.
  //
  // If either side is missing, return silently. This is not an error yet:
  // the counterpart may arrive later in the same cycle or after the RKNP
  // request monitor finishes collecting a multi-flit packet.
  function void try_match_axi(
    axi_tniu_protocol_pkg::axi_id_t id,
    axi_dir_e                       dir
  );
    axi_tniu_expect e;
    axi_seq_item    t;
    int             match_idx;

    forever begin
      match_idx = find_axi_expectation(id, dir);
      if (match_idx < 0)
        return;

      if (dir == AXI_WRITE) begin
        if (!obs_aw_q.exists(id) || obs_aw_q[id].size() == 0)
          return;

        t = obs_aw_q[id].pop_front();

        if (obs_aw_q[id].size() == 0)
          obs_aw_q.delete(id);
      end
      else begin
        if (!obs_ar_q.exists(id) || obs_ar_q[id].size() == 0)
          return;

        t = obs_ar_q[id].pop_front();

        if (obs_ar_q[id].size() == 0)
          obs_ar_q.delete(id);
      end

      e = exp_axi_q[id][match_idx];
      exp_axi_q[id].delete(match_idx);

      if (exp_axi_q[id].size() == 0)
        exp_axi_q.delete(id);

      compare_axi_phase(e, t, dir);
    end
  endfunction

  // Compare one already-paired expectation and AW/AR observation.
  function void compare_axi_phase(
    axi_tniu_expect e,
    axi_seq_item    t,
    axi_dir_e       dir
  );
    bit check_pass;

    check_pass = 1;

    if (e == null) begin
      `uvm_error("C-CONV-01", $sformatf(
        "Null AXI expectation for observed %s", dir.name()))
      n_fail++;
      return;
    end

    if (t == null) begin
      `uvm_error("C-CONV-01", $sformatf(
        " No.%0d null observed AXI %s transaction",
        e.txn_no, dir.name()))
      n_fail++;
      return;
    end

    // C-CONV-01: direction / opcode
    if (e.dir !== dir) begin
      `uvm_error("C-CONV-01", $sformatf(
        " No.%0d AxID=%0h dir mismatch exp=%s got=%s",
        e.txn_no, t.id, e.dir.name(), dir.name()))
      n_fail++;
      check_pass = 0;
    end

    // C-AXID-01: OrderKey -> AxID mapping
    if (e.axid !== t.id) begin
      `uvm_error("C-AXID-01", $sformatf(
        " No.%0d AxID mismatch exp=%0h got=%0h",
        e.txn_no, e.axid, t.id))
      n_fail++;
      check_pass = 0;
    end

    // C-CONV-02: addr / len / size / burst
    if (e.axaddr !== t.addr) begin
      `uvm_error("C-CONV-02", $sformatf(
        " No.%0d AxID=%0h ADDR mismatch exp=%0h got=%0h",
        e.txn_no, t.id, e.axaddr, t.addr))
      n_fail++;
      check_pass = 0;
    end

    if (e.axlen !== t.len) begin
      `uvm_error("C-CONV-02", $sformatf(
        " No.%0d AxID=%0h LEN exp=%0d got=%0d",
        e.txn_no, t.id, e.axlen, t.len))
      n_fail++;
      check_pass = 0;
    end

    if (e.axsize !== t.size) begin
      `uvm_error("C-CONV-02", $sformatf(
        " No.%0d AxID=%0h SIZE exp=%0d got=%0d",
        e.txn_no, t.id, e.axsize, t.size))
      n_fail++;
      check_pass = 0;
    end

    // C-WRAP-01: wrapped request -> AXI WRAP burst
    if (e.axburst !== t.burst) begin
      `uvm_error("C-WRAP-01", $sformatf(
        " No.%0d AxID=%0h BURST exp=%02b got=%02b",
        e.txn_no, t.id, e.axburst, t.burst))
      n_fail++;
      check_pass = 0;
    end

    // C-BP-01: bufferable -> AxCACHE[0]
    if (e.cache_buf !== t.cache[0]) begin
      `uvm_error("C-BP-01", $sformatf(
        " No.%0d AxID=%0h CACHE[0] exp=%0b got=%0b",
        e.txn_no, t.id, e.cache_buf, t.cache[0]))
      n_fail++;
      check_pass = 0;
    end

    if (check_pass)
      n_pass++;

    // AW matching establishes the expected W burst. W may already be waiting
    // in obs_w_q, so immediately try the second-stage W comparison.
    if (dir == AXI_WRITE) begin
      pending_b_q[e.axid].push_back(e);
      exp_w_q.push_back(e);
      try_match_w();
    end
    else begin
      pending_r_q[e.axid].push_back(e);
    end
  endfunction

  // ===========================================================================
  // AXI W: order-independent AW/W callback pairing
  // ===========================================================================

  // write_w() never reports an error merely because AW has not been processed
  // yet. It stores the observed complete W burst and lets try_match_w() perform
  // comparison as soon as the corresponding AW expectation becomes available.
  function void write_w(axi_seq_item t);
    if (!cfg.checks_enable)
      return;

    n_w++;

    if (t == null) begin
      `uvm_error("C-CONV-04", "Observed null AXI W transaction")
      n_fail++;
      return;
    end

    // The AXI monitor creates a fresh item for each completed W burst and does
    // not modify it after analysis_port.write(), so retaining this handle is
    // safe and preserves data/strb dynamic arrays.
    obs_w_q.push_back(t);
    try_match_w();
  endfunction

  // Pair all currently available expected/observed W bursts in FIFO order.
  // The function is called from both write_aw()'s processing path and write_w().
  function void try_match_w();
    axi_tniu_expect e;
    axi_seq_item    t;

    while (exp_w_q.size() > 0 && obs_w_q.size() > 0) begin
      e = exp_w_q.pop_front();
      t = obs_w_q.pop_front();
      compare_w_burst(e, t);
    end
  endfunction

  function void compare_w_burst(axi_tniu_expect e, axi_seq_item t);
    int unsigned compare_beats;
    bit          check_pass;

    check_pass = 1;

    if (e == null) begin
      `uvm_error("C-CONV-04", "Null expected AXI W burst")
      n_fail++;
      return;
    end

    if (t == null) begin
      `uvm_error("C-CONV-04", $sformatf(
        " No.%0d null observed AXI W burst", e.txn_no))
      n_fail++;
      return;
    end

    if (t.data.size() != e.axi_wdata.size()) begin
      `uvm_error("C-CONV-04", $sformatf(
        " No.%0d WDATA beat count mismatch exp=%0d got=%0d",
        e.txn_no, e.axi_wdata.size(), t.data.size()))
      n_fail++;
      check_pass = 0;
    end

    if (t.strb.size() != e.axi_wstrb.size()) begin
      `uvm_error("C-CONV-04", $sformatf(
        " No.%0d WSTRB beat count mismatch exp=%0d got=%0d",
        e.txn_no, e.axi_wstrb.size(), t.strb.size()))
      n_fail++;
      check_pass = 0;
    end

    compare_beats = (t.data.size() < e.axi_wdata.size()) ?
                    t.data.size() : e.axi_wdata.size();

    for (int i = 0; i < compare_beats; i++) begin
      if (t.data[i] !== e.axi_wdata[i]) begin
        `uvm_error("C-CONV-04", $sformatf(
          " No.%0d WDATA mismatch beat=%0d exp=%016h got=%016h",
          e.txn_no, i, e.axi_wdata[i], t.data[i]))
        n_fail++;
        check_pass = 0;
      end
    end

    compare_beats = (t.strb.size() < e.axi_wstrb.size()) ?
                    t.strb.size() : e.axi_wstrb.size();

    for (int i = 0; i < compare_beats; i++) begin
      if (t.strb[i] !== e.axi_wstrb[i]) begin
        `uvm_error("C-CONV-04", $sformatf(
          " No.%0d WSTRB mismatch beat=%0d exp=%02h got=%02h",
          e.txn_no, i, e.axi_wstrb[i], t.strb[i]))
        n_fail++;
        check_pass = 0;
      end
    end

    if (check_pass)
      n_pass++;
  endfunction

  // ===========================================================================
  // RKNP read-response body prediction and comparison
  // ===========================================================================

  // Build the physical RKNP body expected at the DUT output. For a normal
  // response, r contains the AXI RDATA actually accepted by the DUT. For a
  // request error or watchdog timeout, force_zero builds the DUT-organized
  // zero body while preserving the requested length and BE geometry.
  function void build_expected_read_body(
    axi_tniu_expect e,
    axi_seq_item    r,
    bit             force_zero
  );
    int unsigned nbyte;
    int unsigned start_lane;
    int unsigned last_lane;
    int unsigned num_beats;
    bit          unaligned_wrap;
    logic [axi_tniu_protocol_pkg::NBYTEPERWORD*8-1:0] beat_data;

    if (e == null || e.req == null)
      return;

    nbyte          = axi_tniu_protocol_pkg::NBYTEPERWORD;
    start_lane     = int'(e.req.addr & (nbyte - 1));
    last_lane      = (start_lane + int'(e.req.len)) % nbyte;
    unaligned_wrap = e.req.is_wrap() &&
                     (e.req.len > (nbyte - 2)) &&
                     (start_lane != 0);

    e.exp_rsp_bytes.delete();
    e.exp_rsp_be.delete();

    if (force_zero)
      num_beats = int'(e.axlen) + 1;
    else if (r != null)
      num_beats = r.data.size();
    else
      num_beats = 0;

    if (!force_zero && r != null &&
        r.data.size() != (int'(e.axlen) + 1)) begin
      `uvm_error("C-RSP-DATA", $sformatf(
        " No.%0d AXI R beat count exp=%0d got=%0d",
        e.txn_no, int'(e.axlen) + 1, r.data.size()))
      n_fail++;
    end

    // INCR, aligned WRAP and a short WRAP converted to AXI INCR.
    if (!unaligned_wrap) begin
      for (int unsigned beat = 0; beat < num_beats; beat++) begin
        beat_data = (force_zero || r == null) ? '0 : r.data[beat];

        for (int unsigned lane = 0; lane < nbyte; lane++) begin
          bit lane_valid;

          lane_valid = 1'b1;
          if (beat == 0 && lane < start_lane)
            lane_valid = 1'b0;
          if (beat == (num_beats - 1) && lane > last_lane)
            lane_valid = 1'b0;

          e.exp_rsp_bytes.push_back(beat_data[lane*8 +: 8]);
          e.exp_rsp_be.push_back(lane_valid);
        end
      end
    end
    else begin
      // For an unaligned real WRAP, wrap_adjust masks the low lanes of AXI
      // beat0, passes the remaining beats, then appends beat0's low lanes.
      for (int unsigned beat = 0; beat < num_beats; beat++) begin
        beat_data = (force_zero || r == null) ? '0 : r.data[beat];

        for (int unsigned lane = 0; lane < nbyte; lane++) begin
          e.exp_rsp_bytes.push_back(beat_data[lane*8 +: 8]);
          e.exp_rsp_be.push_back((beat != 0) || (lane >= start_lane));
        end
      end

      beat_data = (force_zero || r == null || num_beats == 0) ?
                  '0 : r.data[0];

      for (int unsigned lane = 0; lane < nbyte; lane++) begin
        e.exp_rsp_bytes.push_back(beat_data[lane*8 +: 8]);
        e.exp_rsp_be.push_back(lane < start_lane);
      end
    end

    e.rsp_body_ready = 1'b1;
    try_compare_read_body(e);
  endfunction

  // AXI R and RKNP response analysis callbacks have no guaranteed ordering.
  // Compare only after the complete expected and observed transaction exist.
  function void try_compare_read_body(axi_tniu_expect e);
    int unsigned compare_bytes;
    int unsigned be_mismatch_count;
    int unsigned data_mismatch_count;
    int          first_be_mismatch;
    int          first_data_mismatch;
    bit          check_pass;

    if (e == null || !e.rsp_body_ready || !e.rsp_final_seen ||
        e.rsp_body_checked)
      return;

    e.rsp_body_checked = 1'b1;
    n_rsp_body_checked++;
    check_pass          = 1'b1;
    be_mismatch_count   = 0;
    data_mismatch_count = 0;
    first_be_mismatch   = -1;
    first_data_mismatch = -1;

    if (e.obs_rsp_bytes.size() != e.exp_rsp_bytes.size()) begin
      `uvm_error("C-RSP-DATA", $sformatf(
        " No.%0d RKNP read body byte count exp=%0d got=%0d",
        e.txn_no, e.exp_rsp_bytes.size(), e.obs_rsp_bytes.size()))
      n_fail++;
      check_pass = 1'b0;
    end

    if (e.obs_rsp_be.size() != e.exp_rsp_be.size()) begin
      `uvm_error("C-RSP-BE", $sformatf(
        " No.%0d RKNP read BE count exp=%0d got=%0d",
        e.txn_no, e.exp_rsp_be.size(), e.obs_rsp_be.size()))
      n_fail++;
      check_pass = 1'b0;
    end

    compare_bytes = e.obs_rsp_bytes.size();
    if (compare_bytes > e.exp_rsp_bytes.size())
      compare_bytes = e.exp_rsp_bytes.size();
    if (compare_bytes > e.obs_rsp_be.size())
      compare_bytes = e.obs_rsp_be.size();
    if (compare_bytes > e.exp_rsp_be.size())
      compare_bytes = e.exp_rsp_be.size();

    for (int unsigned i = 0; i < compare_bytes; i++) begin
      if (e.obs_rsp_be[i] !== e.exp_rsp_be[i]) begin
        if (first_be_mismatch < 0)
          first_be_mismatch = i;
        be_mismatch_count++;
      end

      // Invalid byte lanes carry no protocol data and are intentionally
      // treated as don't-care. Their BE value is still checked above.
      if (e.exp_rsp_be[i] &&
          (e.obs_rsp_bytes[i] !== e.exp_rsp_bytes[i])) begin
        if (first_data_mismatch < 0)
          first_data_mismatch = i;
        data_mismatch_count++;
      end
    end

    if (be_mismatch_count != 0) begin
      `uvm_error("C-RSP-BE", $sformatf(
        {" No.%0d RKNP read BE mismatch count=%0d first_byte=%0d ",
         "exp=%0b got=%0b"},
        e.txn_no, be_mismatch_count, first_be_mismatch,
        e.exp_rsp_be[first_be_mismatch],
        e.obs_rsp_be[first_be_mismatch]))
      n_fail++;
      check_pass = 1'b0;
    end

    if (data_mismatch_count != 0) begin
      `uvm_error("C-RSP-DATA", $sformatf(
        {" No.%0d RKNP read data mismatch count=%0d first_byte=%0d ",
         "exp=%02h got=%02h"},
        e.txn_no, data_mismatch_count, first_data_mismatch,
        e.exp_rsp_bytes[first_data_mismatch],
        e.obs_rsp_bytes[first_data_mismatch]))
      n_fail++;
      check_pass = 1'b0;
    end

    if (check_pass)
      n_pass++;
  endfunction

  // Cross-check the AXI read completion status against the FIRST RKNP response
  // packet. This deliberately does not use the final RKNP packet: after a read
  // has been interleaved, resumed packets must carry ST_CONT even if the AXI
  // read transaction completed with SLVERR/DECERR.
  //
  // The AXI monitor publishes the R transaction at RLAST while the RKNP monitor
  // may publish an earlier response packet first. The shared expectation object
  // makes this check callback-order independent.
  function void try_check_read_rsp_status(axi_tniu_expect e);
    axi_tniu_protocol_pkg::status_e expected_status;

    if (e == null ||
        e.rsp_opc != axi_tniu_protocol_pkg::RSP_OPC_RD ||
        !e.axi_valid ||
        e.rsp_was_timeout ||
        !e.rsp_final_seen ||
        !e.axi_rsp_seen ||
        !e.first_rsp_seen ||
        e.first_rsp_axi_checked)
      return;

    e.first_rsp_axi_checked = 1'b1;
    expected_status = e.axi_rsp_error ?
                      axi_tniu_protocol_pkg::ST_ERR :
                      axi_tniu_protocol_pkg::ST_OK;

    if (e.first_rsp_status !== expected_status) begin
      `uvm_error("C-ERR-02", $sformatf(
        {" No.%0d AXI read response status mismatch: AxID=%0h ",
         "AXI_error=%0b expected first RKNP status=%s got=%s"},
        e.txn_no, e.axid, e.axi_rsp_error,
        expected_status.name(), e.first_rsp_status.name()))
      n_fail++;
    end

    if (e.axi_rsp_error &&
        e.first_rsp_errcode !== axi_tniu_protocol_pkg::EC_TARGET) begin
      `uvm_error("C-ERR-02", $sformatf(
        {" No.%0d AXI SLVERR/DECERR on AxID=%0h requires EC_TARGET on ",
         "the first RKNP response packet, got %s"},
        e.txn_no, e.axid, e.first_rsp_errcode.name()))
      n_fail++;
    end
  endfunction

  // ===========================================================================
  // AXI B: capture SLVERR/DECERR for error upgrade
  // ===========================================================================
  function void write_b(axi_seq_item t);
    axi_tniu_expect e;

    if (!cfg.checks_enable)
      return;

    n_b++;

    if (t == null) begin
      `uvm_error("C-ERR-02", "Observed null AXI B response")
      n_fail++;
      return;
    end

    if (!pending_b_q.exists(t.id) || pending_b_q[t.id].size() == 0) begin
      `uvm_error("C-ERR-02", $sformatf(
        "Observed AXI B response on AxID=%0h without a matched AW expectation",
        t.id))
      n_fail++;
      return;
    end

    e = pending_b_q[t.id].pop_front();
    if (pending_b_q[t.id].size() == 0)
      pending_b_q.delete(t.id);

    if (t.resp == 2'b10 || t.resp == 2'b11)
      n_slverr++;

    // A bufferable write has already produced its RKNP early response. A late
    // real B (whether OKAY or error) only retires DUT state and must not be
    // attached to the next same-ID response. The same applies after timeout.
    if (e.req.bufferable || e.rsp_was_timeout)
      return;

    if (t.resp == 2'b10 || t.resp == 2'b11) begin
      err_pending[t.id].push_back(1);
    end
    else begin
      err_pending[t.id].push_back(0);
    end
  endfunction

  // ===========================================================================
  // AXI R: capture SLVERR/DECERR on completed read burst
  // ===========================================================================
  function void write_r(axi_seq_item t);
    axi_tniu_expect e;

    if (!cfg.checks_enable)
      return;

    n_r++;

    if (t == null) begin
      `uvm_error("C-RSP-DATA", "Observed null AXI R burst")
      n_fail++;
      return;
    end

    if (!pending_r_q.exists(t.id) || pending_r_q[t.id].size() == 0) begin
      `uvm_error("C-RSP-DATA", $sformatf(
        "Observed AXI R burst on AxID=%0h without a matched AR expectation",
        t.id))
      n_fail++;
      return;
    end

    e = pending_r_q[t.id].pop_front();
    if (pending_r_q[t.id].size() == 0)
      pending_r_q.delete(t.id);

    // A response arriving after watchdog timeout must be consumed, but it must
    // not overwrite the already-checked zero timeout body. For a normal read,
    // bind the AXI completion status to this exact expectation instead of using
    // the shared err_pending queue (which is write-side only).
    if (!e.rsp_was_timeout) begin
      e.axi_rsp_seen  = 1'b1;
      e.axi_rsp_error = (t.resp == 2'b10 || t.resp == 2'b11);

      if (e.axi_rsp_error)
        n_slverr++;

      build_expected_read_body(e, t, 1'b0);
      try_check_read_rsp_status(e);
    end
  endfunction

  // ===========================================================================
  // RKNP response: final check + leak accounting
  // ===========================================================================
  function void write_rsp(rknp_seq_item t);
    axi_tniu_expect                       e;
    axi_tniu_protocol_pkg::rknp_txn_key_t key;
    bit                                   upgraded;
    bit                                   check_pass;
    int unsigned                          packet_valid_bytes;
    longint unsigned                      expected_addr;
    longint unsigned                      wrap_bytes;
    longint unsigned                      wrap_base;
    longint unsigned                      wrap_offset;

    // n_rsp counts every observed packet and n_rsp_final counts every observed
    // LW=1 packet, including protocol violations such as a duplicate response.
    // n_rsp_matched_final advances only after a final packet has matched and
    // retired a real expectation; the test drain must use that qualified count.
    n_rsp++;
    if (t.rsp_lw)
      n_rsp_final++;

    if (!cfg.checks_enable)
      return;

    check_pass = 1;
    upgraded   = 0;

    key = axi_tniu_protocol_pkg::make_rknp_txn_key(
            t.iid, t.tid, t.orderkey);

    if (!exp_rsp_q.exists(key) || exp_rsp_q[key].size() == 0) begin
      `uvm_error("C-LEAK-01", $sformatf(
        "No.%0d unexpected response iid=0x%0h tid=0x%0h orderkey=0x%0h",
        t.txn_no, t.iid, t.tid, t.orderkey))
      n_fail++;
      return;
    end

    // Every packet, including ST_CONT continuation packets, belongs to the
    // transaction at the queue head. LW, not status, determines retirement.
    e = exp_rsp_q[key][0];

    if (e == null) begin
      `uvm_error("C-LEAK-01", $sformatf(
        "Null response expectation for iid=0x%0h tid=0x%0h orderkey=0x%0h",
        t.iid, t.tid, t.orderkey))
      n_fail++;
      return;
    end

    if (e.txn_no != t.txn_no) begin
      `uvm_error("C-LEAK-01", $sformatf(
        "Response label mismatch exp=No.%0d got=No.%0d",
        e.txn_no, t.txn_no))
      n_fail++;
      check_pass = 0;
    end

    // Check the response address on every packet, not only on packet zero.
    // This catches a wrong req_order address update when an interleaved read
    // resumes with ST_CONT.  The first expected address is the source request
    // address; subsequent values are advanced below by the number of valid
    // payload bytes carried by the current packet.
    if (!next_rsp_addr_by_txn.exists(e.txn_no))
      next_rsp_addr_by_txn[e.txn_no] = e.req.addr;

    if (t.addr !== next_rsp_addr_by_txn[e.txn_no]) begin
      `uvm_error("C-RSP-HDR", $sformatf(
        {" No.%0d rsp packet[%0d] ADDR exp=0x%08h got=0x%08h ",
         "status=%s lw=%0b"},
        e.txn_no, e.rsp_packet_count,
        next_rsp_addr_by_txn[e.txn_no], t.addr,
        t.rsp_status.name(), t.rsp_lw))
      n_fail++;
      check_pass = 0;
    end

    // C-CONV-01: response opcode
    if (e.rsp_opc !== t.rsp_opc) begin
      `uvm_error("C-CONV-01", $sformatf(
        " No.%0d rsp opc exp=%s got=%s",
        e.txn_no, e.rsp_opc.name(), t.rsp_opc.name()))
      n_fail++;
      check_pass = 0;
    end

    // Check request-derived response header fields on the first packet. For a
    // normal AXI completion, AXI-USER may replace user[8], so it is checked
    // only for responses organized locally by the DUT.
    if (e.rsp_packet_count == 0) begin
      if (e.req.qos !== t.qos) begin
        `uvm_error("C-RSP-HDR", $sformatf(
          " No.%0d rsp QoS exp=%0d got=%0d",
          e.txn_no, e.req.qos, t.qos))
        n_fail++;
        check_pass = 0;
      end

      if (e.req.rknp_user !== t.rknp_user ||
          e.req.axlock    !== t.axlock    ||
          e.req.axport    !== t.axport    ||
          e.req.axcache   !== t.axcache) begin
        `uvm_error("C-RSP-HDR", $sformatf(
          {" No.%0d rsp USER request-derived fields mismatch ",
           "exp={rknp=%0b lock=%0b port=%0h cache=%0h} ",
           "got={rknp=%0b lock=%0b port=%0h cache=%0h}"},
          e.txn_no,
          e.req.rknp_user, e.req.axlock, e.req.axport, e.req.axcache,
          t.rknp_user,     t.axlock,     t.axport,     t.axcache))
        n_fail++;
        check_pass = 0;
      end

      if ((!e.axi_valid || e.req.bufferable ||
           (t.rsp_status == axi_tniu_protocol_pkg::ST_ERR &&
            t.rsp_errcode == axi_tniu_protocol_pkg::EC_TIMEOUT)) &&
          e.req.axi_user !== t.axi_user) begin
        `uvm_error("C-RSP-HDR", $sformatf(
          " No.%0d self-generated rsp AXI-USER exp=%0b got=%0b",
          e.txn_no, e.req.axi_user, t.axi_user))
        n_fail++;
        check_pass = 0;
      end
    end

    // RKNP read status semantics:
    //   packet 0                  : ST_OK or ST_ERR
    //   packet 1..N after resume  : ST_CONT
    //
    // Save packet-0 status for the deferred AXI-R cross-check. Do not require
    // the final packet to repeat ST_ERR: after interleaving, the final packet
    // is a continuation and therefore legitimately carries ST_CONT.
    if (e.rsp_opc == axi_tniu_protocol_pkg::RSP_OPC_RD) begin
      if (e.rsp_packet_count == 0) begin
        e.first_rsp_seen    = 1'b1;
        e.first_rsp_status  = t.rsp_status;
        e.first_rsp_errcode = t.rsp_errcode;

        if (t.rsp_status === axi_tniu_protocol_pkg::ST_CONT) begin
          `uvm_error("C-RSP-HDR", $sformatf(
            " No.%0d first RKNP read response packet must be ST_OK/ST_ERR, got ST_CONT",
            e.txn_no))
          n_fail++;
          check_pass = 0;
        end
      end
      else if (t.rsp_status !== axi_tniu_protocol_pkg::ST_CONT) begin
        `uvm_error("C-RSP-HDR", $sformatf(
          {" No.%0d RKNP read continuation packet[%0d] must be ST_CONT ",
           "after interleaving, got %s (lw=%0b)"},
          e.txn_no, e.rsp_packet_count, t.rsp_status.name(), t.rsp_lw))
        n_fail++;
        check_pass = 0;
      end
    end

    // One RKNP transaction may be split into several response packets by read
    // interleaving. Keep accumulating until the packet whose LW is one.
    if (e.rsp_opc == axi_tniu_protocol_pkg::RSP_OPC_RD) begin
      foreach (t.rd_bytes[i])
        e.obs_rsp_bytes.push_back(t.rd_bytes[i]);
      foreach (t.rd_be[i])
        e.obs_rsp_be.push_back(t.rd_be[i]);

      // The next packet header denotes the next logical payload byte.  Count
      // BE=1 lanes rather than physical flits so an unaligned first/last flit
      // advances by only the bytes that actually belong to the transaction.
      packet_valid_bytes = 0;
      foreach (t.rd_be[i])
        if (t.rd_be[i] === 1'b1)
          packet_valid_bytes++;

      if (!t.rsp_lw) begin
        expected_addr = next_rsp_addr_by_txn[e.txn_no];

        if (e.req.is_wrap()) begin
          wrap_bytes  = longint'(e.req.len) + 1;
          wrap_base   = longint'(e.req.addr) & ~(wrap_bytes - 1);
          wrap_offset = (expected_addr - wrap_base + packet_valid_bytes) %
                        wrap_bytes;
          next_rsp_addr_by_txn[e.txn_no] = wrap_base + wrap_offset;
        end
        else begin
          next_rsp_addr_by_txn[e.txn_no] =
            expected_addr + packet_valid_bytes;
        end
      end
    end

    e.rsp_packet_count++;

    // Intermediate response packet: LW=0 means this RKNP transaction still
    // has response flits to come. Status was checked above according to whether
    // this is the first packet or a resumed continuation packet.
    if (t.rsp_lw == 1'b0) begin
      if (check_pass)
        n_pass++;
      return;
    end

    e.rsp_final_seen = 1'b1;

    // Record timeout for both directions. A late real R/B completion must be
    // drained, but must never be applied to the next same-ID transaction.
    if (t.rsp_status == axi_tniu_protocol_pkg::ST_ERR &&
        t.rsp_errcode == axi_tniu_protocol_pkg::EC_TIMEOUT)
      e.rsp_was_timeout = 1'b1;

    if (e.rsp_opc == axi_tniu_protocol_pkg::RSP_OPC_RD) begin
      if (e.rsp_was_timeout) begin
        build_expected_read_body(e, null, 1'b1);
      end
      else if (!e.axi_valid) begin
        // Request-error read responses are locally generated and zero-filled.
        build_expected_read_body(e, null, 1'b1);
      end
      else begin
        // If AXI R arrived first this compares now; otherwise write_r() will
        // complete the comparison when the R burst later becomes available.
        try_compare_read_body(e);
      end

      // The first RKNP status may have arrived before or after AXI RLAST.
      // Compare only once both complete observations are available.
      try_check_read_rsp_status(e);
    end

    // Final response: remove expectation.
    void'(exp_rsp_q[key].pop_front());
    n_rsp_matched_final++;

    if (exp_rsp_q[key].size() == 0)
      exp_rsp_q.delete(key);

    next_rsp_addr_by_txn.delete(e.txn_no);

    // C-ERR-02:
    //   * Locally-generated request errors still use the final packet check.
    //   * Write-side AXI B errors are still checked on the final write response.
    //   * Read-side AXI R errors were checked against the FIRST read packet by
    //     try_check_read_rsp_status(); an interleaved final packet may be CONT.
    if (e.rsp_status == axi_tniu_protocol_pkg::ST_ERR) begin
      if (t.rsp_status !== axi_tniu_protocol_pkg::ST_ERR) begin
        `uvm_error("C-ERR-02", $sformatf(
          " No.%0d expected ERR response", e.txn_no))
        n_fail++;
        check_pass = 0;
      end
      else if (e.rsp_errcode !== t.rsp_errcode) begin
        `uvm_error("C-ERR-02", $sformatf(
          " No.%0d errcode exp=%s got=%s",
          e.txn_no, e.rsp_errcode.name(), t.rsp_errcode.name()))
        n_fail++;
        check_pass = 0;
      end
    end
    else if (e.rsp_opc == axi_tniu_protocol_pkg::RSP_OPC_WR) begin
      // Non-error write request: expected OK unless AXI B forced an upgrade.
      if (err_pending.exists(e.axid) && err_pending[e.axid].size() > 0)
        upgraded = err_pending[e.axid].pop_front();

      if (err_pending.exists(e.axid) && err_pending[e.axid].size() == 0)
        err_pending.delete(e.axid);

      if (upgraded &&
          t.rsp_status !== axi_tniu_protocol_pkg::ST_ERR) begin
        `uvm_error("C-ERR-02", $sformatf(
          " No.%0d AXI SLVERR/DECERR on AxID=%0h but RKNP status=%s",
          e.txn_no, e.axid, t.rsp_status.name()))
        n_fail++;
        check_pass = 0;
      end
      else if (upgraded &&
               t.rsp_errcode !== axi_tniu_protocol_pkg::EC_TARGET) begin
        `uvm_error("C-ERR-02", $sformatf(
          " No.%0d AXI SLVERR/DECERR on AxID=%0h expected EC_TARGET, got %s",
          e.txn_no, e.axid, t.rsp_errcode.name()))
        n_fail++;
        check_pass = 0;
      end
    end

    if (check_pass)
      n_pass++;
  endfunction

  // ===========================================================================
  // Final drain / leak checks
  // ===========================================================================
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    if (!cfg.checks_enable)
      return;

    foreach (exp_rsp_q[k]) begin
      if (exp_rsp_q[k].size() != 0) begin
        `uvm_error("C-LEAK-01", $sformatf(
          "%0d RKNP request expectation(s), key=0x%0h, never got a final response",
          exp_rsp_q[k].size(), k))
        n_fail++;
      end
    end

    // Observed address transactions that remain here never found a matching
    // RKNP-derived expectation. They are genuinely unexpected after drain.
    foreach (obs_aw_q[k]) begin
      if (obs_aw_q[k].size() != 0) begin
        `uvm_error("C-CONV-01", $sformatf(
          "%0d observed AW transaction(s) on AxID=%0h had no matching RKNP request",
          obs_aw_q[k].size(), k))
        n_fail++;
      end
    end

    foreach (obs_ar_q[k]) begin
      if (obs_ar_q[k].size() != 0) begin
        `uvm_error("C-CONV-01", $sformatf(
          "%0d observed AR transaction(s) on AxID=%0h had no matching RKNP request",
          obs_ar_q[k].size(), k))
        n_fail++;
      end
    end

    foreach (exp_axi_q[k]) begin
      if (exp_axi_q[k].size() != 0) begin
        `uvm_error("C-LEAK-01", $sformatf(
          "%0d predicted AXI address transaction(s) on AxID=%0h never appeared",
          exp_axi_q[k].size(), k))
        n_fail++;
      end
    end

    // Expected W without observed W.
    if (exp_w_q.size() != 0) begin
      `uvm_error("C-LEAK-01", $sformatf(
        "%0d AW-matched write expectation(s) never got a complete W burst",
        exp_w_q.size()))
      n_fail++;
    end

    // Observed W without a corresponding matched AW.
    if (obs_w_q.size() != 0) begin
      `uvm_error("C-CONV-04", $sformatf(
        "%0d observed W burst(s) never found a corresponding AW expectation",
        obs_w_q.size()))
      n_fail++;
    end

    if (n_b != n_exp_b) begin
      `uvm_error("C-LEAK-01", $sformatf(
        "AXI B completion count mismatch expected=%0d observed=%0d",
        n_exp_b, n_b))
      n_fail++;
    end

    if (n_r != n_exp_r) begin
      `uvm_error("C-LEAK-01", $sformatf(
        "AXI R-burst completion count mismatch expected=%0d observed=%0d",
        n_exp_r, n_r))
      n_fail++;
    end

    foreach (pending_r_q[k]) begin
      if (pending_r_q[k].size() != 0) begin
        `uvm_error("C-LEAK-01", $sformatf(
          "%0d AR-matched read expectation(s) on AxID=%0h never got a complete R burst",
          pending_r_q[k].size(), k))
        n_fail++;
      end
    end

    foreach (pending_b_q[k]) begin
      if (pending_b_q[k].size() != 0) begin
        `uvm_error("C-LEAK-01", $sformatf(
          "%0d AW-matched write expectation(s) on AxID=%0h never got a B response",
          pending_b_q[k].size(), k))
        n_fail++;
      end
    end

    if (n_rsp_body_checked != n_exp_rsp_body) begin
      `uvm_error("C-RSP-DATA", $sformatf(
        "RKNP read-response body check count mismatch expected=%0d checked=%0d",
        n_exp_rsp_body, n_rsp_body_checked))
      n_fail++;
    end
  endfunction

  // True only after every predicted response/address/data completion has been
  // observed.  Bufferable writes require this extra AXI-side drain because
  // their RKNP early response legitimately precedes the real B response.
  function bit traffic_drained();
    if ((n_b < n_exp_b) || (n_r < n_exp_r) ||
        (n_rsp_body_checked < n_exp_rsp_body) ||
        (exp_w_q.size() != 0) || (obs_w_q.size() != 0))
      return 1'b0;

    foreach (exp_rsp_q[k])
      if (exp_rsp_q[k].size() != 0)
        return 1'b0;

    foreach (exp_axi_q[k])
      if (exp_axi_q[k].size() != 0)
        return 1'b0;

    foreach (obs_aw_q[k])
      if (obs_aw_q[k].size() != 0)
        return 1'b0;

    foreach (obs_ar_q[k])
      if (obs_ar_q[k].size() != 0)
        return 1'b0;

    foreach (pending_r_q[k])
      if (pending_r_q[k].size() != 0)
        return 1'b0;

    foreach (pending_b_q[k])
      if (pending_b_q[k].size() != 0)
        return 1'b0;

    return 1'b1;
  endfunction

  // Return total pending AW observations across all AxIDs for the summary.
  function int unsigned count_pending_aw();
    int unsigned count;

    count = 0;
    foreach (obs_aw_q[k])
      count += obs_aw_q[k].size();

    return count;
  endfunction

  // Return total pending AR observations across all AxIDs for the summary.
  function int unsigned count_pending_ar();
    int unsigned count;

    count = 0;
    foreach (obs_ar_q[k])
      count += obs_ar_q[k].size();

    return count;
  endfunction

  function int unsigned count_pending_r();
    int unsigned count;

    count = 0;
    foreach (pending_r_q[k])
      count += pending_r_q[k].size();

    return count;
  endfunction

  function void report_phase(uvm_phase phase);
    string summary;
  
    super.report_phase(phase);
  
    summary = $sformatf(
      {
        "\n==== axi_tniu scoreboard summary ====\n",
        "  REQ=%0d  RSP_PKT=%0d  RSP_FINAL(raw/matched)=%0d/%0d\n",
        "  AW=%0d AR=%0d W=%0d B=%0d/%0d R=%0d/%0d\n",
        "  RKNP_READ_BODY(checked/expected)=%0d/%0d\n",
        "  ERR_req=%0d  AXI_SLVERR=%0d  WRAP=%0d  BUFFERABLE=%0d\n",
        "  pending_AW=%0d pending_AR=%0d pending_R=%0d\n",
        "  pending_exp_W=%0d pending_obs_W=%0d\n",
        "  PASS=%0d  FAIL=%0d\n",
        "====================================="
      },
      n_req, n_rsp, n_rsp_final, n_rsp_matched_final,
      n_aw, n_ar, n_w, n_b, n_exp_b, n_r, n_exp_r,
      n_rsp_body_checked, n_exp_rsp_body,
      n_err_req, n_slverr, n_wrap, n_buf,
      count_pending_aw(), count_pending_ar(), count_pending_r(),
      exp_w_q.size(), obs_w_q.size(),
      n_pass, n_fail
    );
  
    `uvm_info("SB", summary, UVM_LOW)
  
  endfunction

endclass : axi_tniu_scoreboard

`endif // AXI_TNIU_SCOREBOARD_SV
