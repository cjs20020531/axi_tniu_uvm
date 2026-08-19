`ifndef SEQ_FUNCOV_B2B_MIX_WRAP_UNALIGNED_SV
`define SEQ_FUNCOV_B2B_MIX_WRAP_UNALIGNED_SV

// =============================================================================
// File        : seq_funcov_b2b_mix_wrap_unaligned.sv
// Description : Directed adjacent mixed-request matrix.
//               Every WRAP operand is forced NOT 8-byte aligned.
//
// Covered request pairs (second-request beat class shown):
//   a. INCR_RD -> WRAP_RD  beat=1
//   b. INCR_RD -> WRAP_RD  beat>1
//   c. INCR_WR -> WRAP_WR  beat=1
//   d. INCR_WR -> WRAP_WR  beat>1
//   e. WRAP_RD -> INCR_RD  beat=1
//   f. WRAP_RD -> INCR_RD  beat>1
//   g. WRAP_WR -> INCR_WR  beat=1
//   h. WRAP_WR -> INCR_WR  beat>1
//   i. INCR_RD -> INCR_WR  beat>1
//   j. INCR_RD -> INCR_WR  beat=1
//   k. WRAP_RD -> WRAP_WR  beat>1
//   l. WRAP_RD -> WRAP_WR  beat=1
//   m. INCR_WR -> INCR_RD  beat>1
//   n. INCR_WR -> INCR_RD  beat>1   (kept exactly as listed in the testplan)
//
// For every WRAP operand:
//   addr[0] = 0 to satisfy the native RKNP WRAP constraint
//   addr[2:0] is one of 2/4/6, therefore NOT 8-byte aligned.
//
// Beat selection:
//   second beat=1 : LEN=7
//   second beat>1 : LEN=15 (case n uses LEN=31)
//
// The current coverage helper classifies true WRAP LEN>=7 from payload size,
// so an unaligned WRAP with LEN=7 still belongs to the beat=1 category.
// =============================================================================
// IMPORTANT:
// This sequence submits each pair as two immediately consecutive UVM sequence
// items (no sequence-side delay and no unrelated request inserted between them).
// Exact zero-idle-cycle packet-to-packet B2B behavior still depends on the RKNP
// driver. The current driver inserts an item boundary between packets.
// =============================================================================

class seq_funcov_b2b_mix_wrap_unaligned extends rknp_base_seq;
  `uvm_object_utils(seq_funcov_b2b_mix_wrap_unaligned)

  localparam int unsigned LEN_BEAT1 = 7;
  localparam int unsigned LEN_MULTI = 15;

  function new(string name = "seq_funcov_b2b_mix_wrap_unaligned");
    super.new(name);
  endfunction

  protected function int unsigned wrap_offset(
      int unsigned case_index,
      int unsigned item_index);
    // Rotate legal 2-byte-aligned, non-8-byte-aligned lanes.
    case ((case_index + item_index) % 3)
      0: return 2;
      1: return 4;
      default: return 6;
    endcase
  endfunction

  protected task send_req(
      axi_tniu_protocol_pkg::req_opc_e req_opc,
      int unsigned                    len_value,
      int unsigned                    case_index,
      int unsigned                    item_index,
      string                          item_name);

    rknp_seq_item it;
    int unsigned addr_low;
    int unsigned offset;

    it = rknp_seq_item::type_id::create(item_name);

    // Separate address windows per case, always away from a 4-KiB boundary.
    addr_low = 12'h100 + (case_index * 12'h040) + (item_index * 12'h020);

    if ((req_opc == axi_tniu_protocol_pkg::OPC_RDW) ||
        (req_opc == axi_tniu_protocol_pkg::OPC_WRW)) begin
      offset   = wrap_offset(case_index, item_index);
      addr_low = (addr_low & 12'hff8) + offset;
    end
    else begin
      // INCR operands are kept aligned so beat=1/>1 is determined by LEN only.
      addr_low = addr_low & 12'hff8;
    end

    start_item(it);

    if (!it.randomize() with {
          opc        == local::req_opc;
          status     == axi_tniu_protocol_pkg::ST_OK;
          errcode    == axi_tniu_protocol_pkg::EC_TARGET;
          len        == local::len_value;
          axcache[0] == 1'b0;

          addr[11:0] == local::addr_low;
        }) begin
      `uvm_fatal("SEQ_B2B_MIX_UALIGN",
                 $sformatf(
                   "Randomization failed: case=%0d item=%0d opc=%s len=%0d addr_low=0x%03x",
                   case_index, item_index, req_opc.name(),
                   len_value, addr_low))
    end

    if (it.is_wrap()) begin
      if ((int'(it.addr) & 1) != 0)
        `uvm_fatal("SEQ_B2B_MIX_UALIGN",
                   $sformatf("WRAP address lost 2-byte alignment: addr=0x%0h",
                             it.addr))

      if ((int'(it.addr) & (axi_tniu_protocol_pkg::NBYTEPERWORD - 1)) == 0)
        `uvm_fatal("SEQ_B2B_MIX_UALIGN",
                   $sformatf("WRAP address unexpectedly 8-byte aligned: addr=0x%0h",
                             it.addr))
    end

    complete_item(it, "SEQ_B2B_MIX_UALIGN");
  endtask

  protected task send_pair(
      int unsigned                    case_index,
      string                          case_name,
      axi_tniu_protocol_pkg::req_opc_e first_opc,
      axi_tniu_protocol_pkg::req_opc_e second_opc,
      int unsigned                    second_len);

    `uvm_info("SEQ_B2B_MIX_UALIGN",
              $sformatf("CASE %s : %s -> %s, second LEN=%0d",
                        case_name, first_opc.name(), second_opc.name(),
                        second_len),
              UVM_LOW)

    send_req(first_opc, LEN_BEAT1, case_index, 0,
             $sformatf("case_%s_first", case_name));

    send_req(second_opc, second_len, case_index, 1,
             $sformatf("case_%s_second", case_name));
  endtask

  task body();
    // a
    send_pair(0,  "a", axi_tniu_protocol_pkg::OPC_RD,
                       axi_tniu_protocol_pkg::OPC_RDW, LEN_BEAT1);

    // b
    send_pair(1,  "b", axi_tniu_protocol_pkg::OPC_RD,
                       axi_tniu_protocol_pkg::OPC_RDW, LEN_MULTI);

    // c
    send_pair(2,  "c", axi_tniu_protocol_pkg::OPC_WR,
                       axi_tniu_protocol_pkg::OPC_WRW, LEN_BEAT1);

    // d
    send_pair(3,  "d", axi_tniu_protocol_pkg::OPC_WR,
                       axi_tniu_protocol_pkg::OPC_WRW, LEN_MULTI);

    // e
    send_pair(4,  "e", axi_tniu_protocol_pkg::OPC_RDW,
                       axi_tniu_protocol_pkg::OPC_RD, LEN_BEAT1);

    // f
    send_pair(5,  "f", axi_tniu_protocol_pkg::OPC_RDW,
                       axi_tniu_protocol_pkg::OPC_RD, LEN_MULTI);

    // g
    send_pair(6,  "g", axi_tniu_protocol_pkg::OPC_WRW,
                       axi_tniu_protocol_pkg::OPC_WR, LEN_BEAT1);

    // h
    send_pair(7,  "h", axi_tniu_protocol_pkg::OPC_WRW,
                       axi_tniu_protocol_pkg::OPC_WR, LEN_MULTI);

    // i
    send_pair(8,  "i", axi_tniu_protocol_pkg::OPC_RD,
                       axi_tniu_protocol_pkg::OPC_WR, LEN_MULTI);

    // j
    send_pair(9,  "j", axi_tniu_protocol_pkg::OPC_RD,
                       axi_tniu_protocol_pkg::OPC_WR, LEN_BEAT1);

    // k
    send_pair(10, "k", axi_tniu_protocol_pkg::OPC_RDW,
                       axi_tniu_protocol_pkg::OPC_WRW, LEN_MULTI);

    // l
    send_pair(11, "l", axi_tniu_protocol_pkg::OPC_RDW,
                       axi_tniu_protocol_pkg::OPC_WRW, LEN_BEAT1);

    // m
    send_pair(12, "m", axi_tniu_protocol_pkg::OPC_WR,
                       axi_tniu_protocol_pkg::OPC_RD, LEN_MULTI);

    // n: kept literally as a second INCR_RD multi-beat case.
    send_pair(13, "n", axi_tniu_protocol_pkg::OPC_WR,
                       axi_tniu_protocol_pkg::OPC_RD, 31);

    `uvm_info("SEQ_B2B_MIX_UALIGN",
              "Completed 14 unaligned-WRAP mixed-request pairs (28 requests)",
              UVM_LOW)
  endtask

endclass : seq_funcov_b2b_mix_wrap_unaligned

`endif // SEQ_FUNCOV_B2B_MIX_WRAP_UNALIGNED_SV
