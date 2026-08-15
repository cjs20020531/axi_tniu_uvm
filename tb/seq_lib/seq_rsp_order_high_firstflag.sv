`ifndef SEQ_RSP_ORDER_HIGH_FIRSTFLAG_SV
`define SEQ_RSP_ORDER_HIGH_FIRSTFLAG_SV

// =============================================================================
// Purpose:
//   Put first-of-type special requests (fir_req_flag=1) into rsp_order buffer
//   slots 4..7 so the high bits of buffer_fir_falg/fir_req_buff_index paths
//   toggle.
//
// Method:
//   1) A long normal RD establishes ordering type A.
//   2) Four ERR followers of type A occupy special-buffer slots 0..3.
//   3) Wait until the long normal read response is active.
//   4) Send four ERR RDs with four NEW AXIDs. They are first requests of their
//      respective {AXID,RD} types, so fir_req_flag=1. Because the normal read
//      response is still occupying the RKNP response path, they stay resident
//      in slots 4..7 instead of being dispatched immediately.
//
// Expected toggle targets:
//   buffer_fir_falg[7:4]
//   fir_req_buff_index_hot[7:4]
//   fir_req_buff_index[2]
//   spec_req_ready_hot[7:4]
//   spec_req_ready_index[2]
//   buff_index[2]
//   buff_used[7:4]
//   idle_buff_index_hot[7:5]
// =============================================================================
class seq_rsp_order_high_firstflag extends rknp_base_seq;
  `uvm_object_utils(seq_rsp_order_high_firstflag)

  localparam axi_tniu_protocol_pkg::ordkey_t BLOCK_ORDERKEY = 8'h11;
  localparam logic [31:0] BLOCK_ADDR = 32'h3000_0000;

  function new(string name = "seq_rsp_order_high_firstflag");
    super.new(name);
    num_txn = 9; // one normal blocker + four followers + four first-of-type
  endfunction

  protected task send_directed_read(
    input int unsigned idx,
    input axi_tniu_protocol_pkg::ordkey_t orderkey_v,
    input axi_tniu_protocol_pkg::status_e status_v,
    input logic [7:0] len_v,
    input logic [31:0] addr_v
  );
    rknp_seq_item it;
    it = rknp_seq_item::type_id::create($sformatf("firstflag_it_%0d", idx));

    start_item(it);
    if (!it.randomize() with {
          opc      == axi_tniu_protocol_pkg::OPC_RD;
          status   == local::status_v;
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
    // Type A: orderkey 0x11 folds to AXID 0 with ORDKEY_WITH=8/AXID_WITH=4.
    send_directed_read(
      0,
      BLOCK_ORDERKEY,
      axi_tniu_protocol_pkg::ST_OK,
      8'hff,
      BLOCK_ADDR
    );

    // Occupy special-buffer slots 0..3 with same-type followers.
    for (int unsigned i = 0; i < 4; i++) begin
      send_directed_read(
        i + 1,
        BLOCK_ORDERKEY,
        axi_tniu_protocol_pkg::ST_ERR,
        8'h07,
        32'h3100_0000 + i * 32'h0000_0100
      );
    end

    // The companion test uses a 12-cycle initial AXI-R delay and a 3-cycle beat
    // gap. 200 ns is long enough for the normal response to start, but far
    // shorter than a 32-beat response, so rsp_order remains in NORM_RSP here.
    #200ns;

    // New ordering types. With the repository's XOR orderkey->AXID mapping:
    //   0x01 -> AXID 1, 0x02 -> 2, 0x03 -> 3, 0x04 -> 4.
    // Each one is therefore first-of-type and carries fir_req_flag=1.
    for (int unsigned j = 0; j < 4; j++) begin
      axi_tniu_protocol_pkg::ordkey_t new_orderkey;
      new_orderkey = axi_tniu_protocol_pkg::ordkey_t'(8'h01 + j);
      send_directed_read(
        j + 5,
        new_orderkey,
        axi_tniu_protocol_pkg::ST_ERR,
        8'h07,
        32'h3200_0000 + j * 32'h0000_0100
      );
    end
  endtask
endclass : seq_rsp_order_high_firstflag

`endif // SEQ_RSP_ORDER_HIGH_FIRSTFLAG_SV
