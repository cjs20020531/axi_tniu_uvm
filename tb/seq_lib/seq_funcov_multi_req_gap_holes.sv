`ifndef SEQ_FUNCOV_MULTI_REQ_GAP_HOLES_SV
`define SEQ_FUNCOV_MULTI_REQ_GAP_HOLES_SV

// =============================================================================
// File        : seq_funcov_multi_req_gap_holes.sv
// Description : Directed adjacent-request matrices used to close the remaining
//               cg_multi_req gap_1_10/gap_gt10 and x_pair_beat holes.
//
// All addresses are 8-byte aligned.  With NBYTEPERWORD=8:
//   LEN=7  -> expected AXI beat class beat1
//   LEN=15 -> expected AXI beat class multi
//
// The test selects one of the two modes below and fixes cfg.req_min_gap and
// cfg.req_max_gap before starting the sequence:
//   FUNCOV_MULTI_REQ_GAP_GT10 : req_gap=12
//   FUNCOV_MULTI_REQ_GAP_1_10 : req_gap=4
//
// Note that cfg.req_gap is measured from the previous packet TAIL to the next
// packet HEAD, while cg_multi_req measures HEAD-to-HEAD.  req_gap=12 therefore
// guarantees gap_gt10.  req_gap=4 remains in gap_1_10 even when the previous
// aligned LEN=15 write occupies two RKNP flits (measured HEAD gap is about 5).
// =============================================================================

typedef enum int {
  FUNCOV_MULTI_REQ_GAP_1_10,
  FUNCOV_MULTI_REQ_GAP_GT10
} funcov_multi_req_gap_mode_e;

class seq_funcov_multi_req_gap_holes extends rknp_base_seq;
  `uvm_object_utils(seq_funcov_multi_req_gap_holes)

  localparam int unsigned LEN_BEAT1 = 7;
  localparam int unsigned LEN_MULTI = 15;

  funcov_multi_req_gap_mode_e mode = FUNCOV_MULTI_REQ_GAP_GT10;

  function new(string name = "seq_funcov_multi_req_gap_holes");
    super.new(name);
  endfunction

  // Send one normal, non-bufferable request with an explicit request kind,
  // LEN, and naturally aligned address.
  protected task send_req(
      axi_tniu_protocol_pkg::req_opc_e req_opc,
      int unsigned                    len_value,
      int unsigned                    case_index,
      int unsigned                    item_index,
      string                          item_name);

    rknp_seq_item it;
    int unsigned addr_low;

    it = rknp_seq_item::type_id::create(item_name);

    // Separate address windows per case.  The largest address used by either
    // matrix is well below the next 4-KiB boundary.
    addr_low = 12'h100 + (case_index * 12'h040)
                         + (item_index * 12'h020);
    addr_low = addr_low & 12'hff8;

    start_item(it);

    if (!it.randomize() with {
          opc        == local::req_opc;
          status     == axi_tniu_protocol_pkg::ST_OK;
          errcode    == axi_tniu_protocol_pkg::EC_TARGET;
          len        == local::len_value;
          axcache[0] == 1'b0;
          addr[11:0] == local::addr_low;
        }) begin
      `uvm_fatal("SEQ_MULTI_REQ_GAP_HOLES",
                 $sformatf(
                   "Randomization failed: mode=%0d case=%0d item=%0d opc=%s len=%0d addr_low=0x%03x",
                   mode, case_index, item_index, req_opc.name(),
                   len_value, addr_low))
    end

    if ((int'(it.addr) &
         (axi_tniu_protocol_pkg::NBYTEPERWORD - 1)) != 0) begin
      `uvm_fatal("SEQ_MULTI_REQ_GAP_HOLES",
                 $sformatf("Request address is not 8-byte aligned: addr=0x%0h",
                           it.addr))
    end

    complete_item(it, "SEQ_MULTI_REQ_GAP_HOLES");
  endtask

  // Submit exactly two adjacent sequence items.  Both beat classes are
  // explicit; unlike the older B2B matrix, the first request is not forced to
  // beat1.
  protected task send_pair(
      int unsigned                    case_index,
      string                          case_name,
      axi_tniu_protocol_pkg::req_opc_e first_opc,
      int unsigned                    first_len,
      axi_tniu_protocol_pkg::req_opc_e second_opc,
      int unsigned                    second_len);

    `uvm_info("SEQ_MULTI_REQ_GAP_HOLES",
              $sformatf("MODE=%0d CASE=%s : %s(len=%0d) -> %s(len=%0d)",
                        mode, case_name, first_opc.name(), first_len,
                        second_opc.name(), second_len),
              UVM_LOW)

    send_req(first_opc, first_len, case_index, 0,
             $sformatf("case_%s_first", case_name));

    send_req(second_opc, second_len, case_index, 1,
             $sformatf("case_%s_second", case_name));
  endtask

  // req_gap=12 block.  Cases G01..G07 close all five remaining gap_gt10
  // kind-pair bins.  The complete matrix also closes eleven x_pair_beat bins.
  protected task run_gap_gt10_matrix();
    send_pair(0,  "G01", axi_tniu_protocol_pkg::OPC_RD,  LEN_MULTI,
                           axi_tniu_protocol_pkg::OPC_RDW, LEN_BEAT1);

    send_pair(1,  "G02", axi_tniu_protocol_pkg::OPC_RD,  LEN_BEAT1,
                           axi_tniu_protocol_pkg::OPC_WRW, LEN_BEAT1);

    send_pair(2,  "G03", axi_tniu_protocol_pkg::OPC_RD,  LEN_BEAT1,
                           axi_tniu_protocol_pkg::OPC_WRW, LEN_MULTI);

    send_pair(3,  "G04", axi_tniu_protocol_pkg::OPC_RDW, LEN_MULTI,
                           axi_tniu_protocol_pkg::OPC_RD,  LEN_BEAT1);

    send_pair(4,  "G05", axi_tniu_protocol_pkg::OPC_RDW, LEN_BEAT1,
                           axi_tniu_protocol_pkg::OPC_WR,  LEN_BEAT1);

    send_pair(5,  "G06", axi_tniu_protocol_pkg::OPC_RDW, LEN_BEAT1,
                           axi_tniu_protocol_pkg::OPC_WR,  LEN_MULTI);

    send_pair(6,  "G07", axi_tniu_protocol_pkg::OPC_RDW, LEN_MULTI,
                           axi_tniu_protocol_pkg::OPC_WRW, LEN_BEAT1);

    // Remaining x_pair_beat holes; their gap class is intentionally also
    // gap_gt10, but no additional x_pair_gap bin depends on that choice.
    send_pair(7,  "G08", axi_tniu_protocol_pkg::OPC_WRW, LEN_BEAT1,
                           axi_tniu_protocol_pkg::OPC_RD,  LEN_BEAT1);

    send_pair(8,  "G09", axi_tniu_protocol_pkg::OPC_WRW, LEN_MULTI,
                           axi_tniu_protocol_pkg::OPC_RD,  LEN_BEAT1);

    send_pair(9,  "G10", axi_tniu_protocol_pkg::OPC_WRW, LEN_MULTI,
                           axi_tniu_protocol_pkg::OPC_WR,  LEN_BEAT1);

    send_pair(10, "G11", axi_tniu_protocol_pkg::OPC_WRW, LEN_MULTI,
                           axi_tniu_protocol_pkg::OPC_WRW, LEN_BEAT1);
  endtask

  // req_gap=4 block.  L01 and L02 close the two remaining gap_1_10 kind-pair
  // bins.  L02/L03 close the final two x_pair_beat holes for INCR_WR->WRAP_RD.
  protected task run_gap_1_10_matrix();
    send_pair(0, "L01", axi_tniu_protocol_pkg::OPC_RDW, LEN_BEAT1,
                          axi_tniu_protocol_pkg::OPC_WRW, LEN_BEAT1);

    send_pair(1, "L02", axi_tniu_protocol_pkg::OPC_WR,  LEN_MULTI,
                          axi_tniu_protocol_pkg::OPC_RDW, LEN_BEAT1);

    send_pair(2, "L03", axi_tniu_protocol_pkg::OPC_WR,  LEN_BEAT1,
                          axi_tniu_protocol_pkg::OPC_RDW, LEN_MULTI);
  endtask

  task body();
    case (mode)
      FUNCOV_MULTI_REQ_GAP_GT10: begin
        `uvm_info("SEQ_MULTI_REQ_GAP_HOLES",
                  "Starting gap_gt10 matrix: 11 pairs / 22 requests",
                  UVM_LOW)
        run_gap_gt10_matrix();
      end

      FUNCOV_MULTI_REQ_GAP_1_10: begin
        `uvm_info("SEQ_MULTI_REQ_GAP_HOLES",
                  "Starting gap_1_10 matrix: 3 pairs / 6 requests",
                  UVM_LOW)
        run_gap_1_10_matrix();
      end

      default:
        `uvm_fatal("SEQ_MULTI_REQ_GAP_HOLES",
                   $sformatf("Unsupported mode=%0d", mode))
    endcase

    `uvm_info("SEQ_MULTI_REQ_GAP_HOLES",
              $sformatf("Completed mode=%0d", mode),
              UVM_LOW)
  endtask

endclass : seq_funcov_multi_req_gap_holes

`endif // SEQ_FUNCOV_MULTI_REQ_GAP_HOLES_SV
