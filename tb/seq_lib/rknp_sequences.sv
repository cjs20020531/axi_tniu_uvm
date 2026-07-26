// =============================================================================
// File        : rknp_sequences.sv
// Description : RKNP stimulus sequence library. All sequences generate
//               rknp_seq_item transactions for the RKNP request sequencer.
//               A configurable base sequence provides common helpers; directed
//               sequences target individual verification-plan features:
//                 - read / write (INCR)
//                 - wrapped read / write (WRAP realign)
//                 - error injection (req-error mode)
//                 - same-address ordering (WAW/WAR/RAW)
//                 - AXID mapping (OrderKey aliasing)
//                 - bufferable / early response
//                 - outstanding / interleave stress
//               plus a constrained-random sequence used by the random test.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef RKNP_SEQUENCES_SV
`define RKNP_SEQUENCES_SV

// -----------------------------------------------------------------------------
// Base sequence : shared knobs + a helper to size the write body correctly.
// -----------------------------------------------------------------------------
class rknp_base_seq extends uvm_sequence #(rknp_seq_item);
  `uvm_object_utils(rknp_base_seq)

  rand int unsigned num = 20;   // #transactions

  function new(string name = "rknp_base_seq");
    super.new(name);
  endfunction

  // Build the physical RKNP body after len and addr are known.
  //
  // The item inserts leading/trailing {BE=0, Byte=0} lanes automatically.
  // The existing driver therefore needs no change.
  virtual task finalize_item(rknp_seq_item it);
    it.build_aligned_write_body();
  endtask
endclass


// -----------------------------------------------------------------------------
// Directed read (INCR)
// -----------------------------------------------------------------------------
class rknp_rd_seq extends rknp_base_seq;
  `uvm_object_utils(rknp_rd_seq)
  function new(string name = "rknp_rd_seq"); super.new(name); endfunction
  task body();
    repeat (num) begin
      rknp_seq_item it = rknp_seq_item::type_id::create("it");
      start_item(it);
      if (!it.randomize() with { opc == axi_tniu_protocol_pkg::OPC_RD;
                                 status == axi_tniu_protocol_pkg::ST_OK;
                                 len inside {[0:63]}; })
        `uvm_error("RD_SEQ", "randomize failed")
      // finalize_item(it);

      // `uvm_info(
      //   "SEQ_AFTER_FINALIZE",
      //   it.convert2string(),
      //   UVM_NONE
      // )

      finish_item(it);
    end
  endtask
endclass


// -----------------------------------------------------------------------------
// Directed write (INCR)
// -----------------------------------------------------------------------------
class rknp_wr_seq extends rknp_base_seq;
  `uvm_object_utils(rknp_wr_seq)
  function new(string name = "rknp_wr_seq"); super.new(name); endfunction
  task body();
    repeat (num) begin
      rknp_seq_item it = rknp_seq_item::type_id::create("it");
      start_item(it);
      if (!it.randomize() with { opc == axi_tniu_protocol_pkg::OPC_WR;
                                 status == axi_tniu_protocol_pkg::ST_OK;
                                 len inside {[0:63]}; })
        `uvm_error("WR_SEQ", "randomize failed")
      finalize_item(it);
      finish_item(it);
    end
  endtask
endclass


// -----------------------------------------------------------------------------
// Wrapped read / write (exercises wrap-align realign path)
// -----------------------------------------------------------------------------
class rknp_wrap_seq extends rknp_base_seq;
  `uvm_object_utils(rknp_wrap_seq)
  function new(string name = "rknp_wrap_seq"); super.new(name); endfunction
  task body();
    repeat (num) begin
      rknp_seq_item it = rknp_seq_item::type_id::create("it");
      start_item(it);
      // WRAP requires len = 2^n - 1; constraint c_wrap_len enforces the set.
      if (!it.randomize() with { opc inside {axi_tniu_protocol_pkg::OPC_RDW, axi_tniu_protocol_pkg::OPC_WRW};
                                 status == axi_tniu_protocol_pkg::ST_OK; })
        `uvm_error("WRAP_SEQ", "randomize failed")
      finalize_item(it);
      finish_item(it);
    end
  endtask
endclass


// -----------------------------------------------------------------------------
// Error injection (req-error mode : ERR request must be reflected)
// -----------------------------------------------------------------------------
class rknp_err_seq extends rknp_base_seq;
  `uvm_object_utils(rknp_err_seq)
  function new(string name = "rknp_err_seq"); super.new(name); endfunction
  task body();
    repeat (num) begin
      rknp_seq_item it = rknp_seq_item::type_id::create("it");
      start_item(it);
      if (!it.randomize() with { status == axi_tniu_protocol_pkg::ST_ERR;
                                 errcode == axi_tniu_protocol_pkg::EC_ADDR_DEC;})
        `uvm_error("ERR_SEQ", "randomize failed")
      finalize_item(it);
      finish_item(it);
    end
  endtask
endclass


// -----------------------------------------------------------------------------
// Same-address ordering : bombard one address block with W/R to the same
// OrderKey so the DUT's WAW/WAR/RAW back-pressure logic is exercised.
// -----------------------------------------------------------------------------
class rknp_same_addr_seq extends rknp_base_seq;
  `uvm_object_utils(rknp_same_addr_seq)
  rand logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0]   fixed_addr;
  rand logic [axi_tniu_protocol_pkg::ORDKEY_WITH-1:0] fixed_key;
  function new(string name = "rknp_same_addr_seq"); super.new(name); endfunction
  task body();
    if (!this.randomize()) `uvm_error("ADDR_SEQ","rand failed");
    repeat (num) begin
      rknp_seq_item it = rknp_seq_item::type_id::create("it");
      start_item(it);
      if (!it.randomize() with { opc inside {axi_tniu_protocol_pkg::OPC_RD, axi_tniu_protocol_pkg::OPC_WR};
                                 status == axi_tniu_protocol_pkg::ST_OK;
                                 addr == fixed_addr;
                                 orderkey == fixed_key;
                                 len inside {[0:31]}; })
        `uvm_error("ADDR_SEQ", "randomize failed")
      finalize_item(it);
      finish_item(it);
    end
  endtask
endclass


// -----------------------------------------------------------------------------
// AXID mapping : drive OrderKeys that alias to the same low-nibble AxID to
// confirm the OrderKey->AxID mapping and per-AxID ordering.
// -----------------------------------------------------------------------------
class rknp_axid_seq extends rknp_base_seq;
  `uvm_object_utils(rknp_axid_seq)
  function new(string name = "rknp_axid_seq"); super.new(name); endfunction
  task body();
    logic [3:0] target_nibble = $urandom_range(0,15);
    repeat (num) begin
      rknp_seq_item it = rknp_seq_item::type_id::create("it");
      start_item(it);
      if (!it.randomize() with { status == axi_tniu_protocol_pkg::ST_OK;
                                 opc inside {axi_tniu_protocol_pkg::OPC_RD, axi_tniu_protocol_pkg::OPC_WR};
                                 orderkey[3:0] == target_nibble;
                                 len inside {[0:31]}; })
        `uvm_error("AXID_SEQ", "randomize failed")
      finalize_item(it);
      finish_item(it);
    end
  endtask
endclass


// -----------------------------------------------------------------------------
// Bufferable / early-response : force bufferable requests.
// -----------------------------------------------------------------------------
class rknp_ely_seq extends rknp_base_seq;
  `uvm_object_utils(rknp_ely_seq)
  function new(string name = "rknp_ely_seq"); super.new(name); endfunction
  task body();
    repeat (num) begin
      rknp_seq_item it = rknp_seq_item::type_id::create("it");
      start_item(it);
      if (!it.randomize() with { opc == axi_tniu_protocol_pkg::OPC_WR;
                                 status == axi_tniu_protocol_pkg::ST_OK;
                                 axcache[0] == 1'b1;      // bufferable (early-rsp)
                                 len inside {[0:31]}; })
        `uvm_error("ELY_SEQ", "randomize failed")
      finalize_item(it);
      finish_item(it);
    end
  endtask
endclass


// -----------------------------------------------------------------------------
// Constrained-random mix : full feature soup for the random test.
// -----------------------------------------------------------------------------
class rknp_random_seq extends rknp_base_seq;
  `uvm_object_utils(rknp_random_seq)
  function new(string name = "rknp_random_seq"); super.new(name); endfunction
  task body();
    repeat (num) begin
      rknp_seq_item it = rknp_seq_item::type_id::create("it");
      start_item(it);
      // fully random with weighting: mostly OK traffic, some errors, some wrap
      if (!it.randomize() with {
            status dist { axi_tniu_protocol_pkg::ST_OK := 80, axi_tniu_protocol_pkg::ST_ERR := 20 };
            opc dist { axi_tniu_protocol_pkg::OPC_RD  := 35, axi_tniu_protocol_pkg::OPC_WR  := 35,
                       axi_tniu_protocol_pkg::OPC_RDW := 15, axi_tniu_protocol_pkg::OPC_WRW := 15 };
            len inside {[0:127]};
          })
        `uvm_error("RAND_SEQ", "randomize failed")
      finalize_item(it);
      finish_item(it);
    end
  endtask
endclass

`endif // RKNP_SEQUENCES_SV

