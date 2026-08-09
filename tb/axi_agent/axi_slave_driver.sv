// =============================================================================
// File        : axi_slave_driver.sv
// Description : AXI4 slave driver. Responds to the DUT's AXI master interface.
//               Features exercised by the verification plan:
//                 - AW/W capture into a byte-addressable memory model
//                 - AR handling with a backing-memory read
//                 - configurable AxREADY / response / beat delays
//                 - multiple outstanding transactions
//                 - out-of-order B/R responses across different IDs
//                 - read-data interleaving across different IDs
//                 - strict request-order preservation within each AXI ID
//               Response policy defaults to constrained-random; a slave
//               sequence may inject an axi_seq_item to force specific behaviour.
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
  axi_seq_item  aw_q[$];
  axi_seq_item  w_q[$];

  // Write transactions whose AW and W sides have both completed.
  axi_seq_item  b_pending[$];

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
    aw_q.delete();
    w_q.delete();
    b_pending.delete();
  endfunction

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

        aw = aw_q.pop_front();
        w  = w_q.pop_front();

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

        // Both sides are now complete. Queue exactly one B response.
        b_pending.push_back(aw);
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
        t.dir=AXI_READ; t.id=vif.slv_cb.arid; t.addr=vif.slv_cb.araddr;
        t.len=vif.slv_cb.arlen; t.size=vif.slv_cb.arsize;
        t.burst=vif.slv_cb.arburst;
        rd_q.push_back(t);
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


  // ---- B engine : serialize write responses (optionally out-of-order) -------
  task b_engine();
    int eligible_idx[$];

    forever begin
      @(vif.slv_cb);

      if (b_pending.size() > 0) begin
        int          selected_pos;
        int          selected_idx;
        axi_seq_item t;

        eligible_idx.delete();
        foreach (b_pending[i]) begin
          if (is_oldest_write_for_id(i))
            eligible_idx.push_back(i);
        end

        if (eligible_idx.size() == 0) begin
          `uvm_error(
            "AXI_WR_ORDER",
            "No legal B-response candidate found while b_pending is non-empty"
          )
          continue;
        end

        selected_pos =
          (cfg != null && cfg.axi_ooo_en && eligible_idx.size() > 1)
          ? $urandom_range(0, eligible_idx.size()-1) : 0;

        selected_idx = eligible_idx[selected_pos];
        t            = b_pending[selected_idx];
        b_pending.delete(selected_idx);

        repeat (get_resp_delay()) @(vif.slv_cb);
        vif.slv_cb.bvalid <= 1'b1;
        vif.slv_cb.bid    <= t.id;
        vif.slv_cb.bresp  <= 2'b00;   // OKAY
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

  // ---- R engine : generate read data, out-of-order + interleaved ------------
  task r_engine();
    int eligible_idx[$];
    int interleave_idx[$];

    forever begin
      @(vif.slv_cb);

      if (rd_q.size() == 0)
        continue;

      eligible_idx.delete();

      // Only the oldest request of each ID may be scheduled. Random selection
      // among these candidates still provides legal out-of-order responses
      // between different IDs.
      foreach (rd_q[i]) begin
        if (is_oldest_read_for_id(i))
          eligible_idx.push_back(i);
      end

      if (eligible_idx.size() == 0) begin
        `uvm_error(
          "AXI_RD_ORDER",
          "No legal read candidate found while rd_q is non-empty"
        )
        continue;
      end

      begin
        int          selected_pos;
        int          selected_idx;
        axi_seq_item t0;

        selected_pos =
          (cfg != null && cfg.axi_ooo_en && eligible_idx.size() > 1)
          ? $urandom_range(0, eligible_idx.size()-1) : 0;

        selected_idx = eligible_idx[selected_pos];
        t0           = rd_q[selected_idx];
        rd_q.delete(selected_idx);

        interleave_idx.delete();

        // The second interleaved burst must:
        //   1. use a different ID from t0;
        //   2. be the oldest outstanding request of its own ID.
        //
        // A later request with the same ID as t0 must wait until t0 has
        // completed, otherwise the DUT cannot distinguish the two responses.
        foreach (rd_q[i]) begin
          if ((rd_q[i].id != t0.id) && is_oldest_read_for_id(i))
            interleave_idx.push_back(i);
        end

        if (cfg != null &&
            cfg.axi_interleave_en &&
            interleave_idx.size() > 0 &&
            $urandom_range(0,1)) begin
          int          second_pos;
          int          second_idx;
          axi_seq_item t1;

          second_pos =
            (cfg.axi_ooo_en && interleave_idx.size() > 1)
            ? $urandom_range(0, interleave_idx.size()-1)
            : 0;

          second_idx = interleave_idx[second_pos];
          t1         = rd_q[second_idx];
          rd_q.delete(second_idx);

          `uvm_info(
            "AXI_RD_SCHED",
            $sformatf(
              {
                "Interleave different IDs: ",
                "first(id=0x%0h,addr=0x%010h,len=%0d) ",
                "second(id=0x%0h,addr=0x%010h,len=%0d)"
              },
              t0.id, t0.addr, t0.len,
              t1.id, t1.addr, t1.len
            ),
            UVM_HIGH
          )

          send_interleaved(t0, t1);
        end
        else begin
          `uvm_info(
            "AXI_RD_SCHED",
            $sformatf(
              "Send read burst: id=0x%0h addr=0x%010h len=%0d(beats=%0d)",
              t0.id,
              t0.addr,
              t0.len,
              int'(t0.len) + 1
            ),
            UVM_HIGH
          )

          send_read_burst(t0, 1'b1);
        end
      end
    end
  endtask

  // send a full (non-interleaved) read burst
  task send_read_burst(axi_seq_item t, bit contiguous);
    repeat (get_resp_delay()) @(vif.slv_cb);
    for (int beat = 0; beat <= t.len; beat++) begin
      vif.slv_cb.rvalid <= 1'b1;
      vif.slv_cb.rid    <= t.id;
      vif.slv_cb.rdata  <= read_mem(t.addr + beat*8);
      vif.slv_cb.rresp  <= 2'b00;
      vif.slv_cb.rlast  <= (beat == t.len);
      do @(vif.slv_cb); while (!vif.slv_cb.rready);
      repeat (get_beat_gap_delay()) begin  // inter-beat gap
        vif.slv_cb.rvalid <= 1'b0;
        vif.slv_cb.rlast  <= 1'b0; @(vif.slv_cb);
      end
    end
    vif.slv_cb.rvalid <= 1'b0; 
    vif.slv_cb.rlast <= 1'b0;
  endtask

  // Interleave two read bursts beat-by-beat (exercises F-ILV-01).
  // Interleaving two transactions carrying the same ID is forbidden because
  // the receiver has no way to tell which same-ID transaction owns each beat.
  task send_interleaved(axi_seq_item a, axi_seq_item b);
    int ba = 0;
    int bb = 0;

    if (a.id == b.id) begin
      `uvm_fatal(
        "AXI_RD_ORDER",
        $sformatf(
          {
            "Illegal same-ID read interleave: ",
            "id=0x%0h first_addr=0x%010h second_addr=0x%010h"
          },
          a.id,
          a.addr,
          b.addr
        )
      )
    end

    while (ba <= a.len || bb <= b.len) begin
      if (ba <= a.len) begin
        drive_r_beat(a, ba);
        ba++;
      end

      if (bb <= b.len) begin
        drive_r_beat(b, bb);
        bb++;
      end
    end

    vif.slv_cb.rvalid <= 1'b0;
    vif.slv_cb.rlast  <= 1'b0;
  endtask

  task drive_r_beat(axi_seq_item t, int beat);
    vif.slv_cb.rvalid <= 1'b1;
    vif.slv_cb.rid    <= t.id;
    vif.slv_cb.rdata  <= read_mem(t.addr + beat*8);
    vif.slv_cb.rresp  <= 2'b00;
    vif.slv_cb.rlast  <= (beat == t.len);
    do @(vif.slv_cb); while (!vif.slv_cb.rready);
    vif.slv_cb.rvalid <= 1'b0;

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
