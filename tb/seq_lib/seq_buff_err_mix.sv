`ifndef SEQ_BUFF_ERR_MIX_SV
`define SEQ_BUFF_ERR_MIX_SV

class seq_buff_err_mix extends rknp_base_seq;
  `uvm_object_utils(seq_buff_err_mix)

  function new(string name = "seq_buff_err_mix");
    super.new(name);
    num_txn = 1;
  endfunction

  task body();
    rknp_seq_item it;

    it = rknp_seq_item::type_id::create("it");
    start_item(it);
    if (!it.randomize() with {
          opc inside {axi_tniu_protocol_pkg::OPC_WR,
                      axi_tniu_protocol_pkg::OPC_WRW};
          status     == axi_tniu_protocol_pkg::ST_ERR;
          errcode    == axi_tniu_protocol_pkg::EC_ADDR_DEC;
          axcache[0] == 1'b1;
        })
      `uvm_fatal("SEQ_BUFF_ERR_MIX", "Randomization failed")
    complete_item(it, "SEQ_BUFF_ERR_MIX");
  endtask
endclass : seq_buff_err_mix

`endif // SEQ_BUFF_ERR_MIX_SV
