// =============================================================================
// File        : rknp_agent.sv
// Description : RKNP active master agent. Bundles the sequencer, driver and
//               monitor and exposes the monitor analysis ports upward.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef RKNP_AGENT_SV
`define RKNP_AGENT_SV

class rknp_agent extends uvm_agent;
  `uvm_component_utils(rknp_agent)

  rknp_sequencer sqr;
  rknp_driver    drv;
  rknp_monitor   mon;

  // convenience: re-export monitor ports
  uvm_analysis_port #(rknp_seq_item) req_ap;
  uvm_analysis_port #(rknp_seq_item) rsp_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    req_ap = new("req_ap", this);
    rsp_ap = new("rsp_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = rknp_monitor::type_id::create("mon", this);
    if (get_is_active() == UVM_ACTIVE) begin
      sqr = rknp_sequencer::type_id::create("sqr", this);
      drv = rknp_driver   ::type_id::create("drv", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mon.req_ap.connect(req_ap);
    mon.rsp_ap.connect(rsp_ap);
    if (get_is_active() == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass : rknp_agent

`endif // RKNP_AGENT_SV
