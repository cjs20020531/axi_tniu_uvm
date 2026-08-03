`ifndef SEQ_ERR_RDW_SV
`define SEQ_ERR_RDW_SV

class seq_err_rdw extends rknp_base_seq;
  `uvm_object_utils(seq_err_rdw)

  function new(string name = "seq_err_rdw");
    super.new(name);
  endfunction

  task body();
    for (int unsigned i = 0; i < num_txn; i++) begin
      rknp_seq_item it;
      int unsigned  selected_len;
      int unsigned  align_mask;

      it           = rknp_seq_item::type_id::create($sformatf("it_%0d", i));
      selected_len = choose_wrap_len();
      align_mask    = force_flit_aligned_addr ? (NBPW - 1) : 1;
      start_item(it);
      if (!it.randomize() with {
            opc        == axi_tniu_protocol_pkg::OPC_RDW;
            status     == axi_tniu_protocol_pkg::ST_ERR;
            errcode    == axi_tniu_protocol_pkg::EC_ADDR_DEC;
            axcache[0] == 1'b0;
            len        == local::selected_len;
            (addr & local::align_mask) == 0;
          })
        `uvm_fatal("SEQ_ERR_RDW", "Randomization failed")
      complete_item(it, "SEQ_ERR_RDW");
    end
  endtask
endclass : seq_err_rdw

`endif // SEQ_ERR_RDW_SV
