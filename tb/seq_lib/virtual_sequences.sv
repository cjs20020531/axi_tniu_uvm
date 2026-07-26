// =============================================================================
// File        : virtual_sequences.sv
// Description : Common virtual-sequence infrastructure.
//
//               Concrete testcase scenarios belong in axi_tniu_tests.sv.
//               A derived virtual sequence should be added here only when one
//               scenario must coordinate multiple sequencers, for example an
//               RKNP request sequence and an explicitly controlled AXI response
//               sequence running together.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef VIRTUAL_SEQUENCES_SV
`define VIRTUAL_SEQUENCES_SV

class vseq_base extends uvm_sequence;
  `uvm_object_utils(vseq_base)
  `uvm_declare_p_sequencer(virtual_sequencer)

  function new(string name = "vseq_base");
    super.new(name);
  endfunction

  // Helper for future multi-sequencer virtual sequences. The current tests
  // have only one proactive stimulus stream and therefore start the RKNP
  // sequence directly from axi_tniu_base_test.
  protected task start_rknp_sequence(rknp_base_seq seq);
    if (seq == null)
      `uvm_fatal("VSEQ_NULL", "Attempted to start a null RKNP sequence")

    if ((p_sequencer == null) || (p_sequencer.rknp_sqr == null))
      `uvm_fatal("VSEQ_SQR", "RKNP sequencer handle is not connected")

    seq.start(p_sequencer.rknp_sqr);
  endtask
endclass : vseq_base

`endif // VIRTUAL_SEQUENCES_SV
