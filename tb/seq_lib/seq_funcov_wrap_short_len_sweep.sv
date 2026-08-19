`ifndef SEQ_FUNCOV_WRAP_SHORT_LEN_SWEEP_SV
`define SEQ_FUNCOV_WRAP_SHORT_LEN_SWEEP_SV

// =============================================================================
// File        : seq_funcov_wrap_short_len_sweep.sv
// Description : Directed functional-coverage sequence for short RKNP WRAP
//               read/write requests.
//
// Request types : RDW / WRW
// RKNP LEN      : 1, 3
//
// Each LEN is sent once as RDW and once as WRW:
//   2 LEN values x 2 directions = 4 requests.
//
// Address:
//   No additional address requirement is imposed here.
//   Native rknp_seq_item constraints remain active.
// =============================================================================

class seq_funcov_wrap_short_len_sweep extends rknp_base_seq;
  `uvm_object_utils(seq_funcov_wrap_short_len_sweep)

  localparam int unsigned NUM_LEN = 2;

  function new(string name = "seq_funcov_wrap_short_len_sweep");
    super.new(name);
  endfunction

  protected function int unsigned get_len(int unsigned index);
    case (index)
      0: return 1;
      1: return 3;
      default: begin
        `uvm_fatal("SEQ_WRAP_SHORT_LEN",
                   $sformatf("Invalid LEN-list index %0d", index))
        return 1;
      end
    endcase
  endfunction

  protected task send_one(
      axi_tniu_protocol_pkg::req_opc_e req_opc,
      int unsigned                    len_value,
      string                          item_name);

    rknp_seq_item it;

    it = rknp_seq_item::type_id::create(item_name);

    start_item(it);

    if (!it.randomize() with {
          opc        == local::req_opc;
          status     == axi_tniu_protocol_pkg::ST_OK;
          len        == local::len_value;
          axcache[0] == 1'b0;
          // No additional address constraint.
        }) begin
      `uvm_fatal("SEQ_WRAP_SHORT_LEN",
                 $sformatf("Randomization failed: opc=%s len=%0d",
                           req_opc.name(), len_value))
    end

    complete_item(it, "SEQ_WRAP_SHORT_LEN");
  endtask

  task body();
    int unsigned len_value;

    `uvm_info("SEQ_WRAP_SHORT_LEN",
              "Starting short WRAP RDW/WRW LEN sweep: {1,3}",
              UVM_LOW)

    for (int unsigned i = 0; i < NUM_LEN; i++) begin
      len_value = get_len(i);

      send_one(
        axi_tniu_protocol_pkg::OPC_RDW,
        len_value,
        $sformatf("rdw_len_%0d", len_value)
      );

      send_one(
        axi_tniu_protocol_pkg::OPC_WRW,
        len_value,
        $sformatf("wrw_len_%0d", len_value)
      );
    end

    `uvm_info("SEQ_WRAP_SHORT_LEN",
              $sformatf("Completed short WRAP LEN sweep: %0d requests",
                        2 * NUM_LEN),
              UVM_LOW)
  endtask

endclass : seq_funcov_wrap_short_len_sweep

`endif // SEQ_FUNCOV_WRAP_SHORT_LEN_SWEEP_SV
