`ifndef SEQ_BUFF_ERR_MIX_SV
`define SEQ_BUFF_ERR_MIX_SV

class seq_buff_err_mix extends rknp_base_seq;
  `uvm_object_utils(seq_buff_err_mix)

  localparam int unsigned REQ_COUNT = 2;
  localparam int unsigned REQ_LEN   = 7; // 8 bytes; legal for WR and WRW

  function new(string name = "seq_buff_err_mix");
    super.new(name);
    num_txn = REQ_COUNT;
  endfunction

  // Send one deterministic ERROR + bufferable write.  special_class_of()
  // classifies this combination as SPEC_BOTH.  The caller selects WR or WRW so
  // cp_special_kind does not depend on random opcode selection.
  protected task send_one(
      axi_tniu_protocol_pkg::req_opc_e req_opc,
      int unsigned                    index);

    rknp_seq_item it;
    logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] addr_v;

    // Keep both requests 8-byte aligned and give them distinct transaction
    // addresses.  The WRW request therefore also satisfies c_wrap_addr.
    addr_v = 32'h7400_0000 + index * 32'h0000_0100;

    it = rknp_seq_item::type_id::create(
           $sformatf("%s_both_%s", get_name(),
                     (req_opc == axi_tniu_protocol_pkg::OPC_WRW)
                       ? "wrap_wr" : "incr_wr"));

    start_item(it);

    if (!it.randomize() with {
          opc        == local::req_opc;
          status     == axi_tniu_protocol_pkg::ST_ERR;
          errcode    == axi_tniu_protocol_pkg::EC_ADDR_DEC;
          axcache[0] == 1'b1;
          len        == local::REQ_LEN;
          addr       == local::addr_v;
        }) begin
      `uvm_fatal(
        "SEQ_BUFF_ERR_MIX",
        $sformatf("Randomization failed: opc=%s index=%0d",
                  req_opc.name(), index)
      )
    end

    complete_item(it, "SEQ_BUFF_ERR_MIX");
  endtask

  task body();
    `uvm_info(
      "SEQ_BUFF_ERR_MIX",
      "Send directed SPEC_BOTH requests: INCR write followed by WRAP write",
      UVM_LOW
    )

    // Guarantees both cp_special_kind coverage goals:
    //   SPEC_BOTH + K_INCR_WR -> both_incr_wr
    //   SPEC_BOTH + K_WRAP_WR -> both_wrap_wr
    send_one(axi_tniu_protocol_pkg::OPC_WR,  0);
    send_one(axi_tniu_protocol_pkg::OPC_WRW, 1);
  endtask
endclass : seq_buff_err_mix

`endif // SEQ_BUFF_ERR_MIX_SV
