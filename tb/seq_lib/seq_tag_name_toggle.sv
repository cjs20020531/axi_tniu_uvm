// =============================================================================
// File        : seq_tag_name_toggle.sv
// Description : Directed stimulus for reqo2rspo_tag_name toggle coverage.
//               One sequence instance fills all eight tag-name entries with
//               eight different AXIDs and one common read/write direction.
// =============================================================================
`ifndef SEQ_TAG_NAME_TOGGLE_SV
`define SEQ_TAG_NAME_TOGGLE_SV

class seq_tag_name_toggle extends rknp_base_seq;
  `uvm_object_utils(seq_tag_name_toggle)

  // Round B uses the bitwise complement of round A/C AXIDs.
  bit invert_axid   = 1'b0;
  bit send_write    = 1'b1;

  function new(string name = "seq_tag_name_toggle");
    super.new(name);
    num_txn = 8;
  endfunction

  task body();
    if (num_txn != 8)
      `uvm_fatal("SEQ_TAG_TOGGLE", "num_txn must be 8 to fill every tag_name entry")

    for (int unsigned i = 0; i < num_txn; i++) begin
      rknp_seq_item                         it;
      axi_tniu_protocol_pkg::req_opc_e      selected_opc;
      logic [3:0]                           selected_axid;
      logic [axi_tniu_protocol_pkg::ORDKEY_WITH-1:0] selected_orderkey;
      logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0]   selected_addr;

      // With ORDKEY_WITH=8 and AXID_WITH=4, req_order maps:
      //   AXID = orderkey[3:0] ^ orderkey[7:4].
      // Keeping the high nibble zero makes OrderKey[3:0] the desired AXID.
      selected_axid     = invert_axid ? (i[3:0] ^ 4'hf) : i[3:0];
      selected_orderkey = {{(axi_tniu_protocol_pkg::ORDKEY_WITH-4){1'b0}},
                           selected_axid};
      selected_opc      = send_write ? axi_tniu_protocol_pkg::OPC_WR
                                     : axi_tniu_protocol_pkg::OPC_RD;
      selected_addr     = 32'h1000_0000 + (i << 6);

      it = rknp_seq_item::type_id::create($sformatf("it_%0d", i));
      start_item(it);
      if (!it.randomize() with {
            opc        == local::selected_opc;
            orderkey   == local::selected_orderkey;
            status     == axi_tniu_protocol_pkg::ST_OK;
            axcache[0] == 1'b0;
            len        == 0;
            addr       == local::selected_addr;
          })
        `uvm_fatal("SEQ_TAG_TOGGLE", $sformatf(
          "Randomization failed: item=%0d AXID=0x%0h write=%0b",
          i, selected_axid, send_write))

      complete_item(it, "SEQ_TAG_TOGGLE");
    end
  endtask

endclass : seq_tag_name_toggle

`endif // SEQ_TAG_NAME_TOGGLE_SV
