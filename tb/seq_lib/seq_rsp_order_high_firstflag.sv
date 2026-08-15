`ifndef SEQ_RSP_ORDER_HIGH_FIRSTFLAG_SV
`define SEQ_RSP_ORDER_HIGH_FIRSTFLAG_SV

// =============================================================================
// Purpose:
//   Close the remaining rsp_order slot7 first-request toggle holes.
//
// Key idea:
//   Start one LONG SPECIAL ERR read.  Its head/spec entry is deleted when the
//   special response is dispatched, but its 256-byte generated error response
//   keeps rsp_order in SPEC_RSP for 32 flits.
//
//   While that response is active, send eight ERR reads with eight DIFFERENT
//   AXIDs.  Each request is first-of-type (fir_req_flag=1), and no special
//   request can dispatch before the current special-response tail.  Therefore
//   all eight requests remain resident simultaneously and fill slots 0..7.
//
//   At the blocker tail, spec_req_ready_index uses lowest-index priority.
//   Slots 0..6 are dispatched/cleared first; eventually slot7 becomes the
//   lowest remaining first-of-type request, which forces:
//       buffer_fir_falg[7]       = 1
//       fir_req_buff_index_hot[7]= 1
//       spec_req_ready_hot[7]    = 1
//       buff_index               = 7
//
// Main toggle targets:
//   buff_used[7]
//   buffer_fir_falg[7]
//   fir_req_buff_index_hot[7]
//   spec_req_ready_hot[7]
// =============================================================================
class seq_rsp_order_high_firstflag extends rknp_base_seq;
  `uvm_object_utils(seq_rsp_order_high_firstflag)

  // Blocker uses AXID 15 (0x0f -> 0xf).  The eight queued requests below use
  // AXID 1..8, so none shares the blocker's ordering type.
  localparam axi_tniu_protocol_pkg::ordkey_t BLOCK_ORDERKEY = 8'h0f;
  localparam logic [31:0] BLOCK_ADDR = 32'h3000_0000;

  function new(string name = "seq_rsp_order_high_firstflag");
    super.new(name);
    num_txn = 9; // 1 long special blocker + 8 first-of-type special requests
  endfunction

  protected task send_directed_read(
    input int unsigned idx,
    input axi_tniu_protocol_pkg::ordkey_t orderkey_v,
    input logic [7:0] len_v,
    input logic [31:0] addr_v
  );
    rknp_seq_item it;

    it = rknp_seq_item::type_id::create($sformatf("firstflag_it_%0d", idx));

    start_item(it);
    if (!it.randomize() with {
          opc      == axi_tniu_protocol_pkg::OPC_RD;
          status   == axi_tniu_protocol_pkg::ST_ERR;
          errcode  == axi_tniu_protocol_pkg::EC_ADDR_DEC;
          orderkey == local::orderkey_v;
          len      == local::len_v;
          addr     == local::addr_v;

          rknp_user == 1'b0;
          axi_user  == 1'b0;
          axlock    == 1'b0;
          axport    == 3'b000;
          axcache   == 4'b0000;

          iid == ((10'h180 + local::idx) & 10'h3ff);
          tid == ((10'h280 + local::idx) & 10'h3ff);
        })
      `uvm_fatal("SEQ_RSP_ORDER_FIRSTFLAG",
                 $sformatf("Randomization failed for item %0d", idx))

    complete_item(it, "SEQ_RSP_ORDER_FIRSTFLAG");
  endtask

  task body();
    // -------------------------------------------------------------------------
    // Long SPECIAL blocker: 256B aligned ERR read -> 32 generated response flits.
    // It is removed from the request/spec buffers at dispatch, leaving all eight
    // req_order entries available for the requests below.
    // -------------------------------------------------------------------------
    send_directed_read(
      0,
      BLOCK_ORDERKEY,
      8'hff,
      BLOCK_ADDR
    );

    // -------------------------------------------------------------------------
    // Eight new ordering types.
    //
    // Current mapping for an 8-bit OrderKey and 4-bit AXID is:
    //   AXID = orderkey[3:0] ^ orderkey[7:4]
    //
    // 0x01..0x08 therefore map to AXID 1..8.  All are distinct from each other
    // and from BLOCK_ORDERKEY/AXID15, so every request is first-of-type and
    // carries fir_req_flag=1.
    // -------------------------------------------------------------------------
    for (int unsigned j = 0; j < 8; j++) begin
      axi_tniu_protocol_pkg::ordkey_t new_orderkey;

      new_orderkey = axi_tniu_protocol_pkg::ordkey_t'(8'h01 + j);

      send_directed_read(
        j + 1,
        new_orderkey,
        8'h07, // one-flit special response after it is selected
        32'h3200_0000 + j * 32'h0000_0100
      );
    end
  endtask

endclass : seq_rsp_order_high_firstflag

`endif // SEQ_RSP_ORDER_HIGH_FIRSTFLAG_SV
