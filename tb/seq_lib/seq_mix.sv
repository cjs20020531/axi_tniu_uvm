`ifndef SEQ_MIX_SV
`define SEQ_MIX_SV

class seq_mix extends rknp_base_seq;
  `uvm_object_utils(seq_mix)

  function new(string name = "seq_mix");
    super.new(name);
  endfunction

  task body();
    int unsigned category;
    int unsigned n_err_rd;
    int unsigned n_err_wr;
    int unsigned n_bufferable_wr;
    int unsigned n_normal_rd;
    int unsigned n_normal_wr;

    n_err_rd        = 0;
    n_err_wr        = 0;
    n_bufferable_wr = 0;
    n_normal_rd     = 0;
    n_normal_wr     = 0;

    repeat (num_txn) begin
      rknp_seq_item item;
      bit randomize_ok;

      item         = rknp_seq_item::type_id::create("mix_item");
      category     = $urandom_range(99, 0);
      randomize_ok = 1'b0;

      start_item(item);

      // Percentages below use the complete RKNP request stream as denominator.
      // The six branches form one joint distribution, so overlapping request
      // attributes are represented explicitly and are never made exclusive by
      // a later constraint.
      if (category < 10) begin
        // 10%: ERR read, with RD/RDW chosen randomly.
        randomize_ok = item.randomize() with {
          opc inside {axi_tniu_protocol_pkg::OPC_RD,
                      axi_tniu_protocol_pkg::OPC_RDW};
          status     == axi_tniu_protocol_pkg::ST_ERR;
          errcode    == axi_tniu_protocol_pkg::EC_ADDR_DEC;
          axcache[0] == 1'b0;
        };
        n_err_rd++;
      end
      else if (category < 50) begin
        // 40%: normal read, with RD/RDW chosen randomly.
        randomize_ok = item.randomize() with {
          opc inside {axi_tniu_protocol_pkg::OPC_RD,
                      axi_tniu_protocol_pkg::OPC_RDW};
          status     == axi_tniu_protocol_pkg::ST_OK;
          errcode    == axi_tniu_protocol_pkg::EC_TARGET;
          axcache[0] == 1'b0;
        };
        n_normal_rd++;
      end
      else if (category < 56) begin
        // 6%: ERR write which is also bufferable.
        randomize_ok = item.randomize() with {
          opc inside {axi_tniu_protocol_pkg::OPC_WR,
                      axi_tniu_protocol_pkg::OPC_WRW};
          status     == axi_tniu_protocol_pkg::ST_ERR;
          errcode    == axi_tniu_protocol_pkg::EC_ADDR_DEC;
          axcache[0] == 1'b1;
        };
        n_err_wr++;
        n_bufferable_wr++;
      end
      else if (category < 60) begin
        // 4%: ERR write which is not bufferable.
        randomize_ok = item.randomize() with {
          opc inside {axi_tniu_protocol_pkg::OPC_WR,
                      axi_tniu_protocol_pkg::OPC_WRW};
          status     == axi_tniu_protocol_pkg::ST_ERR;
          errcode    == axi_tniu_protocol_pkg::EC_ADDR_DEC;
          axcache[0] == 1'b0;
        };
        n_err_wr++;
      end
      else if (category < 84) begin
        // 24%: normal bufferable write.
        randomize_ok = item.randomize() with {
          opc inside {axi_tniu_protocol_pkg::OPC_WR,
                      axi_tniu_protocol_pkg::OPC_WRW};
          status     == axi_tniu_protocol_pkg::ST_OK;
          errcode    == axi_tniu_protocol_pkg::EC_TARGET;
          axcache[0] == 1'b1;
        };
        n_normal_wr++;
        n_bufferable_wr++;
      end
      else begin
        // 16%: normal non-bufferable write.
        randomize_ok = item.randomize() with {
          opc inside {axi_tniu_protocol_pkg::OPC_WR,
                      axi_tniu_protocol_pkg::OPC_WRW};
          status     == axi_tniu_protocol_pkg::ST_OK;
          errcode    == axi_tniu_protocol_pkg::EC_TARGET;
          axcache[0] == 1'b0;
        };
        n_normal_wr++;
      end

      if (!randomize_ok)
        `uvm_fatal("SEQ_MIX", "rknp_seq_item randomization failed")

      complete_item(item, "SEQ_MIX");
    end

    `uvm_info("SEQ_MIX_SUMMARY",
      $sformatf({"generated=%0d ERR_RD=%0d ERR_WR=%0d ",
                 "BUFFERABLE_WR=%0d NORMAL_RD=%0d NORMAL_WR=%0d"},
                num_txn, n_err_rd, n_err_wr, n_bufferable_wr,
                n_normal_rd, n_normal_wr),
      UVM_LOW)
  endtask

endclass : seq_mix

`endif // SEQ_MIX_SV
