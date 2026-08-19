`ifndef SEQ_TIMEOUT_BUSY_CONTEXT_SAME_AXID_SV
`define SEQ_TIMEOUT_BUSY_CONTEXT_SAME_AXID_SV

// =============================================================================
// File        : seq_timeout_busy_context_same_axid.sv
// Description : Configurable one-request sequence for x_busy_context closure.
//
// The paired test runs this sequence as:
//   normal previous response -> current watchdog timeout
// while using one fixed OrderKey/AXID.
//
// "send_write" selects the request/response direction.
// =============================================================================

class seq_timeout_busy_context_same_axid extends rknp_base_seq;
  `uvm_object_utils(seq_timeout_busy_context_same_axid)

  bit send_write = 1'b0;

  logic [axi_tniu_protocol_pkg::IID_WITH-1:0]  iid_value;
  logic [axi_tniu_protocol_pkg::TID_WITH-1:0]  tid_value;
  logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] addr_value;

  localparam int unsigned FULL_BEAT_LEN = 7;

  function new(string name = "seq_timeout_busy_context_same_axid");
    super.new(name);
    num_txn    = 1;
    iid_value  = 10'h180;
    tid_value  = 10'h280;
    addr_value = 32'h6800_0000;
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

          // Keep every request simple and deterministic.
          len        == FULL_BEAT_LEN;
          addr       == local::addr_value;
          (addr & (axi_tniu_protocol_pkg::NBYTEPERWORD - 1)) == 0;

          iid        == local::iid_value;
          tid        == local::tid_value;

          // Disable bufferable early write response.
          axcache[0] == 1'b0;

          if (local::use_fixed_orderkey)
            orderkey == local::fixed_orderkey;
        }) begin
      `uvm_fatal(
        "SEQ_TIMEOUT_BUSY_SAME_AXID",
        $sformatf(
          "Randomization failed: dir=%s orderkey=0x%0h iid=0x%0h tid=0x%0h",
          send_write ? "WR" : "RD",
          fixed_orderkey,
          iid_value,
          tid_value
        )
      )
    end

    complete_item(it, "SEQ_TIMEOUT_BUSY_SAME_AXID");
  endtask

endclass : seq_timeout_busy_context_same_axid

`endif // SEQ_TIMEOUT_BUSY_CONTEXT_SAME_AXID_SV
