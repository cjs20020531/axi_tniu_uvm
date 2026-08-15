`ifndef SEQ_RSP_ORDER_DEEP_FOLLOWERS_SV
`define SEQ_RSP_ORDER_DEEP_FOLLOWERS_SV

// =============================================================================
// Purpose:
//   Drive the rsp_order special-request buffer deep enough to exercise slots
//   4..7 and, in particular, the follower lookup path at high buffer indices.
//
// Method:
//   1) Send one long normal RD for a fixed ordering type {AXID,RD}.
//   2) Before that normal response completes, enqueue 8 ERR RD requests with
//      the same orderkey/opcode. They are followers (fir_req_flag=0) and must
//      wait for their tag count to become current.
//   3) The long normal read releases its req_order head while its 256-byte
//      response still occupies the response path, allowing the 8th follower
//      to enter even though HEAD_BUFF_DEEP is also 8.
//
// Expected toggle targets:
//   buff_used[7:4]
//   idle_buff_index_hot[7:5]
//   spec_req_ready_hot[7:4]
//   spec_req_ready_index[2]
//   buff_index[2]
//   follo_req_buff_index_hot[7:3]
//   follo_req_buff_index[2]
// =============================================================================
class seq_rsp_order_deep_followers extends rknp_base_seq;
  `uvm_object_utils(seq_rsp_order_deep_followers)

  localparam axi_tniu_protocol_pkg::ordkey_t BLOCK_ORDERKEY = 8'h11;
  localparam logic [31:0] BLOCK_ADDR = 32'h1000_0000;

  function new(string name = "seq_rsp_order_deep_followers");
    super.new(name);
    num_txn = 9; // one normal blocker + eight special followers
  endfunction

  protected task send_directed_read(
    input int unsigned idx,
    input axi_tniu_protocol_pkg::ordkey_t orderkey_v,
    input axi_tniu_protocol_pkg::status_e status_v,
    input logic [7:0] len_v,
    input logic [31:0] addr_v
  );
    rknp_seq_item it;
    it = rknp_seq_item::type_id::create($sformatf("deep_it_%0d", idx));

    start_item(it);
    if (!it.randomize() with {
          opc      == axi_tniu_protocol_pkg::OPC_RD;
          status   == local::status_v;
          errcode  == axi_tniu_protocol_pkg::EC_ADDR_DEC;
          orderkey == local::orderkey_v;
          len      == local::len_v;
          addr     == local::addr_v;

          // Keep USER deterministic and non-bufferable. ERR alone makes the
          // follower a special request in EARLY_RSP_MODE=1.
          rknp_user == 1'b0;
          axi_user  == 1'b0;
          axlock    == 1'b0;
          axport    == 3'b000;
          axcache   == 4'b0000;

          // Unique labels make waveform/log tracing straightforward.
          iid == ((10'h100 + local::idx) & 10'h3ff);
          tid == ((10'h200 + local::idx) & 10'h3ff);
        })
      `uvm_fatal("SEQ_RSP_ORDER_DEEP",
                 $sformatf("Randomization failed for item %0d", idx))

    complete_item(it, "SEQ_RSP_ORDER_DEEP");
  endtask

  task body();
    // 256-byte normal read. With the companion test's fixed R beat gap, this
    // produces a long response window while the request path can keep accepting
    // the special followers.
    send_directed_read(
      0,
      BLOCK_ORDERKEY,
      axi_tniu_protocol_pkg::ST_OK,
      8'hff,
      BLOCK_ADDR
    );

    // All eight use exactly the same ordering type as the blocker, so once the
    // first request established tag_name they are followers (fir_req_flag=0).
    for (int unsigned i = 0; i < 8; i++) begin
      send_directed_read(
        i + 1,
        BLOCK_ORDERKEY,
        axi_tniu_protocol_pkg::ST_ERR,
        8'h07,
        32'h2000_0000 + i * 32'h0000_0100
      );
    end
  endtask
endclass : seq_rsp_order_deep_followers

`endif // SEQ_RSP_ORDER_DEEP_FOLLOWERS_SV
