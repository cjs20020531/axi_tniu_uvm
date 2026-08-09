`ifndef SEQ_NORM_MIX_SV
`define SEQ_NORM_MIX_SV

class seq_norm_mix extends rknp_base_seq;
  `uvm_object_utils(seq_norm_mix)

  function new(string name = "seq_norm_mix");
    super.new(name);
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
            status     == axi_tniu_protocol_pkg::ST_OK;
            axcache[0] == 1'b0;
            if (local::use_fixed_orderkey)
              orderkey == local::fixed_orderkey;
          })
        `uvm_fatal("SEQ_NORM_MIX", "Randomization failed")
      complete_item(it, "SEQ_NORM_MIX");
    end
  endtask
endclass : seq_norm_mix

`endif // SEQ_NORM_MIX_SV
