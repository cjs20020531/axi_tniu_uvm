`ifndef SEQ_TIMEOUT_SAME_AXID_PREV_RSP_SV
`define SEQ_TIMEOUT_SAME_AXID_PREV_RSP_SV

// =============================================================================
// File        : seq_timeout_same_axid_prev_rsp.sv
// Description : Single-request building block for
//               test_timeout_same_axid_prev_rsp.
//
// The test starts this sequence once for a normal response and once for a
// watchdog timeout.  Both invocations use the same fixed OrderKey, therefore
// map_ordkey_to_axid() produces the same AXID.
//
// LEN=7 + 8-byte-aligned address is intentional: when the second request times
// out, it also supplies a "full" timeout body shape.
// =============================================================================

class seq_timeout_same_axid_prev_rsp extends rknp_base_seq;
  `uvm_object_utils(seq_timeout_same_axid_prev_rsp)

  bit send_write = 1'b0;

  logic [axi_tniu_protocol_pkg::IID_WITH-1:0]  iid_value;
  logic [axi_tniu_protocol_pkg::TID_WITH-1:0]  tid_value;
  logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] addr_value;

  localparam int unsigned FULL_BEAT_LEN = 7;

  function new(string name = "seq_timeout_same_axid_prev_rsp");
    super.new(name);
    num_txn    = 1;
    iid_value  = 10'h120;
    tid_value  = 10'h220;
    addr_value = 32'h6000_0000;
  endfunction

  task body();
    rknp_seq_item it;
    axi_tniu_protocol_pkg::req_opc_e opc_v;

    opc_v = send_write ? axi_tniu_protocol_pkg::OPC_WR
                       : axi_tniu_protocol_pkg::OPC_RD;

    it = rknp_seq_item::type_id::create("it");

    start_item(it);

    if (!it.randomize() with {
          opc        == local::opc_v;
          status     == axi_tniu_protocol_pkg::ST_OK;
          len        == FULL_BEAT_LEN;

          // 8B aligned + 8B payload => full body, no leading/trailing padding.
          (addr & (axi_tniu_protocol_pkg::NBYTEPERWORD - 1)) == 0;
          addr       == local::addr_value;

          iid        == local::iid_value;
          tid        == local::tid_value;

          // Non-bufferable so a write, if selected, waits for the real B path.
          axcache[0] == 1'b0;

          if (local::use_fixed_orderkey)
            orderkey == local::fixed_orderkey;
        }) begin
      `uvm_fatal(
        "SEQ_TIMEOUT_SAME_AXID",
        $sformatf(
          "Randomization failed: dir=%s orderkey=0x%0h addr=0x%0h",
          send_write ? "WR" : "RD",
          fixed_orderkey,
          addr_value
        )
      )
    end

    complete_item(it, "SEQ_TIMEOUT_SAME_AXID");
  endtask

endclass : seq_timeout_same_axid_prev_rsp

`endif // SEQ_TIMEOUT_SAME_AXID_PREV_RSP_SV
