// =============================================================================
// File        : axi_slave_driver.sv
// Description : AXI4 slave driver. Responds to the DUT's AXI master interface.
//               Features exercised by the verification plan:
//                 - AW/W capture into a byte-addressable memory model
//                 - AR handling with a backing-memory read
//                 - configurable AxREADY / response / beat delays
//                 - randomized BUSER/RUSER response attributes
//                 - configurable SLVERR/DECERR response injection
//                 - multiple outstanding transactions
//                 - out-of-order B/R responses across different IDs
//                 - read-data interleaving across different IDs
//                 - strict request-order preservation within each AXI ID
//               Error injection is disabled by default; response USER
//               randomization is enabled by default through axi_tniu_cfg.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_SLAVE_DRIVER_SV
`define AXI_SLAVE_DRIVER_SV

class axi_slave_driver extends uvm_driver #(axi_seq_item);
  `uvm_component_utils(axi_slave_driver)

  virtual axi_if vif;
  axi_tniu_cfg   cfg;

  // simple sparse memory (byte addressable)
  byte unsigned mem[longint];

  // Independently captured channel transactions.
  //
  // AW and W are independent AXI channels. In particular, a complete W burst
  // may be accepted before its AW transfer. Keep separate FIFO queues and pair
  // them only after both sides are available; never wait for AW from inside the
  // W-handshake path.
  axi_seq_item  rd_q[$];
  time          rd_first_ready_time[$];
  time          rd_next_beat_ready_time[$];
  int unsigned  rd_beat_index[$];
  bit           rd_started[$];
  axi_seq_item  aw_q[$];
  axi_seq_item  w_q[$];
  time          aw_accept_time_q[$];
  time          wlast_accept_time_q[$];

  // Write transactions whose AW and W sides have both completed.  Every entry
  // owns an absolute ready time, so all response delays elapse in parallel.
  // The B channel itself is still driven by one scheduler because AXI has only
  // one set of BVALID/BID/BRESP signals.
  axi_seq_item  b_pending[$];
  time          b_ready_time[$];

  // Measured clock period used to convert the configured cycle delay into an
  // absolute response-ready time.  The default matches tb_top and is updated
  // continuously, so changing the testbench clock does not require this driver
  // to be edited.
  time          axi_clk_period = 10ns;

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
      init_outputs();                 // drive ALL outputs to known 0 (also during reset)
      wait (vif.aresetn === 1'b1);    // proceed once reset is de-asserted
      fork : slave_procs
        aw_channel();      // accept write address
        w_channel();       // independently accept complete write-data bursts
        write_matcher();   // pair captured AW and W, then schedule B
        measure_clk_period();
        ar_channel();      // accept read address
        r_engine();        // generate read data (with OOO + interleave)
        b_engine();        // generate write responses (with OOO)
        @(negedge vif.aresetn);   // reset re-asserted -> fall through and re-init
      join_any
      disable slave_procs;          // kill channels; loop re-drives outputs to 0
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
    vif.awready = 0; vif.wready = 0; vif.arready = 0;
    vif.bvalid  = 0; vif.bid = 0; vif.bresp = 0; vif.buser = 0;
    vif.rvalid  = 0; vif.rid = 0; vif.rdata = 0; vif.rresp = 0; vif.ruser = 0;
    vif.rlast   = 0;
  endfunction

  // Ready value to drive this cycle: HIGH by default (always accept). Random
  // stalls are inserted ONLY when back-pressure testing is enabled in cfg.
  function bit slv_ready();
    if (cfg != null && cfg.axi_ready_bp_en)
      return ($urandom_range(0,3) != 0);   // ~75% ready when exercising back-pressure
    return 1'b1;                            // default: ready always high
  endfunction

  // Select the AXI response once per transaction.  For a read, this function
  // is called when AR handshakes, before beat zero is scheduled.  Therefore an
  // injected error is visible on the first R beat and the saved transaction
  // value is reused unchanged through RLAST.  Never randomize RRESP per beat.
  function automatic logic [1:0] choose_axi_resp();
    if (cfg == null || !cfg.axi_error_rsp_en)
      return 2'b00;

    if ($urandom_range(99, 0) < cfg.axi_slverr_pct)
      return cfg.axi_error_resp;

    return 2'b00;
  endfunction

  // Randomize BUSER/RUSER once per response transaction.  For directed tests,
  // cfg can disable randomization and provide axi_rsp_user_fixed instead.
  function automatic logic [axi_tniu_protocol_pkg::AUSER_WITH-1:0]
    choose_axi_rsp_user();
    logic [axi_tniu_protocol_pkg::AUSER_WITH-1:0] user_value;

    if (cfg != null && !cfg.axi_rsp_user_random_en)
      return cfg.axi_rsp_user_fixed;

    user_value = $urandom;
    return user_value;
  endfunction

  // ---- AW : accept write address (ready HIGH by default) --------------------
  task aw_channel();
    bit rdy;
    forever begin
      rdy = slv_ready();
      vif.slv_cb.awready <= rdy;
      @(vif.slv_cb);
      if (rdy && vif.slv_cb.awvalid) begin      // handshake this cycle
        axi_seq_item t = axi_seq_item::type_id::create("aw");
        t.dir=AXI_WRITE; t.id=vif.slv_cb.awid; t.addr=vif.slv_cb.awaddr;
        t.len=vif.slv_cb.awlen; t.size=vif.slv_cb.awsize;
        t.burst=vif.slv_cb.awburst; t.cache=vif.slv_cb.awcache;
        aw_q.push_back(t);
        aw_accept_time_q.push_back($time);
      end
    end
  endtask

  // ---- W : independently capture one complete data burst --------------------
  //
  // Do not look at aw_q here. WREADY is independent of AWREADY, and every
  // accepted W beat must be recorded immediately even when no AW has arrived.
  task w_channel();
    bit                                    rdy;
    bit                                    have_id = 1'b0;
    axi_tniu_protocol_pkg::axi_id_t        burst_id;
    logic [63:0]                           data_q[$];
    logic [7:0]                            strb_q[$];

    forever begin
      rdy = slv_ready();
      vif.slv_cb.wready <= rdy;
      @(vif.slv_cb);

      if (rdy && vif.slv_cb.wvalid) begin       // handshake this cycle
        if (!have_id) begin
          burst_id = vif.slv_cb.wid;
          have_id  = 1'b1;
        end
        else if (vif.slv_cb.wid !== burst_id) begin
          `uvm_error(
            "AXI_WID",
            $sformatf(
              "WID changed within a write burst: first=0x%0h current=0x%0h",
              burst_id,
              vif.slv_cb.wid
            )
          )
        end

        data_q.push_back(vif.slv_cb.wdata);
        strb_q.push_back(vif.slv_cb.wstrb);

        if (vif.slv_cb.wlast) begin
          axi_seq_item t = axi_seq_item::type_id::create("w");

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

  // ---- AW/W matcher : pair independent channel captures in AXI order --------
  //
  // AXI4 does not permit write-data interleaving, so completed W bursts are
  // paired with accepted AW transactions in FIFO order. The WID check is kept
  // because this interface exposes WID and it makes a channel-ordering bug
  // immediately visible.
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
          `uvm_error(
            "AXI_WID",
            $sformatf(
              {
                "AW/W FIFO pairing produced an ID mismatch: ",
                "AWID=0x%0h WID=0x%0h AWADDR=0x%010h"
              },
              aw.id,
              w.id,
              aw.addr
            )
          )
        end

        if (w.data.size() != (int'(aw.len) + 1)) begin
          `uvm_error(
            "AXI_WLEN",
            $sformatf(
              {
                "Write burst beat-count mismatch: ",
                "AWID=0x%0h AWADDR=0x%010h AWLEN=%0d expects=%0d got=%0d"
              },
              aw.id,
              aw.addr,
              aw.len,
              int'(aw.len) + 1,
              w.data.size()
            )
          )
        end

        // Preserve the existing byte-addressable backing-store behaviour.
        foreach (w.data[beat]) begin
          for (int b = 0; b < 8; b++) begin
            if (w.strb[beat][b])
              mem[aw.addr + beat*8 + b] = w.data[beat][b*8 +: 8];
          end
        end

        // Both sides are now complete.  Start this request's response delay at
        // max(AW handshake, WLAST handshake), independently of every other
        // outstanding write.  Storing an absolute deadline avoids the old
        // serial behaviour in which N writes waited N*resp_delay cycles.
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

        `uvm_info(
          "AXI_B_SCHED",
          $sformatf(
            {
              "Queue B id=0x%0h request_complete=%0t ",
              "delay=%0d cycles ready_time=%0t resp=%02b user=0x%0h"
            },
            aw.id,
            request_complete_time,
            response_delay,
            request_complete_time + response_delay * axi_clk_period,
            aw.resp,
            aw.user
          ),
          UVM_HIGH
        )
      end
    end
  endtask

  // ---- AR : accept read address (ready HIGH by default) ---------------------
  task ar_channel();
    bit rdy;
    forever begin
      rdy = slv_ready();
      vif.slv_cb.arready <= rdy;
      @(vif.slv_cb);
      if (rdy && vif.slv_cb.arvalid) begin      // handshake this cycle
        axi_seq_item t = axi_seq_item::type_id::create("ar");
        int unsigned response_delay;

        t.dir=AXI_READ; t.id=vif.slv_cb.arid; t.addr=vif.slv_cb.araddr;
        t.len=vif.slv_cb.arlen; t.size=vif.slv_cb.arsize;
        t.burst=vif.slv_cb.arburst;
        response_delay = get_resp_delay();
        t.resp_delay   = response_delay;
        // Decide the whole burst's response now. If this is SLVERR/DECERR,
        // beat zero and every subsequent beat through RLAST carry that error.
        t.resp         = choose_axi_resp();
        t.user         = choose_axi_rsp_user();

        // Every AR owns an independent first-response deadline.  Do not wait
        // for an earlier read burst to finish before starting this delay.
        rd_q.push_back(t);
        rd_first_ready_time.push_back(
          $time + response_delay * axi_clk_period
        );
        rd_next_beat_ready_time.push_back(
          $time + response_delay * axi_clk_period
        );
        rd_beat_index.push_back(0);
        rd_started.push_back(1'b0);

        `uvm_info(
          "AXI_R_SCHED",
          $sformatf(
            {
              "Queue R id=0x%0h ar_accept=%0t delay=%0d cycles ",
              "first_ready_time=%0t resp=%02b user=0x%0h"
            },
            t.id,
            $time,
            response_delay,
            $time + response_delay * axi_clk_period,
            t.resp,
            t.user
          ),
          UVM_HIGH
        )
      end
    end
  endtask

  // Return 1 only when b_pending[idx] is the oldest completed write carrying
  // its ID. B responses may be reordered across IDs, never within one ID.
  function bit is_oldest_write_for_id(int idx);
    if (idx < 0 || idx >= b_pending.size())
      return 1'b0;

    for (int i = 0; i < idx; i++) begin
      if (b_pending[i].id == b_pending[idx].id)
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

    // 防止配置错误
    if (min_gap >= max_gap)
        return min_gap;

    // axi_min_beat_gap 占 60%
    if ($urandom_range(99, 0) < 60)
        return min_gap;

    gap_count    = max_gap - min_gap;
    total_weight = gap_count * (gap_count + 1) / 2;

    // ticket 范围为 [1, total_weight]
    ticket = $urandom_range(total_weight, 1);

    cumulative_weight = 0;

    for (int unsigned gap = min_gap + 1; gap <= max_gap; gap++) begin

        weight = max_gap - gap + 1;
        cumulative_weight += weight;

        if (ticket <= cumulative_weight)
            return gap;
    end

    return max_gap;
endfunction


  // ---- B engine : schedule independently matured write responses ------------
  task b_engine();
    int eligible_idx[$];

    forever begin
      @(vif.slv_cb);

      if (b_pending.size() > 0) begin
        int          selected_pos;
        int          selected_idx;
        axi_seq_item t;

        if (b_pending.size() != b_ready_time.size()) begin
          `uvm_fatal(
            "AXI_B_SCHED",
            $sformatf(
              "B queue size mismatch: pending=%0d ready_time=%0d",
              b_pending.size(),
              b_ready_time.size()
            )
          )
        end

        eligible_idx.delete();

        if (cfg == null || !cfg.axi_ooo_en) begin
          // With OOO disabled, preserve global write-response order.  A later
          // request may already be mature but must wait for queue entry zero.
          if (b_ready_time[0] <= $time)
            eligible_idx.push_back(0);
        end
        else begin
          // With OOO enabled, any mature request may respond, except that AXI
          // still requires responses carrying the same ID to remain ordered.
          foreach (b_pending[i]) begin
            if (b_ready_time[i] <= $time && is_oldest_write_for_id(i))
              eligible_idx.push_back(i);
          end
        end

        // No request has reached its own deadline yet.  Do not block here;
        // return to the top of the loop and re-check all requests next cycle.
        if (eligible_idx.size() == 0)
          continue;

        selected_pos =
          (cfg != null && cfg.axi_ooo_en && eligible_idx.size() > 1)
          ? $urandom_range(0, eligible_idx.size()-1) : 0;

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

  // Return 1 only when rd_q[idx] is the oldest outstanding request with
  // its AxID. AXI permits reordering between different IDs, but responses
  // carrying the same ID must preserve address-request order.
  function bit is_oldest_read_for_id(int idx);
    if (idx < 0 || idx >= rd_q.size())
      return 1'b0;

    for (int i = 0; i < idx; i++) begin
      if (rd_q[i].id == rd_q[idx].id)
        return 1'b0;
    end

    return 1'b1;
  endfunction

  // ---- R engine : independently timed, beat-level read scheduler ------------
  //
  // Each AR starts its response delay independently.  Once mature, one beat is
  // selected for the shared AXI R channel.  With interleave enabled, another ID
  // may use the channel while a burst is in its configured beat gap.  Requests
  // carrying the same ID are never interleaved or reordered.
  task r_engine();
    int eligible_idx[$];
    bit r_beat_active;
    int active_idx;
    bit burst_lock_valid;
    int burst_lock_idx;

    r_beat_active   = 1'b0;
    active_idx      = -1;
    burst_lock_valid= 1'b0;
    burst_lock_idx  = -1;

    forever begin
      @(vif.slv_cb);

      // A presented beat remains unchanged until RREADY accepts it.  No queue
      // arbitration or signal update is allowed while the channel is stalled.
      if (r_beat_active) begin
        if (!vif.slv_cb.rready)
          continue;

        // The previously presented beat handshakes at this edge.
        if (active_idx < 0 || active_idx >= rd_q.size()) begin
          `uvm_fatal(
            "AXI_R_SCHED",
            $sformatf(
              "Active R index out of range: index=%0d queue_size=%0d",
              active_idx,
              rd_q.size()
            )
          )
        end

        if (rd_beat_index[active_idx] >= int'(rd_q[active_idx].len)) begin
          // RLAST completed this transaction. Delete every parallel state entry
          // at the same index before attempting to schedule another beat.
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
        `uvm_fatal(
          "AXI_R_SCHED",
          $sformatf(
            {
              "R queue size mismatch: req=%0d first=%0d next=%0d ",
              "beat=%0d started=%0d"
            },
            rd_q.size(),
            rd_first_ready_time.size(),
            rd_next_beat_ready_time.size(),
            rd_beat_index.size(),
            rd_started.size()
          )
        )
      end

      if (rd_q.size() == 0)
        continue;

      eligible_idx.delete();

      if (cfg == null || !cfg.axi_interleave_en) begin
        // Without interleaving, once a burst starts it owns the R channel until
        // RLAST. Its beat gaps intentionally leave the shared channel idle.
        if (burst_lock_valid) begin
          if (burst_lock_idx >= rd_q.size()) begin
            `uvm_fatal(
              "AXI_R_SCHED",
              $sformatf(
                "Locked R index out of range: index=%0d queue_size=%0d",
                burst_lock_idx,
                rd_q.size()
              )
            )
          end

          if (rd_next_beat_ready_time[burst_lock_idx] <= $time)
            eligible_idx.push_back(burst_lock_idx);
        end
        else if (cfg == null || !cfg.axi_ooo_en) begin
          // OOO disabled: the globally oldest AR must start first.
          if (rd_next_beat_ready_time[0] <= $time &&
              is_oldest_read_for_id(0))
            eligible_idx.push_back(0);
        end
        else begin
          // OOO enabled: select any mature oldest request of each ID.
          foreach (rd_q[i]) begin
            if (rd_next_beat_ready_time[i] <= $time &&
                is_oldest_read_for_id(i))
              eligible_idx.push_back(i);
          end
        end
      end
      else if (cfg == null || !cfg.axi_ooo_en) begin
        int first_unstarted_idx;

        // Interleaving is enabled but response reordering is disabled. Already
        // started bursts may continue in any available gap, while new responses
        // must begin in original AR order.
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
        // Full legal stress mode: independent deadlines, different-ID OOO and
        // beat-level interleaving. Same-ID ordering is still enforced here.
        foreach (rd_q[i]) begin
          if (rd_next_beat_ready_time[i] <= $time &&
              is_oldest_read_for_id(i))
            eligible_idx.push_back(i);
        end
      end

      if (eligible_idx.size() > 0) begin
        int selected_pos;
        int selected_idx;

        selected_pos =
          ((cfg != null) &&
           (cfg.axi_ooo_en || cfg.axi_interleave_en) &&
           eligible_idx.size() > 1)
          ? $urandom_range(0, eligible_idx.size()-1) : 0;
        selected_idx = eligible_idx[selected_pos];

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

  // read 8 bytes from backing memory (unwritten => incrementing pattern)
  function logic [63:0] read_mem(longint a);
    logic [63:0] d;
    for (int b = 0; b < 8; b++) begin
      if (mem.exists(a+b)) d[b*8 +: 8] = mem[a+b];
      else                 d[b*8 +: 8] = (a+b) & 8'hFF;   // default pattern
    end
    return d;
  endfunction

endclass : axi_slave_driver

`endif // AXI_SLAVE_DRIVER_SV
