// =============================================================================
// File        : rknp_sequencer.sv
// Description : RKNP sequencer. Schedules rknp_seq_item to the RKNP driver.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef RKNP_SEQUENCER_SV
`define RKNP_SEQUENCER_SV

class rknp_sequencer extends uvm_sequencer #(rknp_seq_item);
  `uvm_component_utils(rknp_sequencer)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass : rknp_sequencer

`endif // RKNP_SEQUENCER_SV
