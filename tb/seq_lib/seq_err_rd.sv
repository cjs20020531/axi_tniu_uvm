`ifndef SEQ_ERR_RD_SV
`define SEQ_ERR_RD_SV

class seq_err_rd extends rknp_base_seq;
  `uvm_object_utils(seq_err_rd)

  function new(string name = "seq_err_rd");
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
            opc        == axi_tniu_protocol_pkg::OPC_RD;
            status     == axi_tniu_protocol_pkg::ST_ERR;
            errcode    == axi_tniu_protocol_pkg::EC_ADDR_DEC;
            axcache[0] == 1'b0;
            len        == local::selected_len;
          })
        `uvm_fatal("SEQ_ERR_RD", "Randomization failed")
      complete_item(it, "SEQ_ERR_RD");
    end
  endtask
endclass : seq_err_rd

`endif // SEQ_ERR_RD_SV
