`ifndef SEQ_BUFF_MIX_SV
`define SEQ_BUFF_MIX_SV

class seq_buff_mix extends rknp_base_seq;
  `uvm_object_utils(seq_buff_mix)

  function new(string name = "seq_buff_mix");
    super.new(name);
    num_txn = 10;
  endfunction

  task body();
    repeat (num_txn) begin
      rknp_seq_item it;
      bit           selected_bufferable;

      it                  = rknp_seq_item::type_id::create("it");
      selected_bufferable = ($urandom_range(0, 99) < 30);
      start_item(it);
      if (!it.randomize() with {
            status     == axi_tniu_protocol_pkg::ST_OK;
            axcache[0] == local::selected_bufferable;
            if (local::selected_bufferable)
              opc inside {axi_tniu_protocol_pkg::OPC_WR,
                          axi_tniu_protocol_pkg::OPC_WRW};
          })
        `uvm_fatal("SEQ_BUFF_MIX", "Randomization failed")
      complete_item(it, "SEQ_BUFF_MIX");
    end
  endtask
endclass : seq_buff_mix

`endif // SEQ_BUFF_MIX_SV
