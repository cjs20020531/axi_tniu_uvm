`ifndef SEQ_MIX_SV
`define SEQ_MIX_SV

class seq_mix extends rknp_base_seq;
  `uvm_object_utils(seq_mix)

  function new(string name = "seq_mix");
    super.new(name);
  endfunction

  task body();
    repeat (num_txn) begin
      rknp_seq_item it;
      int unsigned  category;
      bit           randomize_ok;

      it           = rknp_seq_item::type_id::create("it");
      category     = $urandom_range(0, 99);
      randomize_ok = 1'b0;
      start_item(it);

      // Preserve the original request-side mix exactly:
      //   10% request ERR + 20% bufferable write + 70% normal write.
      // AXI response error injection is an independent downstream policy in
      // axi_slave_driver and must not replace any of these request categories.
      if (category < 10) begin
        randomize_ok = it.randomize() with {
          status     == axi_tniu_protocol_pkg::ST_ERR;
          errcode    == axi_tniu_protocol_pkg::EC_ADDR_DEC;
          axcache[0] == 1'b0;
        };
      end
      else if (category < 30) begin
        randomize_ok = it.randomize() with {
          opc inside {axi_tniu_protocol_pkg::OPC_WR,
                      axi_tniu_protocol_pkg::OPC_WRW};
          status     == axi_tniu_protocol_pkg::ST_OK;
          axcache[0] == 1'b1;
        };
      end
      else begin
        randomize_ok = it.randomize() with {
          opc inside {axi_tniu_protocol_pkg::OPC_WR,
                      axi_tniu_protocol_pkg::OPC_WRW};
          status     == axi_tniu_protocol_pkg::ST_OK;
          axcache[0] == 1'b0;
        };
      end

      if (!randomize_ok)
        `uvm_fatal("SEQ_MIX", "Randomization failed")
      complete_item(it, "SEQ_MIX");
    end
  endtask
endclass : seq_mix

`endif // SEQ_MIX_SV
