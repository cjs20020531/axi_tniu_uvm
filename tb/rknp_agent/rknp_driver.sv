// =============================================================================
// File        : rknp_driver.sv
// Description : RKNP request-channel driver (HeadPenalty = 0).
//               Packs an rknp_seq_item into a REQ flit using rknp_pkg field
//               offsets and streams it: head+first body word on the same cycle,
//               subsequent body words, tail asserted on the last body word.
//               Also drives txrsp_ready.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef RKNP_DRIVER_SV
`define RKNP_DRIVER_SV

class rknp_driver extends uvm_driver #(rknp_seq_item);
  `uvm_component_utils(rknp_driver)

  virtual rknp_if   vif;
  axi_tniu_cfg      cfg;
  rknp_txn_tag_mgr  tag_mgr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual rknp_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "rknp_if not set for rknp_driver")
    void'(uvm_config_db#(axi_tniu_cfg)::get(this, "", "cfg", cfg));

    if (!uvm_config_db#(rknp_txn_tag_mgr)::get(this,"","tag_mgr",tag_mgr))
      `uvm_fatal("RKNP_DRV", "rknp_txn_tag_mgr not found")
  endfunction

  task run_phase(uvm_phase phase);
    fork
      reset_and_drive();
      rsp_ready_gen();
    join
  endtask

  task reset_and_drive();
    forever begin
      vif.rxreq_valid <= 1'b0;
      vif.rxreq_head  <= 1'b0;
      vif.rxreq_tail  <= 1'b0;
      vif.rxreq_data  <= '0;

      if (!vif.aresetn)
        @(posedge vif.aresetn);

      drive_loop();
    end
  endtask

  task drive_loop();
    forever begin
      if (!vif.aresetn)
        return;

      seq_item_port.get_next_item(req);
      send_packet(req);
      seq_item_port.item_done();
    end
  endtask

  task send_packet(rknp_seq_item it);
    logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] head_flit;
    logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] flit;
    int nword;

    build_head_flit(it, head_flit);

    nword = it.is_write()
          ? (it.wr_bytes.size() +
             axi_tniu_protocol_pkg::NBYTEPERWORD - 1) /
            axi_tniu_protocol_pkg::NBYTEPERWORD
          : 1;

    if (nword == 0)
      nword = 1;

    @(vif.drv_cb);
    if (!vif.aresetn)
      return;

    for (int w = 0; w < nword; w++) begin
      flit = head_flit;

      if (it.is_write())
        pack_body_word(it, w, flit);

      vif.drv_cb.rxreq_valid <= 1'b1;
      vif.drv_cb.rxreq_head  <= (w == 0);
      vif.drv_cb.rxreq_tail  <= (w == nword-1);
      vif.drv_cb.rxreq_data  <= flit;

      if (w == 0) begin
        req.txn_no = tag_mgr.alloc_request(
          req.iid,
          req.tid,
          req.orderkey,
          req.opc,
          req.status
        );

        `uvm_info(
          "RKNP_DRV_TX_PACKET",
          $sformatf(" No.%0d\n%s", req.txn_no, it.convert2string()),
          UVM_MEDIUM
        )
      end

      do begin
        @(vif.drv_cb);
        if (!vif.aresetn) begin
          vif.drv_cb.rxreq_valid <= 1'b0;
          vif.drv_cb.rxreq_head  <= 1'b0;
          vif.drv_cb.rxreq_tail  <= 1'b0;
          vif.drv_cb.rxreq_data  <= '0;
          return;
        end
      end while (!vif.drv_cb.rxreq_ready);
    end

    vif.drv_cb.rxreq_valid <= 1'b0;
    vif.drv_cb.rxreq_head  <= 1'b0;
    vif.drv_cb.rxreq_tail  <= 1'b0;
  endtask

  function void build_head_flit(
    rknp_seq_item it,
    ref logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] f
  );
    f = '0;

    axi_tniu_protocol_pkg::set_field(
      f, axi_tniu_protocol_pkg::REQ_URGE_OFFSET,
      axi_tniu_protocol_pkg::URGE_WITH,
      axi_tniu_protocol_pkg::qos2urg(it.qos));

    axi_tniu_protocol_pkg::set_field(
      f, axi_tniu_protocol_pkg::REQ_SUBR_OFFSET,
      axi_tniu_protocol_pkg::SUBR_WITH, it.subr);

    axi_tniu_protocol_pkg::set_field(
      f, axi_tniu_protocol_pkg::REQ_IID_OFFSET,
      axi_tniu_protocol_pkg::IID_WITH, it.iid);

    axi_tniu_protocol_pkg::set_field(
      f, axi_tniu_protocol_pkg::REQ_TID_OFFSET,
      axi_tniu_protocol_pkg::TID_WITH, it.tid);

    axi_tniu_protocol_pkg::set_field(
      f, axi_tniu_protocol_pkg::REQ_ORDKEY_OFFSET,
      axi_tniu_protocol_pkg::ORDKEY_WITH, it.orderkey);

    axi_tniu_protocol_pkg::set_field(
      f, axi_tniu_protocol_pkg::REQ_OPC_OFFSET, 4, it.opc);

    axi_tniu_protocol_pkg::set_field(
      f, axi_tniu_protocol_pkg::REQ_STATUS_OFFSET, 2, it.status);

    axi_tniu_protocol_pkg::set_field(
      f, axi_tniu_protocol_pkg::REQ_LEN_OFFSET,
      axi_tniu_protocol_pkg::LEN_WITH, it.len);

    axi_tniu_protocol_pkg::set_field(
      f, axi_tniu_protocol_pkg::REQ_ADDR_OFFSET,
      axi_tniu_protocol_pkg::ADDR_WITH, it.addr);

    axi_tniu_protocol_pkg::set_field(
      f, axi_tniu_protocol_pkg::REQ_USER_OFFSET,
      axi_tniu_protocol_pkg::USER_WITH, it.user);

    axi_tniu_protocol_pkg::set_field(
      f, axi_tniu_protocol_pkg::REQ_ERRC_OFFSET, 3, it.errcode);
  endfunction

  function void pack_body_word(
    rknp_seq_item it,
    int w,
    ref logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] f
  );
    int base;
    int last_word;

    base = axi_tniu_protocol_pkg::REQ_HEAD_LEN_OFFSET;

    last_word =
      (it.wr_bytes.size() + axi_tniu_protocol_pkg::NBYTEPERWORD - 1) /
      axi_tniu_protocol_pkg::NBYTEPERWORD - 1;

    f[base] = (w == last_word);

    for (int b = 0; b < axi_tniu_protocol_pkg::NBYTEPERWORD; b++) begin
      int idx;
      int boff;

      idx  = w * axi_tniu_protocol_pkg::NBYTEPERWORD + b;
      boff = base + 1 + b*9;

      if (idx < it.wr_bytes.size()) begin
        f[boff]          = it.wr_be[idx];
        f[boff+1 +: 8]   = it.wr_bytes[idx];
      end
    end
  endfunction

  // ---------------------------------------------------------------------------
  // Response-ready generation.
  //
  // Priority:
  //   reset                    -> ready LOW
  //   rsp_ready_force_low_en   -> ready LOW (directed coverage)
  //   rsp_ready_bp_en          -> random backpressure
  //   otherwise                -> ready HIGH
  //
  // The cfg object is shared by handle, so a test can clear
  // rsp_ready_force_low_en at runtime to release a deliberately stalled
  // response path.
  // ---------------------------------------------------------------------------
  task rsp_ready_gen();
    forever begin
      if (!vif.aresetn) begin
        vif.txrsp_ready <= 1'b0;
        @(posedge vif.aclk);
        continue;
      end

      if (cfg != null && cfg.rsp_ready_force_low_en)
        vif.txrsp_ready <= 1'b0;
      else if (cfg != null && cfg.rsp_ready_bp_en)
        vif.txrsp_ready <=
          ($urandom_range(99, 0) >= cfg.rsp_ready_low_pct);
      else
        vif.txrsp_ready <= 1'b1;

      @(posedge vif.aclk);
    end
  endtask

endclass : rknp_driver

`endif // RKNP_DRIVER_SV
