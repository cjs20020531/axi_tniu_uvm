// =============================================================================
// File        : vseq_base.sv
// Description : Base virtual sequence for future multi-sequencer scenarios.
// =============================================================================
`ifndef VSEQ_BASE_SV
`define VSEQ_BASE_SV

class vseq_base extends uvm_sequence;
  `uvm_object_utils(vseq_base)
  `uvm_declare_p_sequencer(virtual_sequencer)

  function new(string name = "vseq_base");
    super.new(name);
  endfunction

  protected task start_rknp_sequence(rknp_base_seq seq);
    if (seq == null)
      `uvm_fatal("VSEQ_NULL", "Attempted to start a null RKNP sequence")
    if ((p_sequencer == null) || (p_sequencer.rknp_sqr == null))
      `uvm_fatal("VSEQ_SQR", "RKNP sequencer handle is not connected")
    seq.start(p_sequencer.rknp_sqr);
  endtask
endclass : vseq_base

`endif // VSEQ_BASE_SV
