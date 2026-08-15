`ifndef SEQ_RSP_ORDER_DEEP_FOLLOWERS_SV
`define SEQ_RSP_ORDER_DEEP_FOLLOWERS_SV

// =============================================================================
// Purpose:
//   Close the remaining rsp_order slot7 follower-path toggle holes.
//
// Key idea:
//   Use a LONG SPECIAL ERR read as the response-path blocker, not a normal AXI
//   read.  When the blocker is dispatched, rsp_order removes its special-buffer
//   entry and req_order head immediately, but the generated 256-byte RKNP error
//   response keeps cur_state==SPEC_RSP for 32 response flits.
//
//   During those 32 flits, eight additional same-type ERR reads can all enter
//   req_order + rsp_order.  Because no new special response may dispatch until
//   the current special-response tail, the eight requests remain resident and
//   fill special-buffer slots 0..7.
//
//   The requests use one {AXID,RD} ordering type.  After the current tag advances,
//   the matching follower walks through all saved tags, eventually making slot7
//   the matching follower.
//
// Main toggle targets:
//   buff_used[7]
//   spec_req_ready_hot[7]
//   follo_req_buff_index_hot[7]
//
// Side effects:
//   spec_req_ready_index[2:0], buff_index[2:0] and related low/high index logic
//   continue to toggle as the chain is drained.
// =============================================================================
class seq_rsp_order_deep_followers extends rknp_base_seq;
  `uvm_object_utils(seq_rsp_order_deep_followers)

  // 8'h11 maps to AXID 0 with the current OrderKey->AXID XOR mapping.
  localparam axi_tniu_protocol_pkg::ordkey_t FOLLOW_ORDERKEY = 8'h11;
  localparam logic [31:0] BLOCK_ADDR = 32'h1000_0000;

  function new(string name = "seq_rsp_order_deep_followers");
    super.new(name);
    num_txn = 9; // 1 long special blocker + 8 same-type special requests
  endfunction

  protected task send_directed_read(
    input int unsigned idx,
    input axi_tniu_protocol_pkg::ordkey_t orderkey_v,
    input logic [7:0] len_v,
    input logic [31:0] addr_v
  );
    rknp_seq_item it;

    it = rknp_seq_item::type_id::create($sformatf("deep_it_%0d", idx));

    start_item(it);
    if (!it.randomize() with {
          opc      == axi_tniu_protocol_pkg::OPC_RD;
          status   == axi_tniu_protocol_pkg::ST_ERR;
          errcode  == axi_tniu_protocol_pkg::EC_ADDR_DEC;
          orderkey == local::orderkey_v;
          len      == local::len_v;
          addr     == local::addr_v;

          // ERR is enough to select the special-response path.
          // Keep bufferable disabled so only the ERR mechanism is exercised.
          rknp_user == 1'b0;
          axi_user  == 1'b0;
          axlock    == 1'b0;
          axport    == 3'b000;
          axcache   == 4'b0000;

          // Unique labels make log/waveform tracing deterministic.
          iid == ((10'h100 + local::idx) & 10'h3ff);
          tid == ((10'h200 + local::idx) & 10'h3ff);
        })
      `uvm_fatal("SEQ_RSP_ORDER_DEEP",
                 $sformatf("Randomization failed for item %0d", idx))

    complete_item(it, "SEQ_RSP_ORDER_DEEP");
  endtask

  task body();
    // -------------------------------------------------------------------------
    // Long SPECIAL blocker.
    //
    // Aligned addr + len=8'hff => 256 bytes => 32 RKNP response flits at
    // NBYTEPERWORD=8.  Because status=ERR, there is no AXI transaction.
    //
    // The blocker is removed from req_order/spec_req_buffer when its special
    // response starts, so it does NOT consume one of the eight head slots while
    // the following eight requests are being accumulated.
    // -------------------------------------------------------------------------
    send_directed_read(
      0,
      FOLLOW_ORDERKEY,
      8'hff,
      BLOCK_ADDR
    );

    // -------------------------------------------------------------------------
    // Eight same-type special requests.
    //
    // They are issued immediately while the 32-flit blocker response is active.
    // Depending on the exact first-dispatch cycle, the first one may either
    // preserve the old tag_name or re-create it as first-of-type; requests after
    // it are followers.  In either timing case, after the blocker is removed,
    // all eight requests can coexist and occupy rsp_order slots 0..7.
    //
    // The tag chain then makes the next matching follower advance through the
    // resident entries until follo_req_buff_index_hot[7] becomes 1.
    // -------------------------------------------------------------------------
    for (int unsigned i = 0; i < 8; i++) begin
      send_directed_read(
        i + 1,
        FOLLOW_ORDERKEY,
        8'h07, // 8-byte, one-flit special response when later dispatched
        32'h2000_0000 + i * 32'h0000_0100
      );
    end
  endtask

endclass : seq_rsp_order_deep_followers

`endif // SEQ_RSP_ORDER_DEEP_FOLLOWERS_SV
