// =============================================================================
// File        : virtual_sequencer.sv
// Description : Virtual sequencer that holds handles to the RKNP request
//               sequencer and the AXI slave sequencer, so a single virtual
//               sequence can coordinate stimulus generation on the request side
//               with response-policy steering on the slave side.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef VIRTUAL_SEQUENCER_SV
`define VIRTUAL_SEQUENCER_SV

class virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(virtual_sequencer)

  rknp_sequencer rknp_sqr;   // drives RKNP requests into the DUT
  axi_sequencer  axi_sqr;    // steers the AXI slave response policy

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass : virtual_sequencer

`endif // VIRTUAL_SEQUENCER_SV
