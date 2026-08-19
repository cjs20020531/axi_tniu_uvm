// =============================================================================
// File        : rknp_driver.sv
// Description : RKNP request-channel driver (HeadPenalty = 0).
//               Packs an rknp_seq_item into a REQ flit using rknp_pkg field
//               offsets and streams it: head+first body word on the same cycle,
//               subsequent body words, tail asserted on the last body word.
//               Request packet gap is controlled by cfg.req_min_gap/max_gap:
//                 gap=0 -> packet-level B2B when next item is ready
//                 gap=N -> insert N idle cycles between TAIL and next HEAD
//               Also keeps txrsp_ready driven (default accept, random stall).
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef RKNP_DRIVER_SV
`define RKNP_DRIVER_SV

class rknp_driver extends uvm_driver #(rknp_seq_item);
  `uvm_component_utils(rknp_driver)

  virtual rknp_if  vif;
  axi_tniu_cfg     cfg;
  rknp_txn_tag_mgr tag_mgr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual rknp_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "rknp_if not set for rknp_driver")
    void'(uvm_config_db#(axi_tniu_cfg)::get(this, "", "cfg", cfg));

    if (!uvm_config_db#(rknp_txn_tag_mgr)::get(this,"","tag_mgr",tag_mgr))
      `uvm_fatal("RKNP_DRV", "rknp_txn_tag_mgr not found")
  endfunction

  // Two parallel jobs: drive requests, and keep the response ready line moving.
  task run_phase(uvm_phase phase);
    fork
      reset_and_drive();
      rsp_ready_gen();
    join
  endtask

  task reset_and_drive();
    forever begin
      // Hold the request channel idle during reset.
      vif.rxreq_valid <= 1'b0;
      vif.rxreq_head  <= 1'b0;
      vif.rxreq_tail  <= 1'b0;
      vif.rxreq_data  <= '0;

      if (!vif.aresetn)
        @(posedge vif.aresetn);

      drive_loop();  // returns if reset re-asserts
    end
  endtask

  // ---------------------------------------------------------------------------
  // Request gap definition:
  //
  //   previous TAIL handshake @ cycle N
  //
  //   gap=0 : next HEAD may handshake @ cycle N+1
  //   gap=1 : cycle N+1 idle, next HEAD may handshake @ cycle N+2
  //   gap=K : exactly K driver-inserted idle cycles
  //
  // If the sequence does not provide the next item in time, the real gap can
  // be larger than the selected value. The driver never sends a nonexistent
  // transaction.
  // ---------------------------------------------------------------------------
  function automatic int unsigned choose_req_gap();
    int unsigned min_gap;
    int unsigned max_gap;

    if (cfg == null)
      return 0;

    min_gap = cfg.req_min_gap;
    max_gap = cfg.req_max_gap;

    if (min_gap > max_gap) begin
      `uvm_fatal("RKNP_DRV_GAP",
                 $sformatf("req_min_gap(%0d) > req_max_gap(%0d)",
                           min_gap, max_gap))
      return 0;
    end

    if (min_gap == max_gap)
      return min_gap;

    return $urandom_range(max_gap, min_gap);
  endfunction

  task drive_req_idle();
    vif.drv_cb.rxreq_valid <= 1'b0;
    vif.drv_cb.rxreq_head  <= 1'b0;
    vif.drv_cb.rxreq_tail  <= 1'b0;
  endtask

  task drive_loop();
    int unsigned gap_cycles;

    if (!vif.aresetn)
      return;

    // First item can arrive at an arbitrary simulation phase, so synchronize
    // before presenting its first flit.
    seq_item_port.get_next_item(req);
    send_packet(req, 1'b1);
    seq_item_port.item_done();

    if (!vif.aresetn)
      return;

    forever begin
      gap_cycles = choose_req_gap();

      `uvm_info("RKNP_DRV_GAP",
                $sformatf("request gap=%0d cycle(s), cfg range=[%0d:%0d]",
                          gap_cycles,
                          (cfg == null) ? 0 : cfg.req_min_gap,
                          (cfg == null) ? 0 : cfg.req_max_gap),
                UVM_HIGH)

      // Insert the configured idle cycles.  send_packet() returned immediately
      // after the previous TAIL handshake, so these are packet-to-packet gaps.
      if (gap_cycles > 0) begin
        drive_req_idle();

        repeat (gap_cycles) begin
          @(vif.drv_cb);
          if (!vif.aresetn)
            return;
        end
      end

      // At the configured launch point, first try to obtain an already-ready
      // item without adding another clock.
      //
      // For gap=0 this is the B2B path:
      //   TAIL accepted at cycle N
      //   next HEAD driven from the same drv_cb event
      //   next HEAD can be accepted at cycle N+1
      req = null;
      seq_item_port.try_next_item(req);

      if (req != null) begin
        send_packet(req, 1'b0);
        seq_item_port.item_done();

        if (!vif.aresetn)
          return;

        continue;
      end

      // No request was available at the requested launch time.  Stay idle,
      // block until a new item arrives, then re-synchronize because it may
      // arrive at any simulation phase.
      drive_req_idle();

      seq_item_port.get_next_item(req);
      send_packet(req, 1'b1);
      seq_item_port.item_done();

      if (!vif.aresetn)
        return;
    end
  endtask

  // ---- pack + stream one request packet -------------------------------------
  //
  // sync_before_first=1:
  //   item arrived at an arbitrary phase; enter drv_cb before first flit.
  //
  // sync_before_first=0:
  //   drive_loop is already at a safe drv_cb launch point.  This avoids one
  //   extra clock and enables packet-level B2B when gap=0.
  // ---------------------------------------------------------------------------
  task send_packet(rknp_seq_item it, bit sync_before_first);
    logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] head_flit, flit;
    int nword;

    build_head_flit(it, head_flit);

    // Reads are HEAD-ONLY (1 flit: head+tail+valid for one cycle).
    // Only writes carry body data words (ceil(bytes / NBYTEPERWORD) flits).
    nword = it.is_write()
          ? (it.wr_bytes.size() + axi_tniu_protocol_pkg::NBYTEPERWORD - 1)
            / axi_tniu_protocol_pkg::NBYTEPERWORD
          : 1;

    if (nword == 0)
      nword = 1;

    // A sequence item may reach the driver at any simulation phase.  The normal
    // first-item / late-item path synchronizes here.  The configured gap/B2B
    // path is already at drv_cb and skips this extra clock.
    if (sync_before_first) begin
      @(vif.drv_cb);
      if (!vif.aresetn)
        return;
    end

    for (int w = 0; w < nword; w++) begin
      // Per RKNP: head fields are held on every flit; only body data changes.
      flit = head_flit;
      if (it.is_write())
        pack_body_word(it, w, flit);

      vif.drv_cb.rxreq_valid <= 1'b1;
      vif.drv_cb.rxreq_head  <= (w == 0);
      vif.drv_cb.rxreq_tail  <= (w == nword-1);
      vif.drv_cb.rxreq_data  <= flit;

      if (w == 0) begin
        req.txn_no = tag_mgr.alloc_request(
          req.iid,
          req.tid,
          req.orderkey,
          req.opc,
          req.status
        );

        `uvm_info(
          "RKNP_DRV_TX_PACKET",
          $sformatf(
            " No.%0d\n%s",
            req.txn_no,
            it.convert2string()
          ),
          UVM_MEDIUM
        )
      end

      // Hold the flit until accepted.
      do begin
        @(vif.drv_cb);

        if (!vif.aresetn) begin
          vif.drv_cb.rxreq_valid <= 1'b0;
          vif.drv_cb.rxreq_head  <= 1'b0;
          vif.drv_cb.rxreq_tail  <= 1'b0;
          vif.drv_cb.rxreq_data  <= '0;
          return;
        end
      end while (!vif.drv_cb.rxreq_ready);

      // Accepted at this edge.  Next body flit, if any, is driven immediately.
    end

    // Do NOT force idle here.
    //
    // drive_loop() owns the packet boundary:
    //   gap>0                -> drive_req_idle() + wait gap cycles
    //   gap=0 + next ready   -> immediately drive next HEAD (true B2B)
    //   gap=0 + next absent  -> drive_req_idle() while waiting
  endtask

  // ---- build the head flit from item fields ---------------------------------
  function void build_head_flit(rknp_seq_item it,
                                ref logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] f);
    f = '0;
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_URGE_OFFSET,  axi_tniu_protocol_pkg::URGE_WITH,
                        axi_tniu_protocol_pkg::qos2urg(it.qos));
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_SUBR_OFFSET,  axi_tniu_protocol_pkg::SUBR_WITH,   it.subr);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_IID_OFFSET,   axi_tniu_protocol_pkg::IID_WITH,    it.iid);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_TID_OFFSET,   axi_tniu_protocol_pkg::TID_WITH,    it.tid);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_ORDKEY_OFFSET,axi_tniu_protocol_pkg::ORDKEY_WITH, it.orderkey);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_OPC_OFFSET,   4,                     it.opc);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_STATUS_OFFSET,2,                     it.status);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_LEN_OFFSET,   axi_tniu_protocol_pkg::LEN_WITH,    it.len);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_ADDR_OFFSET,  axi_tniu_protocol_pkg::ADDR_WITH,   it.addr);
    // USER is composed from its sub-fields (axcache[0] carries bufferable)
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_USER_OFFSET,  axi_tniu_protocol_pkg::USER_WITH, it.user);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_ERRC_OFFSET,  3,                     it.errcode);
  endfunction

  // ---- pack one 64-bit body word (write data) into a flit -------------------
  function void pack_body_word(rknp_seq_item it, int w,
                               ref logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] f);
    int base = axi_tniu_protocol_pkg::REQ_HEAD_LEN_OFFSET;
    int last_word = (it.wr_bytes.size() + axi_tniu_protocol_pkg::NBYTEPERWORD - 1)
                    / axi_tniu_protocol_pkg::NBYTEPERWORD - 1;

    f[base] = (w == last_word);

    for (int b = 0; b < axi_tniu_protocol_pkg::NBYTEPERWORD; b++) begin
      int idx  = w*axi_tniu_protocol_pkg::NBYTEPERWORD + b;
      int boff = base + 1 + b*9;

      if (idx < it.wr_bytes.size()) begin
        f[boff]        = it.wr_be[idx];
        f[boff+1 +: 8] = it.wr_bytes[idx];
      end
    end
  endfunction

  // ---- keep the response ready line active (existing behavior preserved) ----
  task rsp_ready_gen();
    forever begin
      if (!vif.aresetn) begin
        vif.txrsp_ready <= 1'b0;
        @(posedge vif.aclk);
        continue;
      end

      if (cfg != null && cfg.rsp_ready_bp_en)
        vif.txrsp_ready <= ($urandom_range(0,9) != 0);
      else
        vif.txrsp_ready <= 1'b1;

      @(posedge vif.aclk);
    end
  endtask

endclass : rknp_driver

`endif // RKNP_DRIVER_SV
