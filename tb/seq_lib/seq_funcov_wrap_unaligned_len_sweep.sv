`ifndef SEQ_FUNCOV_WRAP_UNALIGNED_LEN_SWEEP_SV
`define SEQ_FUNCOV_WRAP_UNALIGNED_LEN_SWEEP_SV

// =============================================================================
// File        : seq_funcov_wrap_unaligned_len_sweep.sv
// Description : Directed functional-coverage sequence for non-8-byte-aligned
//               RKNP WRAP read/write requests.
//
// Request types : RDW / WRW
// RKNP LEN      : 7, 15, 31, 63, 127
// Max beat count:
//   LEN=127 -> 128 bytes / 8 bytes per beat = 16 beats
//
// Each LEN is sent once as RDW and once as WRW:
//   5 LEN values x 2 directions = 10 requests.
//
// Address:
//   Keep legal 2-byte alignment, but force NOT 8-byte aligned.
//   Offsets 2/4/6 are rotated across the LEN sweep.
// =============================================================================

class seq_funcov_wrap_unaligned_len_sweep extends rknp_base_seq;
  `uvm_object_utils(seq_funcov_wrap_unaligned_len_sweep)

  localparam int unsigned NUM_LEN = 5;

  function new(string name = "seq_funcov_wrap_unaligned_len_sweep");
    super.new(name);
  endfunction

  protected function int unsigned get_len(int unsigned index);
    case (index)
      0: return 7;
      1: return 15;
      2: return 31;
      3: return 63;
      4: return 127;
      default: begin
        `uvm_fatal("SEQ_WRAP_UALIGN_LEN",
                   $sformatf("Invalid LEN-list index %0d", index))
        return 7;
      end
    endcase
  endfunction

  protected function int unsigned get_offset(int unsigned index);
    case (index % 3)
      0: return 2;
      1: return 4;
      default: return 6;
    endcase
  endfunction

  protected task send_one(
      axi_tniu_protocol_pkg::req_opc_e req_opc,
      int unsigned                    len_value,
      int unsigned                    addr_offset,
      string                          item_name);

    rknp_seq_item it;

    it = rknp_seq_item::type_id::create(item_name);

    start_item(it);

    if (!it.randomize() with {
          opc        == local::req_opc;
          status     == axi_tniu_protocol_pkg::ST_OK;
          len        == local::len_value;
          axcache[0] == 1'b0;

          // 0x100 is 8-byte aligned; +2/+4/+6 makes the address explicitly
          // non-8-byte-aligned while preserving 2-byte alignment.
          addr[11:0] == (12'h100 + local::addr_offset);
        }) begin
      `uvm_fatal("SEQ_WRAP_UALIGN_LEN",
                 $sformatf("Randomization failed: opc=%s len=%0d offset=%0d",
                           req_opc.name(), len_value, addr_offset))
    end

    complete_item(it, "SEQ_WRAP_UALIGN_LEN");
  endtask

  task body();
    int unsigned len_value;
    int unsigned addr_offset;

    `uvm_info("SEQ_WRAP_UALIGN_LEN",
              "Starting unaligned WRAP RDW/WRW LEN sweep: {7,15,31,63,127}",
              UVM_LOW)

    for (int unsigned i = 0; i < NUM_LEN; i++) begin
      len_value   = get_len(i);
      addr_offset = get_offset(i);

      send_one(
        axi_tniu_protocol_pkg::OPC_RDW,
        len_value,
        addr_offset,
        $sformatf("rdw_len_%0d_off_%0d", len_value, addr_offset)
      );

      send_one(
        axi_tniu_protocol_pkg::OPC_WRW,
        len_value,
        addr_offset,
        $sformatf("wrw_len_%0d_off_%0d", len_value, addr_offset)
      );
    end

    `uvm_info("SEQ_WRAP_UALIGN_LEN",
              $sformatf("Completed unaligned WRAP LEN sweep: %0d requests",
                        2 * NUM_LEN),
              UVM_LOW)
  endtask

endclass : seq_funcov_wrap_unaligned_len_sweep

`endif // SEQ_FUNCOV_WRAP_UNALIGNED_LEN_SWEEP_SV
