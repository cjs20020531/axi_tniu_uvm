`ifndef SEQ_WATCHDOG_MULTI_TIMEOUT_COV_SV
`define SEQ_WATCHDOG_MULTI_TIMEOUT_COV_SV

class seq_watchdog_multi_timeout_cov extends rknp_base_seq;
  `uvm_object_utils(seq_watchdog_multi_timeout_cov)

  function new(string name = "seq_watchdog_multi_timeout_cov");
    super.new(name);
    num_txn = 8;
  endfunction

  protected function axi_tniu_protocol_pkg::ordkey_t
    choose_orderkey(input int unsigned idx);
    case (idx % 8)
      0: return axi_tniu_protocol_pkg::ordkey_t'(8'h00);
      1: return axi_tniu_protocol_pkg::ordkey_t'(8'h06);
      2: return axi_tniu_protocol_pkg::ordkey_t'(8'h0a);
      3: return axi_tniu_protocol_pkg::ordkey_t'(8'h0c);
      4: return axi_tniu_protocol_pkg::ordkey_t'(8'h03);
      5: return axi_tniu_protocol_pkg::ordkey_t'(8'h05);
      6: return axi_tniu_protocol_pkg::ordkey_t'(8'h09);
      default:
         return axi_tniu_protocol_pkg::ordkey_t'(8'h0f);
    endcase
  endfunction

  task body();
    for (int unsigned i = 0; i < num_txn; i++) begin
      rknp_seq_item                              it;
      axi_tniu_protocol_pkg::ordkey_t            orderkey_v;
      axi_tniu_protocol_pkg::req_opc_e           opc_v;
      logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] addr_v;
      logic [axi_tniu_protocol_pkg::IID_WITH-1:0]  iid_v;
      logic [axi_tniu_protocol_pkg::TID_WITH-1:0]  tid_v;

      orderkey_v = choose_orderkey(i);
      opc_v = ((i & 1) == 0) ?
              axi_tniu_protocol_pkg::OPC_RD :
              axi_tniu_protocol_pkg::OPC_WR;

      addr_v = 32'h5000_0000 + (i * 32'h0000_0100);
      iid_v  = axi_tniu_protocol_pkg::IID_WITH'(10'h100 + i);
      tid_v  = axi_tniu_protocol_pkg::TID_WITH'(10'h200 + i);

      it = rknp_seq_item::type_id::create(
             $sformatf("watchdog_timeout_it_%0d", i));

      start_item(it);
      if (!it.randomize() with {
            opc        == local::opc_v;
            status     == axi_tniu_protocol_pkg::ST_OK;
            errcode    == axi_tniu_protocol_pkg::EC_TARGET;
            orderkey   == local::orderkey_v;
            addr       == local::addr_v;
            len        == 8'h00;
            subr       == 0;
            qos        == 0;
            axcache    == 4'b0000;
            rknp_user  == 1'b0;
            axi_user   == 1'b0;
            axlock     == 1'b0;
            axport     == 3'b000;
            iid        == local::iid_v;
            tid        == local::tid_v;
          })
        `uvm_fatal("SEQ_WATCHDOG_MULTI_TIMEOUT",
                   $sformatf("Randomization failed for item %0d", i))

      complete_item(it, "SEQ_WATCHDOG_MULTI_TIMEOUT");
    end
  endtask

endclass : seq_watchdog_multi_timeout_cov

`endif // SEQ_WATCHDOG_MULTI_TIMEOUT_COV_SV
