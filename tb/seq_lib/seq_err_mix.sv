`ifndef SEQ_ERR_MIX_SV
`define SEQ_ERR_MIX_SV

class seq_err_mix extends rknp_base_seq;
  `uvm_object_utils(seq_err_mix)

  function new(string name = "seq_err_mix");
    super.new(name);
    num_txn = 10;
  endfunction

  task body();
    repeat (num_txn) begin
      rknp_seq_item it;

      it = rknp_seq_item::type_id::create("it");
      start_item(it);
      if (!it.randomize() with {
            opc inside {axi_tniu_protocol_pkg::OPC_RD,
                        axi_tniu_protocol_pkg::OPC_WR,
                        axi_tniu_protocol_pkg::OPC_RDW,
                        axi_tniu_protocol_pkg::OPC_WRW};
            status dist {axi_tniu_protocol_pkg::ST_OK  := 70,
                         axi_tniu_protocol_pkg::ST_ERR := 30};
            errcode    == axi_tniu_protocol_pkg::EC_ADDR_DEC;
            axcache[0] == 1'b0;
            if (local::use_fixed_orderkey)
              orderkey == local::fixed_orderkey;
          })
        `uvm_fatal("SEQ_ERR_MIX", "Randomization failed")
      complete_item(it, "SEQ_ERR_MIX");
    end
  endtask
endclass : seq_err_mix

`endif // SEQ_ERR_MIX_SV
