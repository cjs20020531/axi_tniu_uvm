`ifndef SEQ_ADDROL_RAW_SV
`define SEQ_ADDROL_RAW_SV

// =============================================================================
// File        : seq_addrol_raw.sv
// Description : Directed RAW address-overlap coverage sequence.
//
// Target covergroup:
//   cg_addr_overlap
//
// This sequence covers, for flow=RAW:
//   1) cp_overlap_bytes = 1..63
//   2) prev/current INCR/WRAP values
//   3) all four RAW burst-pair cross bins:
//        INCR_WR -> INCR_RD
//        INCR_WR -> WRAP_RD
//        WRAP_WR -> INCR_RD
//        WRAP_WR -> WRAP_RD
//
// The first request of every pair is always a write, because cg_addr_overlap
// samples RAW only when an overlapping read follows a write.
// =============================================================================

class seq_addrol_raw extends rknp_base_seq;
  `uvm_object_utils(seq_addrol_raw)

  localparam int unsigned PAYLOAD_BYTES = 64;
  localparam int unsigned REQ_LEN       = PAYLOAD_BYTES - 1; // LEN=63
  localparam int unsigned PAIR_STRIDE   = 32'h0000_0400;
  localparam int unsigned CROSS_OVERLAP = 16;

  function new(string name = "seq_addrol_raw");
    super.new(name);
  endfunction

  protected task send_req(
      bit is_read,
      bit wrap,
      logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] addr_v,
      string item_name);

    rknp_seq_item it;
    axi_tniu_protocol_pkg::req_opc_e opc_v;

    if (is_read)
      opc_v = wrap ? axi_tniu_protocol_pkg::OPC_RDW
                   : axi_tniu_protocol_pkg::OPC_RD;
    else
      opc_v = wrap ? axi_tniu_protocol_pkg::OPC_WRW
                   : axi_tniu_protocol_pkg::OPC_WR;

    it = rknp_seq_item::type_id::create(item_name);

    start_item(it);

    if (!it.randomize() with {
          opc        == local::opc_v;
          status     == axi_tniu_protocol_pkg::ST_OK;
          len        == REQ_LEN;
          addr       == local::addr_v;

          subr       == '0;
          rknp_user  == 1'b0;
          axi_user   == 1'b0;
          axlock     == 1'b0;
          axport     == 3'b000;
          axcache    == 4'b0000;
        }) begin
      `uvm_fatal(
        "SEQ_ADDROL_RAW",
        $sformatf("Randomization failed: read=%0b wrap=%0b addr=0x%0h len=%0d",
                  is_read, wrap, addr_v, REQ_LEN)
      )
    end

    if (wrap &&
        ((int'(it.addr) &
          (axi_tniu_protocol_pkg::NBYTEPERWORD - 1)) != 0)) begin
      `uvm_fatal(
        "SEQ_ADDROL_RAW",
        $sformatf("WRAP address is not flit aligned: 0x%0h", it.addr)
      )
    end

    complete_item(it, "SEQ_ADDROL_RAW");
  endtask

  // ---------------------------------------------------------------------------
  // Send one adjacent RAW pair:
  //   previous = write
  //   current  = read
  // ---------------------------------------------------------------------------
  protected task send_raw_pair(
      bit prev_wrap,
      bit cur_wrap,
      int unsigned overlap,
      logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] base_addr,
      string pair_name);

    logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] cur_addr;

    if ((overlap < 1) || (overlap > 63))
      `uvm_fatal("SEQ_ADDROL_RAW",
                 $sformatf("Illegal overlap=%0d, expected 1..63", overlap))

    cur_addr = base_addr + (PAYLOAD_BYTES - overlap);

    send_req(1'b0, prev_wrap, base_addr,
             $sformatf("%s_write", pair_name));

    send_req(1'b1, cur_wrap, cur_addr,
             $sformatf("%s_read", pair_name));
  endtask

  task body();
    logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] base_addr;

    `uvm_info(
      "SEQ_ADDROL_RAW",
      "Start RAW overlap full-coverage sweep",
      UVM_LOW
    )

    // -------------------------------------------------------------------------
    // Phase A:
    // Hit every overlap-size bin 1..63 using INCR_WR -> INCR_RD.
    //
    // After each pair the previous request is a read.  Therefore the transition
    // from that read to the next pair's write is ignored by cg_addr_overlap,
    // which keeps these directed pairs clean.
    // -------------------------------------------------------------------------
    for (int unsigned ov = 1; ov <= 63; ov++) begin
      base_addr = 64'h0000_0000_3000_0000 +
                  (ov * PAIR_STRIDE);

      send_raw_pair(
        1'b0,                       // previous INCR write
        1'b0,                       // current  INCR read
        ov,
        base_addr,
        $sformatf("raw_overlap_%0d", ov)
      );
    end

    // -------------------------------------------------------------------------
    // Phase B:
    // Complete the remaining RAW burst-pair cross bins.
    // overlap=16 gives an aligned 48-byte start delta.
    // -------------------------------------------------------------------------

    // INCR_WR -> WRAP_RD
    base_addr = 64'h0000_0000_4000_0000;
    send_raw_pair(1'b0, 1'b1, CROSS_OVERLAP, base_addr,
                  "raw_incr_to_wrap");

    // WRAP_WR -> INCR_RD
    base_addr = 64'h0000_0000_4000_1000;
    send_raw_pair(1'b1, 1'b0, CROSS_OVERLAP, base_addr,
                  "raw_wrap_to_incr");

    // WRAP_WR -> WRAP_RD
    base_addr = 64'h0000_0000_4000_2000;
    send_raw_pair(1'b1, 1'b1, CROSS_OVERLAP, base_addr,
                  "raw_wrap_to_wrap");

    `uvm_info(
      "SEQ_ADDROL_RAW",
      "Completed RAW coverage: overlap=1..63 + all INCR/WRAP pair types",
      UVM_LOW
    )
  endtask

endclass : seq_addrol_raw

`endif // SEQ_ADDROL_RAW_SV
