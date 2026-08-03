`ifndef SEQ_NORM_WRW_SV
`define SEQ_NORM_WRW_SV

class seq_norm_wrw extends rknp_base_seq;
  `uvm_object_utils(seq_norm_wrw)

  function new(string name = "seq_norm_wrw");
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
            opc        == axi_tniu_protocol_pkg::OPC_WRW;
            status     == axi_tniu_protocol_pkg::ST_OK;
            axcache[0] == 1'b0;
            len        == local::selected_len;
            (addr & local::align_mask) == 0;
          })
        `uvm_fatal("SEQ_NORM_WRW", "Randomization failed")
      complete_item(it, "SEQ_NORM_WRW");
    end
  endtask
endclass : seq_norm_wrw

`endif // SEQ_NORM_WRW_SV
