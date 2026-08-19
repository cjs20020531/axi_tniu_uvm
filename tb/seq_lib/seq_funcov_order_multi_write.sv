`ifndef SEQ_FUNCOV_ORDER_MULTI_WRITE_SV
`define SEQ_FUNCOV_ORDER_MULTI_WRITE_SV

typedef enum logic {
  FUNCOV_WRITE_INCR = 1'b0,
  FUNCOV_WRITE_WRAP = 1'b1
} funcov_write_mode_e;

class seq_funcov_order_multi_write extends rknp_base_seq;
  `uvm_object_utils(seq_funcov_order_multi_write)

  localparam int unsigned GROUPS        = 4;
  localparam int unsigned REQ_PER_GROUP = 2;
  localparam int unsigned LEN_MULTI     = 31;

  funcov_write_mode_e mode = FUNCOV_WRITE_INCR;

  function new(string name = "seq_funcov_order_multi_write");
    super.new(name);
    num_txn = GROUPS * REQ_PER_GROUP;
  endfunction

  protected function string mode_name();
    if (mode == FUNCOV_WRITE_WRAP)
      return "WRAP_WR";
    return "INCR_WR";
  endfunction

  protected function axi_tniu_protocol_pkg::req_opc_e selected_opc();
    if (mode == FUNCOV_WRITE_WRAP)
      return axi_tniu_protocol_pkg::OPC_WRW;
    return axi_tniu_protocol_pkg::OPC_WR;
  endfunction

  protected function axi_tniu_protocol_pkg::ordkey_t group_orderkey(
      int unsigned group);
    return axi_tniu_protocol_pkg::ordkey_t'(8'h01 + group);
  endfunction

  protected task send_one(int unsigned group, int unsigned round);
    rknp_seq_item it;
    axi_tniu_protocol_pkg::req_opc_e opc_v;
    axi_tniu_protocol_pkg::ordkey_t  orderkey_v;
    logic [axi_tniu_protocol_pkg::IID_WITH-1:0] iid_v;
    logic [axi_tniu_protocol_pkg::TID_WITH-1:0] tid_v;
    logic [31:0] addr_v;

    opc_v      = selected_opc();
    orderkey_v = group_orderkey(group);
    iid_v      = 10'h300 + group;
    tid_v      = 10'h100 + group;

    addr_v = 32'h5000_0000
           + group * 32'h0000_1000
           + round * 32'h0000_0100;

    it = rknp_seq_item::type_id::create(
           $sformatf("%s_g%0d_r%0d", mode_name(), group, round));

    start_item(it);

    if (!it.randomize() with {
          opc        == local::opc_v;
          status     == axi_tniu_protocol_pkg::ST_OK;
          len        == LEN_MULTI;
          rknp_user  == 1'b0;
          axi_user   == 1'b0;
          axlock     == 1'b0;
          axport     == 3'b000;
          axcache    == 4'b0000;
          iid        == local::iid_v;
          tid        == local::tid_v;
          orderkey   == local::orderkey_v;
          addr       == local::addr_v;
        }) begin
      `uvm_fatal("SEQ_ORDER_MULTI_WRITE",
                 $sformatf("Randomization failed: mode=%s group=%0d round=%0d",
                           mode_name(), group, round))
    end

    if (it.is_wrap() &&
        ((int'(it.addr) &
          (axi_tniu_protocol_pkg::NBYTEPERWORD - 1)) != 0)) begin
      `uvm_fatal("SEQ_ORDER_MULTI_WRITE",
                 $sformatf("WRAP write address is not 8-byte aligned: 0x%08h",
                           it.addr))
    end

    complete_item(it, "SEQ_ORDER_MULTI_WRITE");
  endtask

  task body();
    `uvm_info("SEQ_ORDER_MULTI_WRITE",
              $sformatf("Start write block: %s len=%0d requests=%0d",
                        mode_name(), LEN_MULTI, GROUPS*REQ_PER_GROUP),
              UVM_LOW)

    for (int unsigned g = 0; g < GROUPS; g++)
      send_one(g, 0);

    for (int unsigned g = 0; g < GROUPS; g++)
      send_one(g, 1);

    `uvm_info("SEQ_ORDER_MULTI_WRITE",
              $sformatf("Completed write block: %s", mode_name()),
              UVM_LOW)
  endtask

endclass : seq_funcov_order_multi_write

`endif
