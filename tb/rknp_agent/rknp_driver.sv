// =============================================================================
// File        : rknp_driver.sv
// Description : RKNP request-channel driver (HeadPenalty = 0).
//               Packs an rknp_seq_item into a REQ flit using rknp_pkg field
//               offsets and streams it: head+first body word on the same cycle,
//               subsequent body words, tail asserted on the last body word.
//               Also keeps txrsp_ready driven (default accept, random stall).
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef RKNP_DRIVER_SV
`define RKNP_DRIVER_SV

class rknp_driver extends uvm_driver #(rknp_seq_item);
  `uvm_component_utils(rknp_driver)

  virtual rknp_if  vif;
  axi_tniu_cfg     cfg;
  rknp_txn_tag_mgr tag_mgr;

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

  // Two parallel jobs: drive requests, and keep the response ready line moving.
  task run_phase(uvm_phase phase);
    fork
      reset_and_drive();
      rsp_ready_gen();
    join
  endtask

  task reset_and_drive();
    forever begin
      // Hold the request channel idle during reset.
      // NOTE: aresetn is asserted (low) from time 0, so there is NO falling
      // edge to wait on. Drive idle immediately and LEVEL-check the reset;
      // otherwise @(negedge aresetn) blocks forever, no stimulus is ever
      // driven, and the sim hangs until the global timeout.
      vif.rxreq_valid <= 1'b0;
      vif.rxreq_head  <= 1'b0;
      vif.rxreq_tail  <= 1'b0;
      vif.rxreq_data  <= '0;
      if (!vif.aresetn) @(posedge vif.aresetn);  // wait for reset release
      drive_loop();                              // returns if reset re-asserts
    end
  endtask

  task drive_loop();
    forever begin
      if (!vif.aresetn) return;              // bail out to reset handler
      seq_item_port.get_next_item(req);
      send_packet(req);
      seq_item_port.item_done();
    end
  endtask

  // ---- pack + stream one request packet -------------------------------------
  task send_packet(rknp_seq_item it);
    logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] head_flit, flit;
    int nword;
    build_head_flit(it, head_flit);
    // Reads are HEAD-ONLY (1 flit: head+tail+valid for one cycle).
    // Only writes carry body data words (ceil(bytes / NBYTEPERWORD) flits).
    nword = it.is_write()
          ? (it.wr_bytes.size() + axi_tniu_protocol_pkg::NBYTEPERWORD - 1) / axi_tniu_protocol_pkg::NBYTEPERWORD
          : 1;
    if (nword == 0) nword = 1;               // zero-length write : still 1 flit

    for (int w = 0; w < nword; w++) begin
      // Per RKNP: the head-portion fields [0 +: REQ_HEAD_LEN_OFFSET] are HELD on
      // every flit (NOT re-zeroed on body flits). Only the data region
      // [REQ_HEAD_LEN_OFFSET +: 73] is updated with the current word's data.
      flit = head_flit;
      if (it.is_write()) pack_body_word(it, w, flit);

      // Present this flit, THEN advance one clock so it is on the bus.
      vif.drv_cb.rxreq_valid <= 1'b1;
      vif.drv_cb.rxreq_head  <= (w == 0);        // HeadPenalty=0 -> head is one flit only
      vif.drv_cb.rxreq_tail  <= (w == nword-1);
      vif.drv_cb.rxreq_data  <= flit;

      //发送第一拍时打印整笔transaction
      if (w == 0) begin

        req.txn_no = tag_mgr.alloc_request(
          req.iid,
          req.tid,
          req.orderkey,
          req.opc,
          req.status
        ); // 保存请求-响应标签，每个transaction仅保存一次

        `uvm_info(
          "RKNP_DRV_TX_PACKET",
          $sformatf(
            " No.%0d\n%s",
            req.txn_no,
            it.convert2string()
          ),
          UVM_MEDIUM
        )
      end

      @(vif.drv_cb);
      // If not accepted this cycle, HOLD the same flit unchanged until ready.
      while (!vif.drv_cb.rxreq_ready) @(vif.drv_cb);
      // accepted at this edge -> next iteration overwrites with the next flit
      // (no gap); after the last word we drop valid on the very next cycle.
    end
    vif.drv_cb.rxreq_valid <= 1'b0;
    vif.drv_cb.rxreq_head  <= 1'b0;
    vif.drv_cb.rxreq_tail  <= 1'b0;
  endtask

  // ---- build the head flit from item fields ---------------------------------
  function void build_head_flit(rknp_seq_item it,
                                ref logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] f);
    f = '0;
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_URGE_OFFSET,  axi_tniu_protocol_pkg::URGE_WITH,
                        axi_tniu_protocol_pkg::qos2urg(it.qos));
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_SUBR_OFFSET,  axi_tniu_protocol_pkg::SUBR_WITH,   it.subr);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_IID_OFFSET,   axi_tniu_protocol_pkg::IID_WITH,    it.iid);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_TID_OFFSET,   axi_tniu_protocol_pkg::TID_WITH,    it.tid);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_ORDKEY_OFFSET,axi_tniu_protocol_pkg::ORDKEY_WITH, it.orderkey);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_OPC_OFFSET,   4,                     it.opc);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_STATUS_OFFSET,2,                     it.status);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_LEN_OFFSET,   axi_tniu_protocol_pkg::LEN_WITH,    it.len);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_ADDR_OFFSET,  axi_tniu_protocol_pkg::ADDR_WITH,   it.addr);
    // USER is composed from its sub-fields (axcache[0] carries bufferable)
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_USER_OFFSET,  axi_tniu_protocol_pkg::USER_WITH, it.user);
    axi_tniu_protocol_pkg::set_field(f, axi_tniu_protocol_pkg::REQ_ERRC_OFFSET,  3,                     it.errcode);
  endfunction

  // ---- pack one 64-bit body word (write data) into a flit -------------------
  // Body word layout: [LW][ {Be,Byte} * NBYTEPERWORD ] starting at REQ_HEAD_LEN_OFFSET.
  function void pack_body_word(rknp_seq_item it, int w,
                               ref logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] f);
    int base = axi_tniu_protocol_pkg::REQ_HEAD_LEN_OFFSET;   // body region start
    int last_word = (it.wr_bytes.size() + axi_tniu_protocol_pkg::NBYTEPERWORD - 1)
                    / axi_tniu_protocol_pkg::NBYTEPERWORD - 1;
    f[base] = (w == last_word);                 // LW bit
    for (int b = 0; b < axi_tniu_protocol_pkg::NBYTEPERWORD; b++) begin
      int idx  = w*axi_tniu_protocol_pkg::NBYTEPERWORD + b;
      int boff = base + 1 + b*9;                 // Be(1)+Byte(8)
      if (idx < it.wr_bytes.size()) begin
        f[boff]            = it.wr_be[idx];
        f[boff+1 +: 8]     = it.wr_bytes[idx];
      end
      // `uvm_info(
      //   "PACKET_BODY_BYTE",
      //   $sformatf("byte=%h",it.wr_bytes[idx]),
      //   UVM_MEDIUM
      // )
      // `uvm_info(
      //   "PACKET_BODY_BE",
      //   $sformatf("be=%d",it.wr_be[idx]),
      //   UVM_MEDIUM
      // )
    end
  endfunction

  // ---- keep the response ready line active (default HIGH) --------------------
  task rsp_ready_gen();
    forever begin
      if (!vif.aresetn) begin
        vif.txrsp_ready <= 1'b0; @(posedge vif.aclk); continue;
      end
      // Default: always ready to accept the DUT response (ready HIGH).
      // Apply random back-pressure ONLY when explicitly enabled for testing.
      if (cfg != null && cfg.rsp_ready_bp_en)
        vif.txrsp_ready <= ($urandom_range(0,9) != 0);  // ~10% stall
      else
        vif.txrsp_ready <= 1'b1;                         // default: always accept
      @(posedge vif.aclk);
    end
  endtask





endclass : rknp_driver

`endif // RKNP_DRIVER_SV
