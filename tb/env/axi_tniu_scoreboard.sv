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

  // Pending SLVERR/DECERR flags captured on B/R and consumed at final RKNP rsp.
  bit err_pending [axi_tniu_protocol_pkg::axi_id_t][$];

  // ---------------------------------------------------------------------------
  // Statistics
  // ---------------------------------------------------------------------------
  int unsigned n_req, n_rsp, n_rsp_final, n_rsp_matched_final;
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
      exp_w_q.push_back(e);
      try_match_w();
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
  // AXI B: capture SLVERR/DECERR for error upgrade
  // ===========================================================================
  function void write_b(axi_seq_item t);
    if (!cfg.checks_enable)
      return;

    n_b++;

    if (t.resp == 2'b10 || t.resp == 2'b11) begin
      n_slverr++;
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
    if (!cfg.checks_enable)
      return;

    n_r++;

    if (t.resp == 2'b10 || t.resp == 2'b11) begin
      n_slverr++;
      err_pending[t.id].push_back(1);
    end
    else begin
      err_pending[t.id].push_back(0);
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

    // ST_CONT belongs to the transaction at the queue head but does not finish
    // it. Only a final ST_OK/ST_ERR response removes the expectation.
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

    // C-CONV-01: response opcode
    if (e.rsp_opc !== t.rsp_opc) begin
      `uvm_error("C-CONV-01", $sformatf(
        " No.%0d rsp opc exp=%s got=%s",
        e.txn_no, e.rsp_opc.name(), t.rsp_opc.name()))
      n_fail++;
      check_pass = 0;
    end

    // Intermediate response packet: LW=0 means this RKNP transaction still
    // has response flits to come, regardless of ST_OK/ST_CONT.
    if (t.rsp_lw == 1'b0) begin
      if (check_pass)
        n_pass++;
      return;
    end

    // Final response: remove expectation.
    void'(exp_rsp_q[key].pop_front());
    n_rsp_matched_final++;

    if (exp_rsp_q[key].size() == 0)
      exp_rsp_q.delete(key);

    // C-ERR-02: ERR request must reflect the predicted error.
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
    else begin
      // Non-error request: expected OK unless AXI completion forced an upgrade.
      if (err_pending.exists(e.axid) && err_pending[e.axid].size() > 0)
        upgraded = err_pending[e.axid].pop_front();

      if (err_pending.exists(e.axid) && err_pending[e.axid].size() == 0)
        err_pending.delete(e.axid);

      if (upgraded &&
          t.rsp_status !== axi_tniu_protocol_pkg::ST_ERR) begin
        `uvm_warning("C-ERR-02", $sformatf(
          " No.%0d AXI SLVERR on AxID=%0h but RKNP status=%s",
          e.txn_no, e.axid, t.rsp_status.name()))
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
  endfunction

  // True only after every predicted response/address/data completion has been
  // observed.  Bufferable writes require this extra AXI-side drain because
  // their RKNP early response legitimately precedes the real B response.
  function bit traffic_drained();
    if ((n_b < n_exp_b) || (n_r < n_exp_r) ||
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

  function void report_phase(uvm_phase phase);
    string summary;
  
    super.report_phase(phase);
  
    summary = $sformatf(
      {
        "\n==== axi_tniu scoreboard summary ====\n",
        "  REQ=%0d  RSP_PKT=%0d  RSP_FINAL(raw/matched)=%0d/%0d\n",
        "  AW=%0d AR=%0d W=%0d B=%0d/%0d R=%0d/%0d\n",
        "  ERR_req=%0d  AXI_SLVERR=%0d  WRAP=%0d  BUFFERABLE=%0d\n",
        "  pending_AW=%0d pending_AR=%0d\n",
        "  pending_exp_W=%0d pending_obs_W=%0d\n",
        "  PASS=%0d  FAIL=%0d\n",
        "====================================="
      },
      n_req, n_rsp, n_rsp_final, n_rsp_matched_final,
      n_aw, n_ar, n_w, n_b, n_exp_b, n_r, n_exp_r,
      n_err_req, n_slverr, n_wrap, n_buf,
      count_pending_aw(), count_pending_ar(),
      exp_w_q.size(), obs_w_q.size(),
      n_pass, n_fail
    );
  
    `uvm_info("SB", summary, UVM_LOW)
  
  endfunction

endclass : axi_tniu_scoreboard

`endif // AXI_TNIU_SCOREBOARD_SV
