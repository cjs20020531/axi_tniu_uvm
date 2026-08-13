// =============================================================================
// File        : axi_monitor.sv
// Description : AXI4 monitor. Passively samples the five channels and publishes
//               completed transactions (one per AW+W+B for writes, one per
//               AR + full R burst for reads) on analysis ports for the
//               scoreboard and coverage.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_MONITOR_SV
`define AXI_MONITOR_SV

class axi_monitor extends uvm_monitor;
  `uvm_component_utils(axi_monitor)

  virtual axi_if vif;
  rknp_txn_tag_mgr tag_mgr;

  uvm_analysis_port #(axi_seq_item) aw_ap;   // write address seen
  uvm_analysis_port #(axi_seq_item) ar_ap;   // read address seen
  uvm_analysis_port #(axi_seq_item) w_ap;    // completed write (with data)
  uvm_analysis_port #(axi_seq_item) b_ap;    // write response seen
  uvm_analysis_port #(axi_seq_item) r_ap;    // completed read burst seen

  function new(string name, uvm_component parent);
    super.new(name, parent);
    aw_ap = new("aw_ap", this); ar_ap = new("ar_ap", this);
    w_ap  = new("w_ap",  this); b_ap  = new("b_ap",  this);
    r_ap  = new("r_ap",  this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "axi_if not set for axi_monitor")
    if (!uvm_config_db#(rknp_txn_tag_mgr)::get(this, "", "tag_mgr", tag_mgr))
      `uvm_fatal("AXI_MON", "rknp_txn_tag_mgr not found")
  endfunction

  task run_phase(uvm_phase phase);
    @(posedge vif.aresetn);
    fork
      mon_aw(); mon_ar(); mon_w(); mon_b(); mon_r();
    join
  endtask

  // ---- AW ------------------------------------------------------------------
  task mon_aw();
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.awvalid && vif.mon_cb.awready) begin
        axi_seq_item t = axi_seq_item::type_id::create("aw_mon");
        t.dir=AXI_WRITE; t.id=vif.mon_cb.awid; t.addr=vif.mon_cb.awaddr;
        t.len=vif.mon_cb.awlen; t.size=vif.mon_cb.awsize;
        t.burst=vif.mon_cb.awburst; t.cache=vif.mon_cb.awcache;
        if (!tag_mgr.record_axi_aw_accept(t.id, $time))
          `uvm_warning("LATENCY_TAG", $sformatf(
            "No pending RKNP write matched AXI AWID=0x%0h", t.id))
        aw_ap.write(t);
      end
    end
  endtask

  // ---- AR ------------------------------------------------------------------
  task mon_ar();
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.arvalid && vif.mon_cb.arready) begin
        axi_seq_item t = axi_seq_item::type_id::create("ar_mon");
        t.dir=AXI_READ; t.id=vif.mon_cb.arid; t.addr=vif.mon_cb.araddr;
        t.len=vif.mon_cb.arlen; t.size=vif.mon_cb.arsize; t.burst=vif.mon_cb.arburst;
        t.cache=vif.mon_cb.arcache;   // AxCACHE[0] carries bufferable (C-BP-01)
        if (!tag_mgr.record_axi_ar_accept(t.id, $time))
          `uvm_warning("LATENCY_TAG", $sformatf(
            "No pending RKNP read matched AXI ARID=0x%0h", t.id))
        ar_ap.write(t);
      end
    end
  endtask

  // ---- W : gather a full write-data burst ----------------------------------
  task mon_w();
    forever begin
      logic [63:0] d[$]; logic [7:0] s[$];
      @(vif.mon_cb);
      if (vif.mon_cb.wvalid && vif.mon_cb.wready) begin
        d.push_back(vif.mon_cb.wdata); s.push_back(vif.mon_cb.wstrb);
        while (!vif.mon_cb.wlast) begin
          do @(vif.mon_cb); while (!(vif.mon_cb.wvalid && vif.mon_cb.wready));
          d.push_back(vif.mon_cb.wdata); s.push_back(vif.mon_cb.wstrb);
        end
        begin
          axi_seq_item t = axi_seq_item::type_id::create("w_mon");
          t.dir=AXI_WRITE; t.id=vif.mon_cb.wid;
          t.data=new[d.size()]; t.strb=new[s.size()];
          foreach (d[i]) t.data[i]=d[i];
          foreach (s[i]) t.strb[i]=s[i];
          if (!tag_mgr.record_axi_w_accept(t.id, $time))
            `uvm_warning("LATENCY_TAG", $sformatf(
              "No pending RKNP write matched AXI WID=0x%0h", t.id))
          w_ap.write(t);
        end
      end
    end
  endtask

  // ---- B -------------------------------------------------------------------
  task mon_b();
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.bvalid && vif.mon_cb.bready) begin
        axi_seq_item t = axi_seq_item::type_id::create("b_mon");
        t.dir=AXI_WRITE; t.id=vif.mon_cb.bid; t.resp=vif.mon_cb.bresp;
        t.user=vif.mon_cb.buser;
        b_ap.write(t);
      end
    end
  endtask

  // ---- R : gather a full read burst per ID (handles interleave via per-ID q)-
  task mon_r();
    logic [63:0] d[logic[3:0]][$];
    logic [1:0] resp_by_id[logic[3:0]];
    logic [axi_tniu_protocol_pkg::AUSER_WITH-1:0] user_by_id[logic[3:0]];
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.rvalid && vif.mon_cb.rready) begin
        logic [3:0] id = vif.mon_cb.rid;
        if (d[id].size() == 0) begin
          // The first accepted beat defines the response for this transaction.
          // This lets the scoreboard observe an error from beat zero instead
          // of accidentally using only the final beat's RRESP.
          resp_by_id[id] = vif.mon_cb.rresp;
          user_by_id[id] = vif.mon_cb.ruser;
        end
        else if (vif.mon_cb.rresp !== resp_by_id[id]) begin
          `uvm_error("AXI_RRESP_STABLE", $sformatf(
            {"RRESP changed inside one read transaction: id=0x%0h ",
             "first=%02b current=%02b beat=%0d"},
            id, resp_by_id[id], vif.mon_cb.rresp, d[id].size()))
        end

        d[id].push_back(vif.mon_cb.rdata);
        if (vif.mon_cb.rlast) begin
          axi_seq_item t = axi_seq_item::type_id::create("r_mon");
          t.dir=AXI_READ; t.id=id; t.resp=resp_by_id[id];
          t.user=user_by_id[id];
          t.data=new[d[id].size()];
          foreach (d[id][i]) t.data[i]=d[id][i];
          r_ap.write(t);
          d[id].delete();
          resp_by_id.delete(id);
          user_by_id.delete(id);
        end
      end
    end
  endtask

endclass : axi_monitor

`endif // AXI_MONITOR_SV
