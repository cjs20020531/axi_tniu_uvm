// =============================================================================
// File        : axi_sequencer.sv
// Description : Sequencer for the AXI slave agent. Response sequences run on
//               this sequencer to steer the slave driver's per-transaction
//               response policy (resp code, delays, interleave permission).
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_SEQUENCER_SV
`define AXI_SEQUENCER_SV

class axi_sequencer extends uvm_sequencer #(axi_seq_item);
  `uvm_component_utils(axi_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass : axi_sequencer

`endif // AXI_SEQUENCER_SV
