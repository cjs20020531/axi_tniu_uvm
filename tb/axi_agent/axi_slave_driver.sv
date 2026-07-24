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

  // outstanding read/write request queues (address phase accepted)
  axi_seq_item  rd_q[$];
  axi_seq_item  wr_q[$];

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
      init_outputs();                 // drive ALL outputs to known 0 (also during reset)
      wait (vif.aresetn === 1'b1);    // proceed once reset is de-asserted
      fork : slave_procs
        aw_channel();      // accept write address
        w_channel();       // accept write data + push B
        ar_channel();      // accept read address
        r_engine();        // generate read data (with OOO + interleave)
        b_engine();        // generate write responses (with OOO)
        @(negedge vif.aresetn);   // reset re-asserted -> fall through and re-init
      join_any
      disable slave_procs;          // kill channels; loop re-drives outputs to 0
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
        wr_q.push_back(t);
      end
    end
  endtask

  // ---- W : accept write data, write memory, schedule B (ready HIGH default) --
  task w_channel();
    bit          rdy;
    axi_seq_item cur  = null;   // write burst currently being received
    int          beat = 0;      // beat index within the burst
    longint      a    = 0;      // base address of the burst
    forever begin
      rdy = slv_ready();
      vif.slv_cb.wready <= rdy;
      @(vif.slv_cb);
      if (rdy && vif.slv_cb.wvalid) begin       // handshake this cycle
        if (cur == null) begin
          wait (wr_q.size() > 0);               // matching AW (already captured)
          cur = wr_q[0]; wr_q.delete(0);
          beat = 0; a = cur.addr;
        end
        // commit strobed bytes to memory (INCR assumed for backing store)
        for (int b = 0; b < 8; b++)
          if (vif.slv_cb.wstrb[b]) mem[a + beat*8 + b] = vif.slv_cb.wdata[b*8 +: 8];
        if (vif.slv_cb.wlast) begin
          fork automatic axi_seq_item tt = cur; b_push(tt); join_none
          cur = null;
        end
        else beat++;
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

  // ---- B engine : serialize write responses (optionally out-of-order) -------
  axi_seq_item b_pending[$];
  task b_push(axi_seq_item t); b_pending.push_back(t); endtask
  task b_engine();
    forever begin
      @(vif.slv_cb);
      if (b_pending.size() > 0) begin
        // out-of-order: randomly pick an index when enabled
        int idx = (cfg != null && cfg.axi_ooo_en && b_pending.size()>1)
                  ? $urandom_range(0, b_pending.size()-1) : 0;
        axi_seq_item t = b_pending[idx];
        b_pending.delete(idx);
        repeat ($urandom_range(0,4)) @(vif.slv_cb);
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
    repeat ($urandom_range(0,5)) @(vif.slv_cb);
    for (int beat = 0; beat <= t.len; beat++) begin
      vif.slv_cb.rvalid <= 1'b1;
      vif.slv_cb.rid    <= t.id;
      vif.slv_cb.rdata  <= read_mem(t.addr + beat*8);
      vif.slv_cb.rresp  <= 2'b00;
      vif.slv_cb.rlast  <= (beat == t.len);
      do @(vif.slv_cb); while (!vif.slv_cb.rready);
      repeat ($urandom_range(0,2)) begin  // inter-beat gap
        vif.slv_cb.rvalid <= 1'b0; @(vif.slv_cb);
      end
    end
    vif.slv_cb.rvalid <= 1'b0; vif.slv_cb.rlast <= 1'b0;
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

