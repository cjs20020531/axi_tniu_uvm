`ifndef SEQ_ADDROL_WAW_SV
`define SEQ_ADDROL_WAW_SV

// =============================================================================
// File        : seq_addrol_waw.sv
// Description : Directed WAW address-overlap coverage sequence.
//
// Target covergroup:
//   cg_addr_overlap
//
// This sequence covers, for flow=WAW:
//   1) cp_overlap_bytes = 1..63
//   2) prev/current INCR/WRAP values
//   3) all four WAW burst-pair cross bins:
//        INCR -> INCR
//        INCR -> WRAP
//        WRAP -> INCR
//        WRAP -> WRAP
//
// The current coverage model computes overlap linearly from:
//   [ADDR, ADDR+LEN]
//
// Therefore two 64-byte requests (LEN=63) with:
//   req0.addr = BASE
//   req1.addr = BASE + (64-overlap)
// produce exactly "overlap" bytes.
//
// Cross-pair bases are separated by a large stride so the second request of
// one pair does not accidentally overlap the first request of the next pair.
// =============================================================================

class seq_addrol_waw extends rknp_base_seq;
  `uvm_object_utils(seq_addrol_waw)

  localparam int unsigned PAYLOAD_BYTES = 64;
  localparam int unsigned REQ_LEN       = PAYLOAD_BYTES - 1; // LEN=63
  localparam int unsigned PAIR_STRIDE   = 32'h0000_0400;
  localparam int unsigned CROSS_OVERLAP = 16;

  function new(string name = "seq_addrol_waw");
    super.new(name);
  endfunction

  // ---------------------------------------------------------------------------
  // Send one normal write request.
  // wrap=0 -> OPC_WR
  // wrap=1 -> OPC_WRW
  // ---------------------------------------------------------------------------
  protected task send_write(
      bit wrap,
      logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] addr_v,
      string item_name);

    rknp_seq_item it;
    axi_tniu_protocol_pkg::req_opc_e opc_v;

    opc_v = wrap ? axi_tniu_protocol_pkg::OPC_WRW
                 : axi_tniu_protocol_pkg::OPC_WR;

    it = rknp_seq_item::type_id::create(item_name);

    start_item(it);

    if (!it.randomize() with {
          opc        == local::opc_v;
          status     == axi_tniu_protocol_pkg::ST_OK;
          len        == REQ_LEN;
          addr       == local::addr_v;

          // Keep this test focused on address-overlap ordering only.
          subr       == '0;
          rknp_user  == 1'b0;
          axi_user   == 1'b0;
          axlock     == 1'b0;
          axport     == 3'b000;
          axcache    == 4'b0000;
        }) begin
      `uvm_fatal(
        "SEQ_ADDROL_WAW",
        $sformatf("Randomization failed: wrap=%0b addr=0x%0h len=%0d",
                  wrap, addr_v, REQ_LEN)
      )
    end

    // WRAP requests in the current transaction model require at least 2-byte
    // address alignment.  All WRAP addresses used below are actually 8B aligned.
    if (wrap &&
        ((int'(it.addr) &
          (axi_tniu_protocol_pkg::NBYTEPERWORD - 1)) != 0)) begin
      `uvm_fatal(
        "SEQ_ADDROL_WAW",
        $sformatf("WRAP write address is not flit aligned: 0x%0h", it.addr)
      )
    end

    complete_item(it, "SEQ_ADDROL_WAW");
  endtask

  // ---------------------------------------------------------------------------
  // Send one adjacent WAW pair with an exact linear overlap size.
  // ---------------------------------------------------------------------------
  protected task send_waw_pair(
      bit prev_wrap,
      bit cur_wrap,
      int unsigned overlap,
      logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] base_addr,
      string pair_name);

    logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] cur_addr;

    if ((overlap < 1) || (overlap > 63))
      `uvm_fatal("SEQ_ADDROL_WAW",
                 $sformatf("Illegal overlap=%0d, expected 1..63", overlap))

    cur_addr = base_addr + (PAYLOAD_BYTES - overlap);

    send_write(prev_wrap, base_addr,
               $sformatf("%s_prev", pair_name));
    send_write(cur_wrap, cur_addr,
               $sformatf("%s_cur", pair_name));
  endtask

  task body();
    logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] base_addr;

    `uvm_info(
      "SEQ_ADDROL_WAW",
      "Start WAW overlap full-coverage sweep",
      UVM_LOW
    )

    // -------------------------------------------------------------------------
    // Phase A:
    // Hit every cp_overlap_bytes bin 1..63.
    //
    // Use INCR->INCR here because INCR addresses have no WRAP 2-byte alignment
    // restriction, so every overlap byte count can be generated exactly.
    // This phase also covers WAW x INCR x INCR.
    // -------------------------------------------------------------------------
    for (int unsigned ov = 1; ov <= 63; ov++) begin
      base_addr = 64'h0000_0000_1000_0000 +
                  (ov * PAIR_STRIDE);

      send_waw_pair(
        1'b0,                       // prev INCR write
        1'b0,                       // cur  INCR write
        ov,
        base_addr,
        $sformatf("waw_overlap_%0d", ov)
      );
    end

    // -------------------------------------------------------------------------
    // Phase B:
    // Complete the remaining WAW burst-pair cross bins.
    //
    // CROSS_OVERLAP=16 -> address delta = 48 bytes, which is 8B aligned.
    // Therefore every WRAP address in these pairs remains legal/aligned.
    // -------------------------------------------------------------------------

    // INCR -> WRAP
    base_addr = 64'h0000_0000_2000_0000;
    send_waw_pair(1'b0, 1'b1, CROSS_OVERLAP, base_addr,
                  "waw_incr_to_wrap");

    // WRAP -> INCR
    base_addr = 64'h0000_0000_2000_1000;
    send_waw_pair(1'b1, 1'b0, CROSS_OVERLAP, base_addr,
                  "waw_wrap_to_incr");

    // WRAP -> WRAP
    base_addr = 64'h0000_0000_2000_2000;
    send_waw_pair(1'b1, 1'b1, CROSS_OVERLAP, base_addr,
                  "waw_wrap_to_wrap");

    `uvm_info(
      "SEQ_ADDROL_WAW",
      "Completed WAW coverage: overlap=1..63 + all INCR/WRAP pair types",
      UVM_LOW
    )
  endtask

endclass : seq_addrol_waw

`endif // SEQ_ADDROL_WAW_SV
