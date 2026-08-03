`ifndef SEQ_NORM_WR_SV
`define SEQ_NORM_WR_SV

class seq_norm_wr extends rknp_base_seq;
  `uvm_object_utils(seq_norm_wr)

  function new(string name = "seq_norm_wr");
    super.new(name);
    num_txn = 4;
  endfunction

  task body();
    for (int unsigned i = 0; i < num_txn; i++) begin
      rknp_seq_item it;
      int unsigned  selected_len;

      it           = rknp_seq_item::type_id::create($sformatf("it_%0d", i));
      selected_len = choose_incr_len(i);
      start_item(it);
      if (!it.randomize() with {
            opc        == axi_tniu_protocol_pkg::OPC_WR;
            status     == axi_tniu_protocol_pkg::ST_OK;
            axcache[0] == 1'b0;
            len        == local::selected_len;
          })
        `uvm_fatal("SEQ_NORM_WR", "Randomization failed")
      complete_item(it, "SEQ_NORM_WR");
    end
  endtask
endclass : seq_norm_wr

`endif // SEQ_NORM_WR_SV
