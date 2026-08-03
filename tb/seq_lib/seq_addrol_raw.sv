`ifndef SEQ_ADDROL_RAW_SV
`define SEQ_ADDROL_RAW_SV

class seq_addrol_raw extends rknp_base_seq;
  `uvm_object_utils(seq_addrol_raw)

  function new(string name = "seq_addrol_raw");
    super.new(name);
    num_txn = 2;
  endfunction

  task body();
    logic [axi_tniu_protocol_pkg::ADDR_WITH-1:6] base_block;
    logic [axi_tniu_protocol_pkg::SUBR_WITH-1:0] base_subr;

    if (num_txn < 2)
      `uvm_fatal("SEQ_ADDROL_RAW", "num_txn must be at least 2")

    for (int unsigned i = 0; i < num_txn; i++) begin
      rknp_seq_item it;

      it = rknp_seq_item::type_id::create($sformatf("it_%0d", i));
      start_item(it);

      if (i == 0) begin
        if (!it.randomize() with {
              opc inside {axi_tniu_protocol_pkg::OPC_WR,
                          axi_tniu_protocol_pkg::OPC_WRW};
              status     == axi_tniu_protocol_pkg::ST_OK;
              axcache[0] == 1'b0;
            })
          `uvm_fatal("SEQ_ADDROL_RAW", "First request randomization failed")
        base_block = it.addr[axi_tniu_protocol_pkg::ADDR_WITH-1:6];
        base_subr  = it.subr;
      end
      else if (i == (num_txn - 1)) begin
        if (!it.randomize() with {
              opc inside {axi_tniu_protocol_pkg::OPC_RD,
                          axi_tniu_protocol_pkg::OPC_RDW};
              status     == axi_tniu_protocol_pkg::ST_OK;
              axcache[0] == 1'b0;
              addr[axi_tniu_protocol_pkg::ADDR_WITH-1:6] == local::base_block;
              subr == local::base_subr;
            })
          `uvm_fatal("SEQ_ADDROL_RAW", "Last request randomization failed")
      end
      else begin
        if (!it.randomize() with {
              status     == axi_tniu_protocol_pkg::ST_OK;
              axcache[0] == 1'b0;
            })
          `uvm_fatal("SEQ_ADDROL_RAW", "Middle request randomization failed")
      end

      complete_item(it, "SEQ_ADDROL_RAW");
    end
  endtask
endclass : seq_addrol_raw

`endif // SEQ_ADDROL_RAW_SV
