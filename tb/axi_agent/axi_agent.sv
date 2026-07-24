// =============================================================================
// File        : axi_agent.sv
// Description : AXI slave agent. The DUT (axi_tniu) is the AXI master, so this
//               agent plays the downstream slave: it accepts AW/AR/W and drives
//               R/B. It is ACTIVE (drives the bus) and always instantiates a
//               monitor that broadcasts every channel transaction to the env.
//
//               The slave driver is REACTIVE: it services the AXI handshakes
//               from a backing memory and shapes its responses from axi_tniu_cfg
//               (delays, out-of-order, read interleave, SLVERR rate). The
//               sequencer is present so directed response sequences can be run
//               when finer per-ID steering is required.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_AGENT_SV
`define AXI_AGENT_SV

class axi_agent extends uvm_agent;
  `uvm_component_utils(axi_agent)

  axi_slave_driver drv;
  axi_sequencer    sqr;
  axi_monitor      mon;

  axi_tniu_cfg     cfg;

  // Re-exported analysis ports (mirror the monitor's per-channel ports).
  uvm_analysis_port #(axi_seq_item) aw_ap;
  uvm_analysis_port #(axi_seq_item) ar_ap;
  uvm_analysis_port #(axi_seq_item) w_ap;
  uvm_analysis_port #(axi_seq_item) b_ap;
  uvm_analysis_port #(axi_seq_item) r_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    aw_ap = new("aw_ap", this);  ar_ap = new("ar_ap", this);
    w_ap  = new("w_ap",  this);  b_ap  = new("b_ap",  this);
    r_ap  = new("r_ap",  this);

    void'(uvm_config_db#(axi_tniu_cfg)::get(this, "", "cfg", cfg));

    mon = axi_monitor::type_id::create("mon", this);
    if (get_is_active() == UVM_ACTIVE) begin
      drv = axi_slave_driver::type_id::create("drv", this);
      sqr = axi_sequencer  ::type_id::create("sqr", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
    // fan the monitor ports out through the agent boundary
    mon.aw_ap.connect(aw_ap);  
    mon.ar_ap.connect(ar_ap);
    mon.w_ap.connect(w_ap);    
    mon.b_ap.connect(b_ap);
    mon.r_ap.connect(r_ap);
  endfunction

endclass : axi_agent

`endif // AXI_AGENT_SV
