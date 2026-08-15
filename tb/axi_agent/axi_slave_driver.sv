// =============================================================================
// File        : axi_slave_driver.sv
// Description : AXI4 slave driver. Responds to the DUT's AXI master interface.
//               Features exercised by the verification plan:
//                 - AW/W capture into a byte-addressable memory model
//                 - AR handling with a backing-memory read
//                 - configurable response / beat delays
//                 - randomized BUSER/RUSER response attributes
//                 - configurable SLVERR/DECERR response injection
//                 - multiple outstanding transactions
//                 - out-of-order B/R responses across different IDs
//                 - read-data interleaving across different IDs
//                 - optional deterministic forced read-data interleaving
//                 - strict request-order preservation within each AXI ID
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_SLAVE_DRIVER_SV
`define AXI_SLAVE_DRIVER_SV

class axi_slave_driver extends uvm_driver #(axi_seq_item);
  `uvm_component_utils(axi_slave_driver)

  virtual axi_if vif;
  axi_tniu_cfg   cfg;

  // Sparse byte-addressable backing memory.
  byte unsigned mem[longint];

  // Read transactions and parallel scheduler state.
  axi_seq_item  rd_q[$];
  time          rd_first_ready_time[$];
  time          rd_next_beat_ready_time[$];
  int unsigned  rd_beat_index[$];
  bit           rd_started[$];

  // Independently captured AXI write channels.
  axi_seq_item  aw_q[$];
  axi_seq_item  w_q[$];
  time          aw_accept_time_q[$];
  time          wlast_accept_time_q[$];

  // Completed write requests waiting for B response.
  axi_seq_item  b_pending[$];
  time          b_ready_time[$];

  time axi_clk_period = 10ns;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "axi_if not set for axi_slave_driver")
    void'(uvm_config_db#(axi_tniu_cfg)::get(this, "", "cfg", cfg));
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      clear_transaction_state();
      init_outputs();
      wait (vif.aresetn === 1'b1);
      fork : slave_procs
        aw_channel();
        w_channel();
        write_matcher();
        measure_clk_period();
        ar_channel();
        r_engine();
        b_engine();
        @(negedge vif.aresetn);
      join_any
      disable slave_procs;
    end
  endtask

  function void clear_transaction_state();
    rd_q.delete();
    rd_first_ready_time.delete();
    rd_next_beat_ready_time.delete();
    rd_beat_index.delete();
    rd_started.delete();

    aw_q.delete();
    w_q.delete();
    aw_accept_time_q.delete();
    wlast_accept_time_q.delete();

    b_pending.delete();
    b_ready_time.delete();
  endfunction

  task measure_clk_period();
    time previous_edge;
    previous_edge = 0;
    forever begin
      @(vif.slv_cb);
      if (previous_edge != 0 && $time > previous_edge)
        axi_clk_period = $time - previous_edge;
      previous_edge = $time;
    end
  endtask

  function void init_outputs();
    vif.awready = 0;
    vif.wready  = 0;
    vif.arready = 0;

    vif.bvalid  = 0;
    vif.bid     = 0;
    vif.bresp   = 0;
    vif.buser   = 0;

    vif.rvalid  = 0;
    vif.rid     = 0;
    vif.rdata   = 0;
    vif.rresp   = 0;
    vif.ruser   = 0;
    vif.rlast   = 0;
  endfunction

  function bit slv_ready();
    if (cfg != null && cfg.axi_ready_bp_en)
      return ($urandom_range(0, 3) != 0);
    return 1'b1;
  endfunction

  function automatic logic [1:0] choose_axi_resp();
    if (cfg == null || !cfg.axi_error_rsp_en)
      return 2'b00;

    if ($urandom_range(99, 0) < cfg.axi_slverr_pct)
      return cfg.axi_error_resp;

    return 2'b00;
  endfunction

  function automatic logic [axi_tniu_protocol_pkg::AUSER_WITH-1:0]
    choose_axi_rsp_user();
    logic [axi_tniu_protocol_pkg::AUSER_WITH-1:0] user_value;

    if (cfg != null && !cfg.axi_rsp_user_random_en)
      return cfg.axi_rsp_user_fixed;

    user_value = $urandom;
    return user_value;
  endfunction

  // ---------------------------------------------------------------------------
  // AW channel
  // ---------------------------------------------------------------------------
  task aw_channel();
    bit rdy;

    forever begin
      rdy = slv_ready();
      vif.slv_cb.awready <= rdy;
      @(vif.slv_cb);

      if (rdy && vif.slv_cb.awvalid) begin
        axi_seq_item t;

        t = axi_seq_item::type_id::create("aw");
        t.dir   = AXI_WRITE;
        t.id    = vif.slv_cb.awid;
        t.addr  = vif.slv_cb.awaddr;
        t.len   = vif.slv_cb.awlen;
        t.size  = vif.slv_cb.awsize;
        t.burst = vif.slv_cb.awburst;
        t.cache = vif.slv_cb.awcache;

        aw_q.push_back(t);
        aw_accept_time_q.push_back($time);
      end
    end
  endtask

  // ---------------------------------------------------------------------------
  // W channel
  // ---------------------------------------------------------------------------
  task w_channel();
    bit                                    rdy;
    bit                                    have_id;
    axi_tniu_protocol_pkg::axi_id_t        burst_id;
    logic [63:0]                           data_q[$];
    logic [7:0]                            strb_q[$];

    have_id = 1'b0;

    forever begin
      rdy = slv_ready();
      vif.slv_cb.wready <= rdy;
      @(vif.slv_cb);

      if (rdy && vif.slv_cb.wvalid) begin
        if (!have_id) begin
          burst_id = vif.slv_cb.wid;
          have_id  = 1'b1;
        end
        else if (vif.slv_cb.wid !== burst_id) begin
          `uvm_error("AXI_WID", $sformatf(
            "WID changed within a write burst: first=0x%0h current=0x%0h",
            burst_id, vif.slv_cb.wid))
        end

        data_q.push_back(vif.slv_cb.wdata);
        strb_q.push_back(vif.slv_cb.wstrb);

        if (vif.slv_cb.wlast) begin
          axi_seq_item t;

          t = axi_seq_item::type_id::create("w");
          t.dir  = AXI_WRITE;
          t.id   = burst_id;
          t.len  = data_q.size() - 1;
          t.data = new[data_q.size()];
          t.strb = new[strb_q.size()];

          foreach (data_q[i])
            t.data[i] = data_q[i];
          foreach (strb_q[i])
            t.strb[i] = strb_q[i];

          w_q.push_back(t);
          wlast_accept_time_q.push_back($time);

          data_q.delete();
          strb_q.delete();
          have_id = 1'b0;
        end
      end
    end
  endtask

  // ---------------------------------------------------------------------------
  // AW/W matcher and B scheduling
  // ---------------------------------------------------------------------------
  task write_matcher();
    forever begin
      @(vif.slv_cb);

      while (aw_q.size() > 0 && w_q.size() > 0) begin
        axi_seq_item aw;
        axi_seq_item w;
        time         aw_accept_time;
        time         wlast_accept_time;
        time         request_complete_time;
        int unsigned response_delay;

        aw = aw_q.pop_front();
        w  = w_q.pop_front();

        aw_accept_time    = aw_accept_time_q.pop_front();
        wlast_accept_time = wlast_accept_time_q.pop_front();

        if (w.id !== aw.id) begin
          `uvm_error("AXI_WID", $sformatf(
            "AW/W FIFO pairing produced ID mismatch: AWID=0x%0h WID=0x%0h",
            aw.id, w.id))
        end

        if (w.data.size() != (int'(aw.len) + 1)) begin
          `uvm_error("AXI_WLEN", $sformatf(
            "AWID=0x%0h AWLEN=%0d expects=%0d W beats, got=%0d",
            aw.id, aw.len, int'(aw.len) + 1, w.data.size()))
        end

        foreach (w.data[beat]) begin
          for (int b = 0; b < 8; b++) begin
            if (w.strb[beat][b])
              mem[aw.addr + beat*8 + b] = w.data[beat][b*8 +: 8];
          end
        end

        request_complete_time =
          (aw_accept_time >= wlast_accept_time) ?
          aw_accept_time : wlast_accept_time;

        response_delay = get_resp_delay();
        aw.resp_delay  = response_delay;
        aw.resp        = choose_axi_resp();
        aw.user        = choose_axi_rsp_user();

        b_pending.push_back(aw);
        b_ready_time.push_back(
          request_complete_time + response_delay * axi_clk_period
        );
      end
    end
  endtask

  // ---------------------------------------------------------------------------
  // AR channel
  // ---------------------------------------------------------------------------
  task ar_channel();
    bit rdy;

    forever begin
      rdy = slv_ready();
      vif.slv_cb.arready <= rdy;
      @(vif.slv_cb);

      if (rdy && vif.slv_cb.arvalid) begin
        axi_seq_item t;
        int unsigned response_delay;

        t = axi_seq_item::type_id::create("ar");
        t.dir   = AXI_READ;
        t.id    = vif.slv_cb.arid;
        t.addr  = vif.slv_cb.araddr;
        t.len   = vif.slv_cb.arlen;
        t.size  = vif.slv_cb.arsize;
        t.burst = vif.slv_cb.arburst;

        response_delay = get_resp_delay();
        t.resp_delay   = response_delay;
        t.resp         = choose_axi_resp();
        t.user         = choose_axi_rsp_user();

        rd_q.push_back(t);
        rd_first_ready_time.push_back(
          $time + response_delay * axi_clk_period
        );
        rd_next_beat_ready_time.push_back(
          $time + response_delay * axi_clk_period
        );
        rd_beat_index.push_back(0);
        rd_started.push_back(1'b0);

        `uvm_info("AXI_R_SCHED", $sformatf(
          "Queue R id=0x%0h ready=%0t len=%0d",
          t.id,
          $time + response_delay * axi_clk_period,
          t.len),
          UVM_HIGH)
      end
    end
  endtask

  function bit is_oldest_write_for_id(int idx);
    if (idx < 0 || idx >= b_pending.size())
      return 1'b0;

    for (int i = 0; i < idx; i++) begin
      if (b_pending[i].id == b_pending[idx].id)
        return 1'b0;
    end

    return 1'b1;
  endfunction

  function bit is_oldest_read_for_id(int idx);
    if (idx < 0 || idx >= rd_q.size())
      return 1'b0;

    for (int i = 0; i < idx; i++) begin
      if (rd_q[i].id == rd_q[idx].id)
        return 1'b0;
    end

    return 1'b1;
  endfunction

  function automatic int unsigned get_resp_delay();
    if (cfg == null)
      return $urandom_range(5, 0);

    return $urandom_range(
      cfg.axi_min_resp_delay,
      cfg.axi_max_resp_delay
    );
  endfunction

  function automatic int unsigned get_beat_gap_delay();
    int unsigned min_gap;
    int unsigned max_gap;
    int unsigned gap_count;
    int unsigned total_weight;
    int unsigned ticket;
    int unsigned cumulative_weight;
    int unsigned weight;

    if (cfg == null)
      return $urandom_range(2, 0);

    min_gap = cfg.axi_min_beat_gap;
    max_gap = cfg.axi_max_beat_gap;

    if (min_gap >= max_gap)
      return min_gap;

    if ($urandom_range(99, 0) < 60)
      return min_gap;

    gap_count    = max_gap - min_gap;
    total_weight = gap_count * (gap_count + 1) / 2;
    ticket       = $urandom_range(total_weight, 1);

    cumulative_weight = 0;
    for (int unsigned gap = min_gap + 1; gap <= max_gap; gap++) begin
      weight = max_gap - gap + 1;
      cumulative_weight += weight;
      if (ticket <= cumulative_weight)
        return gap;
    end

    return max_gap;
  endfunction

  // ---------------------------------------------------------------------------
  // B engine
  // ---------------------------------------------------------------------------
  task b_engine();
    int eligible_idx[$];

    forever begin
      @(vif.slv_cb);

      if (b_pending.size() > 0) begin
        int          selected_pos;
        int          selected_idx;
        axi_seq_item t;

        if (b_pending.size() != b_ready_time.size())
          `uvm_fatal("AXI_B_SCHED", "B queue/state size mismatch")

        eligible_idx.delete();

        if (cfg == null || !cfg.axi_ooo_en) begin
          if (b_ready_time[0] <= $time)
            eligible_idx.push_back(0);
        end
        else begin
          foreach (b_pending[i]) begin
            if (b_ready_time[i] <= $time && is_oldest_write_for_id(i))
              eligible_idx.push_back(i);
          end
        end

        if (eligible_idx.size() == 0)
          continue;

        selected_pos =
          (cfg != null && cfg.axi_ooo_en && eligible_idx.size() > 1) ?
          $urandom_range(0, eligible_idx.size()-1) : 0;

        selected_idx = eligible_idx[selected_pos];
        t            = b_pending[selected_idx];

        b_pending.delete(selected_idx);
        b_ready_time.delete(selected_idx);

        vif.slv_cb.bvalid <= 1'b1;
        vif.slv_cb.bid    <= t.id;
        vif.slv_cb.bresp  <= t.resp;
        vif.slv_cb.buser  <= t.user;

        do @(vif.slv_cb); while (!vif.slv_cb.bready);

        vif.slv_cb.bvalid <= 1'b0;
      end
    end
  endtask

  // ---------------------------------------------------------------------------
  // R engine
  //
  // Normal mode:
  //   preserves the repository's existing randomized OOO/interleave policy.
  //
  // Forced mode (cfg.axi_force_interleave_en=1):
  //   * requires cfg.axi_interleave_en=1 (checked by cfg.validate());
  //   * when another different RID is already outstanding, waits for that RID
  //     to mature instead of repeatedly serving the current RID;
  //   * if multiple IDs are eligible, excludes the previously accepted RID
  //     whenever possible;
  //   * selects the next RID with deterministic circular round-robin fairness.
  //
  // This guarantees beat-by-beat interleaving for a directed test that keeps
  // multiple different-ID read bursts outstanding. AXI same-ID ordering remains
  // legal because is_oldest_read_for_id() is always applied.
  // ---------------------------------------------------------------------------
  task r_engine();
    int eligible_idx[$];
    bit r_beat_active;
    int active_idx;

    bit burst_lock_valid;
    int burst_lock_idx;

    bit force_last_rid_valid;
    axi_tniu_protocol_pkg::axi_id_t force_last_rid;
    axi_tniu_protocol_pkg::axi_id_t force_rr_next_rid;

    r_beat_active       = 1'b0;
    active_idx          = -1;
    burst_lock_valid    = 1'b0;
    burst_lock_idx      = -1;
    force_last_rid_valid= 1'b0;
    force_last_rid      = '0;
    force_rr_next_rid   = '0;

    forever begin
      @(vif.slv_cb);

      // A presented beat must remain unchanged until accepted.
      if (r_beat_active) begin
        axi_tniu_protocol_pkg::axi_id_t accepted_rid;

        if (!vif.slv_cb.rready)
          continue;

        if (active_idx < 0 || active_idx >= rd_q.size()) begin
          `uvm_fatal("AXI_R_SCHED", $sformatf(
            "Active R index out of range: index=%0d queue_size=%0d",
            active_idx, rd_q.size()))
        end

        accepted_rid = rd_q[active_idx].id;

        if (cfg != null && cfg.axi_force_interleave_en) begin
          force_last_rid_valid = 1'b1;
          force_last_rid       = accepted_rid;
          force_rr_next_rid    =
            axi_tniu_protocol_pkg::axi_id_t'(accepted_rid + 1'b1);
        end

        if (rd_beat_index[active_idx] >= int'(rd_q[active_idx].len)) begin
          // RLAST completed the transaction.
          rd_q.delete(active_idx);
          rd_first_ready_time.delete(active_idx);
          rd_next_beat_ready_time.delete(active_idx);
          rd_beat_index.delete(active_idx);
          rd_started.delete(active_idx);

          if (burst_lock_valid) begin
            burst_lock_valid = 1'b0;
            burst_lock_idx   = -1;
          end
        end
        else begin
          int unsigned beat_gap;

          beat_gap = get_beat_gap_delay();
          rd_beat_index[active_idx]++;
          rd_next_beat_ready_time[active_idx] =
            $time + beat_gap * axi_clk_period;
        end

        r_beat_active = 1'b0;
        active_idx    = -1;
        vif.slv_cb.rvalid <= 1'b0;
        vif.slv_cb.rlast  <= 1'b0;
      end

      if (rd_q.size() != rd_first_ready_time.size() ||
          rd_q.size() != rd_next_beat_ready_time.size() ||
          rd_q.size() != rd_beat_index.size() ||
          rd_q.size() != rd_started.size()) begin
        `uvm_fatal("AXI_R_SCHED", $sformatf(
          "R queue size mismatch: req=%0d first=%0d next=%0d beat=%0d started=%0d",
          rd_q.size(),
          rd_first_ready_time.size(),
          rd_next_beat_ready_time.size(),
          rd_beat_index.size(),
          rd_started.size()))
      end

      if (rd_q.size() == 0)
        continue;

      // -----------------------------------------------------------------------
      // Build the legal eligible set exactly as in the normal scheduler.
      // -----------------------------------------------------------------------
      eligible_idx.delete();

      if (cfg == null || !cfg.axi_interleave_en) begin
        if (burst_lock_valid) begin
          if (burst_lock_idx >= rd_q.size())
            `uvm_fatal("AXI_R_SCHED", "Locked R index out of range")

          if (rd_next_beat_ready_time[burst_lock_idx] <= $time)
            eligible_idx.push_back(burst_lock_idx);
        end
        else if (cfg == null || !cfg.axi_ooo_en) begin
          if (rd_next_beat_ready_time[0] <= $time &&
              is_oldest_read_for_id(0))
            eligible_idx.push_back(0);
        end
        else begin
          foreach (rd_q[i]) begin
            if (rd_next_beat_ready_time[i] <= $time &&
                is_oldest_read_for_id(i))
              eligible_idx.push_back(i);
          end
        end
      end
      else if (cfg == null || !cfg.axi_ooo_en) begin
        int first_unstarted_idx;

        first_unstarted_idx = -1;

        foreach (rd_q[i]) begin
          if (!rd_started[i] && first_unstarted_idx < 0)
            first_unstarted_idx = i;

          if (rd_started[i] &&
              rd_next_beat_ready_time[i] <= $time &&
              is_oldest_read_for_id(i))
            eligible_idx.push_back(i);
        end

        if (first_unstarted_idx >= 0 &&
            rd_next_beat_ready_time[first_unstarted_idx] <= $time &&
            is_oldest_read_for_id(first_unstarted_idx))
          eligible_idx.push_back(first_unstarted_idx);
      end
      else begin
        foreach (rd_q[i]) begin
          if (rd_next_beat_ready_time[i] <= $time &&
              is_oldest_read_for_id(i))
            eligible_idx.push_back(i);
        end
      end

      if (eligible_idx.size() > 0) begin
        int selected_idx;

        // ---------------------------------------------------------------------
        // Forced deterministic interleaving.
        // ---------------------------------------------------------------------
        if (cfg != null && cfg.axi_force_interleave_en) begin
          bit have_alt_eligible;
          bit other_id_pending;
          int best_distance;
          int rid_space;

          have_alt_eligible = 1'b0;
          other_id_pending  = 1'b0;
          selected_idx      = -1;

          // Is there a currently eligible RID different from the last accepted
          // beat's RID?
          if (force_last_rid_valid) begin
            foreach (eligible_idx[p]) begin
              if (rd_q[eligible_idx[p]].id != force_last_rid)
                have_alt_eligible = 1'b1;
            end
          end

          // If the only currently runnable choice would violate the forced
          // alternation, but a different RID is already outstanding and simply
          // has not reached its ready time yet, wait for it instead of allowing
          // the current RID to run ahead.
          foreach (rd_q[i]) begin
            if (is_oldest_read_for_id(i)) begin
              if (!force_last_rid_valid) begin
                // Before the first beat, if only one RID is mature while another
                // different RID is already queued, wait so interleaving starts
                // from the first response beat.
                if (eligible_idx.size() == 1 &&
                    rd_q[i].id != rd_q[eligible_idx[0]].id)
                  other_id_pending = 1'b1;
              end
              else if (rd_q[i].id != force_last_rid) begin
                other_id_pending = 1'b1;
              end
            end
          end

          if (!force_last_rid_valid &&
              eligible_idx.size() == 1 &&
              other_id_pending) begin
            continue;
          end

          if (force_last_rid_valid &&
              !have_alt_eligible &&
              other_id_pending) begin
            continue;
          end

          // Circular RID round-robin.  If another RID is eligible, explicitly
          // exclude the previously accepted RID. This prevents A,A,B patterns
          // and produces A,B,C,D,A,B,C,D... for the directed rwrap test.
          rid_space     = (1 << axi_tniu_protocol_pkg::AXID_WITH);
          best_distance = rid_space + 1;

          foreach (eligible_idx[p]) begin
            int idx;
            int candidate_rid;
            int next_rid;
            int distance;

            idx = eligible_idx[p];

            if (force_last_rid_valid &&
                have_alt_eligible &&
                rd_q[idx].id == force_last_rid)
              continue;

            candidate_rid = int'(rd_q[idx].id);
            next_rid      = int'(force_rr_next_rid);
            distance      = candidate_rid - next_rid;
            if (distance < 0)
              distance += rid_space;

            if (selected_idx < 0 || distance < best_distance) begin
              selected_idx  = idx;
              best_distance = distance;
            end
          end

          if (selected_idx < 0)
            selected_idx = eligible_idx[0];

          `uvm_info("AXI_R_FORCE_INTLV", $sformatf(
            "force-select RID=0x%0h beat=%0d/%0d eligible=%0d last_valid=%0b last=0x%0h",
            rd_q[selected_idx].id,
            rd_beat_index[selected_idx],
            rd_q[selected_idx].len,
            eligible_idx.size(),
            force_last_rid_valid,
            force_last_rid),
            UVM_HIGH)
        end
        else begin
          int selected_pos;

          selected_pos =
            ((cfg != null) &&
             (cfg.axi_ooo_en || cfg.axi_interleave_en) &&
             eligible_idx.size() > 1) ?
            $urandom_range(0, eligible_idx.size()-1) : 0;

          selected_idx = eligible_idx[selected_pos];
        end

        if (cfg == null || !cfg.axi_interleave_en) begin
          if (!burst_lock_valid) begin
            burst_lock_valid = 1'b1;
            burst_lock_idx   = selected_idx;
          end
        end

        rd_started[selected_idx] = 1'b1;
        active_idx               = selected_idx;
        r_beat_active            = 1'b1;

        vif.slv_cb.rvalid <= 1'b1;
        vif.slv_cb.rid    <= rd_q[selected_idx].id;
        vif.slv_cb.rdata  <= read_mem(
          rd_q[selected_idx].addr + rd_beat_index[selected_idx] * 8
        );
        vif.slv_cb.rresp  <= rd_q[selected_idx].resp;
        vif.slv_cb.ruser  <= rd_q[selected_idx].user;
        vif.slv_cb.rlast  <=
          (rd_beat_index[selected_idx] >= int'(rd_q[selected_idx].len));
      end
    end
  endtask

  function logic [63:0] read_mem(longint a);
    logic [63:0] d;

    for (int b = 0; b < 8; b++) begin
      if (mem.exists(a+b))
        d[b*8 +: 8] = mem[a+b];
      else
        d[b*8 +: 8] = (a+b) & 8'hff;
    end

    return d;
  endfunction

endclass : axi_slave_driver

`endif // AXI_SLAVE_DRIVER_SV
