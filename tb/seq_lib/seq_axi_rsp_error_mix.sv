// =============================================================================
// File        : seq_axi_rsp_error_mix.sv
// Description : Directed normal RKNP request used by the AXI response-error
//               test.  AXI response policy is selected by the test through
//               axi_tniu_cfg; the RKNP source request itself remains ST_OK.
// =============================================================================
`ifndef SEQ_AXI_RSP_ERROR_MIX_SV
`define SEQ_AXI_RSP_ERROR_MIX_SV

typedef enum bit {
  AXI_RSP_CASE_READ,
  AXI_RSP_CASE_WRITE
} axi_rsp_case_dir_e;

class seq_axi_rsp_error_mix extends rknp_base_seq;
  `uvm_object_utils(seq_axi_rsp_error_mix)

  axi_rsp_case_dir_e request_dir   = AXI_RSP_CASE_READ;
  int unsigned      transfer_bytes = 32;

  function new(string name = "seq_axi_rsp_error_mix");
    super.new(name);
    num_txn = 1;
  endfunction

  task body();
    axi_tniu_protocol_pkg::req_opc_e selected_opc;
    int unsigned                     selected_len;

    if (transfer_bytes == 0 || transfer_bytes > 256)
      `uvm_fatal("SEQ_AXI_RSP_ERR", $sformatf(
        "transfer_bytes=%0d must be in 1..256", transfer_bytes))

    selected_opc = (request_dir == AXI_RSP_CASE_WRITE) ?
                   axi_tniu_protocol_pkg::OPC_WR :
                   axi_tniu_protocol_pkg::OPC_RD;
    selected_len = transfer_bytes - 1;

    for (int unsigned i = 0; i < num_txn; i++) begin
      rknp_seq_item it;

      it = rknp_seq_item::type_id::create($sformatf("it_%0d", i));
      start_item(it);
      if (!it.randomize() with {
            opc        == local::selected_opc;
            status     == axi_tniu_protocol_pkg::ST_OK;
            axcache[0] == 1'b0;       // exclude bufferable early response
            len        == local::selected_len;
            addr[2:0]  == 3'b000;     // aligned 64-bit AXI beats
            if (local::use_fixed_orderkey)
              orderkey == local::fixed_orderkey;
          })
        `uvm_fatal("SEQ_AXI_RSP_ERR", "Request randomization failed")

      complete_item(it, "SEQ_AXI_RSP_ERR");
    end
  endtask

endclass : seq_axi_rsp_error_mix

`endif // SEQ_AXI_RSP_ERROR_MIX_SV
