`ifndef SEQ_WATCHDOG_FIFO_FULL_COV_SV
`define SEQ_WATCHDOG_FIFO_FULL_COV_SV

class seq_watchdog_fifo_full_cov extends rknp_base_seq;
  `uvm_object_utils(seq_watchdog_fifo_full_cov)

  function new(string name = "seq_watchdog_fifo_full_cov");
    super.new(name);
    num_txn = 9;
  endfunction

  protected task send_blocker();
    rknp_seq_item it;

    it = rknp_seq_item::type_id::create("fifo_full_blocker");

    start_item(it);
    if (!it.randomize() with {
          opc       == axi_tniu_protocol_pkg::OPC_RD;
          status    == axi_tniu_protocol_pkg::ST_ERR;
          errcode   == axi_tniu_protocol_pkg::EC_ADDR_DEC ;

          // 256B ERR Read -> rsp_order locally generates 32 response flits.
          len       == 8'hff;
          addr      == 32'h7000_0000;

          orderkey  == 8'h0f;
          iid       == 10'h300;
          tid       == 10'h301;

          qos       == 3'd0;
          subr      == 8'h00;
          rknp_user == 1'b0;
          axi_user  == 1'b0;
          axlock    == 1'b0;
          axport    == 3'b000;
          axcache   == 4'b0000;
        })
      `uvm_fatal("SEQ_WD_FIFO_FULL", "Blocker randomization failed")

    complete_item(it, "SEQ_WD_FIFO_FULL");
  endtask

  protected task send_timeout_write(input int unsigned idx);
    rknp_seq_item it;
    axi_tniu_protocol_pkg::ordkey_t orderkey_v;
    logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] addr_v;

    orderkey_v = axi_tniu_protocol_pkg::ordkey_t'(8'h01 + idx);
    addr_v     = 32'h7100_0000 + idx * 32'h0000_0100;

    it = rknp_seq_item::type_id::create(
           $sformatf("fifo_full_wr_%0d", idx));

    start_item(it);
    if (!it.randomize() with {
          opc       == axi_tniu_protocol_pkg::OPC_WR;
          status    == axi_tniu_protocol_pkg::ST_OK;
          errcode   == axi_tniu_protocol_pkg::EC_TARGET;

          orderkey  == local::orderkey_v;
          addr      == local::addr_v;
          len       == 8'h00;

          iid       == ((10'h320 + local::idx) & 10'h3ff);
          tid       == ((10'h360 + local::idx) & 10'h3ff);

          qos       == 3'd0;
          subr      == 8'h00;
          rknp_user == 1'b0;
          axi_user  == 1'b0;
          axlock    == 1'b0;
          axport    == 3'b000;

          // Must remain non-bufferable so watchdog timing is enabled.
          axcache   == 4'b0000;
        })
      `uvm_fatal("SEQ_WD_FIFO_FULL",
        $sformatf("Write %0d randomization failed", idx))

    complete_item(it, "SEQ_WD_FIFO_FULL");
  endtask

  task body();
    // The ERR blocker is dispatched locally and frees its req_order head.
    send_blocker();

    // All 8 writes can then occupy the full req_order/watchdog table.
    for (int unsigned i = 0; i < 8; i++)
      send_timeout_write(i);
  endtask

endclass : seq_watchdog_fifo_full_cov

`endif // SEQ_WATCHDOG_FIFO_FULL_COV_SV
