// =============================================================================
// File        : virtual_sequences.sv
// Description : Virtual sequences that run on the virtual_sequencer. Each one
//               launches a chosen RKNP request sequence on the RKNP sequencer
//               (the AXI slave responds reactively from its policy). Tests pick
//               a virtual sequence by type, keeping test bodies tiny.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef VIRTUAL_SEQUENCES_SV
`define VIRTUAL_SEQUENCES_SV

class vseq_base extends uvm_sequence;
  `uvm_object_utils(vseq_base)
  `uvm_declare_p_sequencer(virtual_sequencer)

  int unsigned num = 20;

  function new(string name = "vseq_base");
    super.new(name);
  endfunction
endclass


// generic macro-free wrapper: run any rknp_base_seq subtype
`define VSEQ_WRAP(VNAME, SNAME)                                             \
class VNAME extends vseq_base;                                             \
  `uvm_object_utils(VNAME)                                                 \
  function new(string name = `"VNAME`"); super.new(name); endfunction      \
  task body();                                                             \
    SNAME s = SNAME::type_id::create("s");                                \
    s.num = num;                                                           \
    s.start(p_sequencer.rknp_sqr);                                        \
  endtask                                                                  \
endclass

`VSEQ_WRAP(vseq_rd,        rknp_rd_seq)
`VSEQ_WRAP(vseq_wr,        rknp_wr_seq)
`VSEQ_WRAP(vseq_wrap,      rknp_wrap_seq)
`VSEQ_WRAP(vseq_err,       rknp_err_seq)
`VSEQ_WRAP(vseq_same_addr, rknp_same_addr_seq)
`VSEQ_WRAP(vseq_axid,      rknp_axid_seq)
`VSEQ_WRAP(vseq_ely,       rknp_ely_seq)
`VSEQ_WRAP(vseq_random,    rknp_random_seq)


// Mixed regression virtual sequence : chains several directed sequences plus a
// random tail, giving broad feature coverage in one run.
class vseq_mix extends vseq_base;
  `uvm_object_utils(vseq_mix)
  function new(string name = "vseq_mix"); super.new(name); endfunction
  task body();
    rknp_rd_seq        s_rd   = rknp_rd_seq       ::type_id::create("s_rd");
    rknp_wr_seq        s_wr   = rknp_wr_seq       ::type_id::create("s_wr");
    rknp_wrap_seq      s_wrap = rknp_wrap_seq     ::type_id::create("s_wrap");
    rknp_err_seq       s_err  = rknp_err_seq      ::type_id::create("s_err");
    // rknp_same_addr_seq s_adr  = rknp_same_addr_seq::type_id::create("s_adr");
    // rknp_axid_seq      s_axid = rknp_axid_seq     ::type_id::create("s_axid");
    // rknp_ely_seq       s_ely  = rknp_ely_seq      ::type_id::create("s_ely");
    // rknp_random_seq    s_rnd  = rknp_random_seq   ::type_id::create("s_rnd");
    s_rd.num=num;  
    s_wr.num=num;  
    s_wrap.num=num; 
    s_err.num=num;
    // s_adr.num=num; 
    // s_axid.num=num; 
    // s_ely.num=num; 
    // s_rnd.num=num*2;
    s_rd.start  (p_sequencer.rknp_sqr);
    s_wr.start  (p_sequencer.rknp_sqr);
    s_wrap.start(p_sequencer.rknp_sqr);
    s_err.start (p_sequencer.rknp_sqr);
    // s_adr.start (p_sequencer.rknp_sqr);
    // s_axid.start(p_sequencer.rknp_sqr);
    // s_ely.start (p_sequencer.rknp_sqr);
    // s_rnd.start (p_sequencer.rknp_sqr);
  endtask
endclass

`endif // VIRTUAL_SEQUENCES_SV
