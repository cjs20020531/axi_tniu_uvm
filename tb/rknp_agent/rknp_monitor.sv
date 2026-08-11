// =============================================================================
// File        : rknp_monitor.sv
// Description : RKNP monitor. Samples BOTH the request channel (rxreq, the
//               stimulus actually accepted by the DUT) and the response channel
//               (txrsp, packets emitted by the DUT). Unpacks each accepted flit
//               stream into an rknp_seq_item and broadcasts on analysis ports.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef RKNP_MONITOR_SV
`define RKNP_MONITOR_SV

class rknp_monitor extends uvm_monitor;
  `uvm_component_utils(rknp_monitor)

  virtual rknp_if vif;

  rknp_txn_tag_mgr tag_mgr;

  uvm_analysis_port #(rknp_seq_item) req_ap;   // observed requests
  uvm_analysis_port #(rknp_seq_item) rsp_ap;   // observed responses

  function new(string name, uvm_component parent);
    super.new(name, parent);
    req_ap = new("req_ap", this);
    rsp_ap = new("rsp_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual rknp_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "rknp_if not set for rknp_monitor")

    if (!uvm_config_db#(rknp_txn_tag_mgr)::get(this,"","tag_mgr",tag_mgr))
      `uvm_fatal("RKNP_MON", "rknp_txn_tag_mgr not found")
    
  endfunction

  task run_phase(uvm_phase phase);
    fork
      mon_request();
      mon_response();
    join
  endtask

  // ---- collect an accepted request packet -----------------------------------
  task mon_request();
      logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] head_flit;
      byte unsigned bytes[$]; 
      bit be[$];
      bit got_head = 0;
      rknp_seq_item req;
    forever begin
      // 每次开始接收新 packet 前清空临时数据。
      bytes.delete();
      be.delete();
      got_head = 1'b0;

      @(vif.mon_cb);
      if (!vif.aresetn) continue;
      if (vif.mon_cb.rxreq_valid && vif.mon_cb.rxreq_ready) begin
        // start of packet
        if (vif.mon_cb.rxreq_head) begin
          head_flit = vif.mon_cb.rxreq_data; 
          got_head = 1;
        end
        // gather body across the packet until tail
        collect_body(1'b1, vif.mon_cb.rxreq_data, bytes, be);
        while (!vif.mon_cb.rxreq_tail) begin
          do @(vif.mon_cb); while (!(vif.mon_cb.rxreq_valid && vif.mon_cb.rxreq_ready));
          collect_body(1'b1, vif.mon_cb.rxreq_data, bytes, be);
        end
        if (got_head) begin
          req = unpack_req(head_flit, bytes, be);
          //----
          if (!tag_mgr.claim_request_no(req.iid,req.tid,req.orderkey,req.txn_no)) begin
            `uvm_warning("RKNP_TAG",
              $sformatf("Request label not found: iid=0x%0h tid=0x%0h orderkey=0x%0h",req.iid,req.tid,req.orderkey))
          end
          //===
          req_ap.write(req);

        end
      end
    end
  endtask

  // ---- collect an emitted response packet -----------------------------------
  // ---- collect an emitted response packet -----------------------------------
  task mon_response();
    logic [axi_tniu_protocol_pkg::RSP_FLIT_WITH-1:0] head_flit;

    byte unsigned bytes[$];
    bit           be[$];
    bit           got_head;
    rknp_seq_item rsp;
    bit           final_lw;
    forever begin
      bytes.delete();
      be.delete();
      got_head    = 1'b0;
      final_lw    = 1'b0;
      @(vif.mon_cb);

      if (!vif.aresetn)
        continue;

      if (vif.mon_cb.txrsp_valid && vif.mon_cb.txrsp_ready) begin

        final_lw = vif.mon_cb.txrsp_data[axi_tniu_protocol_pkg::RSP_HEAD_LEN_OFFSET];

        if (vif.mon_cb.txrsp_head) begin
          // 只有 head 有效时才保存并解析事务标识字段。
          head_flit  = vif.mon_cb.txrsp_data;
          got_head   = 1'b1;
        end

        collect_body(1'b0, vif.mon_cb.txrsp_data, bytes, be);

        // 持续采集直到当前 response packet 的 tail flit 完成握手。
        while (!vif.mon_cb.txrsp_tail) begin
          do @(vif.mon_cb);
          while (!(vif.mon_cb.txrsp_valid && vif.mon_cb.txrsp_ready));

          final_lw = vif.mon_cb.txrsp_data[axi_tniu_protocol_pkg::RSP_HEAD_LEN_OFFSET];

          collect_body(1'b0, vif.mon_cb.txrsp_data, bytes, be);
        end

        if (got_head) begin
          // OPC/IID/TID/OrderKey 等事务标识仍然从 head flit 解码。
          rsp = unpack_rsp(head_flit, bytes, be);

          rsp.rsp_lw = final_lw;
          rsp.is_rsp     = 1'b1;

          if (!tag_mgr.claim_response_no(rsp.iid, rsp.tid, rsp.orderkey, rsp.rsp_lw, rsp.txn_no)) begin
            `uvm_warning(
              "RKNP_TAG",
              $sformatf({"Response label not found: iid=0x%0h tid=0x%0h ","orderkey=0x%0h status=%s"},
                rsp.iid,
                rsp.tid,
                rsp.orderkey,
                rsp.rsp_status.name())
            )
          end

          `uvm_info(
            "RKNP_TXN",
            $sformatf(
              " No.%0d\n%s",
              rsp.txn_no,
              rsp.convert2string()),
            UVM_MEDIUM)

          rsp_ap.write(rsp);
        end
      end
    end
  endtask



  // ---- helpers --------------------------------------------------------------
  // extract body bytes from a flit (works on both req/rsp flit widths)
  function void collect_body(bit is_req, logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] flit,
                             ref byte unsigned bytes[$], ref bit be[$]);
    int base = is_req ? axi_tniu_protocol_pkg::REQ_HEAD_LEN_OFFSET : axi_tniu_protocol_pkg::RSP_HEAD_LEN_OFFSET;
    for (int b = 0; b < axi_tniu_protocol_pkg::NBYTEPERWORD; b++) begin
      int boff = base + 1 + b*9;
      be.push_back(flit[boff]);
      bytes.push_back(flit[boff+1 +: 8]);

    end

  endfunction

  function rknp_seq_item unpack_req(logic [axi_tniu_protocol_pkg::REQ_FLIT_WITH-1:0] f,
                                    byte unsigned bytes[$], bit be[$]);
    rknp_seq_item req = rknp_seq_item::type_id::create("mon_req");
    req.opc      = axi_tniu_protocol_pkg::req_opc_e'(axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::REQ_OPC_OFFSET, 4));
    req.qos      = axi_tniu_protocol_pkg::urg2qos(axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::REQ_URGE_OFFSET, axi_tniu_protocol_pkg::URGE_WITH));
    req.subr     = axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::REQ_SUBR_OFFSET,  axi_tniu_protocol_pkg::SUBR_WITH);
    req.iid      = axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::REQ_IID_OFFSET,   axi_tniu_protocol_pkg::IID_WITH);
    req.tid      = axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::REQ_TID_OFFSET,   axi_tniu_protocol_pkg::TID_WITH);
    req.orderkey = axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::REQ_ORDKEY_OFFSET,axi_tniu_protocol_pkg::ORDKEY_WITH);
    req.status   = axi_tniu_protocol_pkg::status_e'(axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::REQ_STATUS_OFFSET, 2));
    req.errcode  = axi_tniu_protocol_pkg::errcode_e'(axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::REQ_ERRC_OFFSET, 3));
    req.len      = axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::REQ_LEN_OFFSET,   axi_tniu_protocol_pkg::LEN_WITH);
    req.addr     = axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::REQ_ADDR_OFFSET,  axi_tniu_protocol_pkg::ADDR_WITH);
    req.unpack_user(axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::REQ_USER_OFFSET, axi_tniu_protocol_pkg::USER_WITH));
    // 只有写请求才携带 write body。
    if ((req.opc == axi_tniu_protocol_pkg::OPC_WR) ||
        (req.opc == axi_tniu_protocol_pkg::OPC_WRW)) begin
      int unsigned start_lane;
      int unsigned payload_bytes;

      start_lane    = int'(req.addr &
                          (axi_tniu_protocol_pkg::NBYTEPERWORD - 1));
      payload_bytes = int'(req.len) + 1;

      // The monitor exports the original logical payload representation to the
      // reference model. Leading physical padding inserted by the sequence item
      // is skipped here; the existing reference model therefore needs no change.
      req.wr_bytes = new[payload_bytes];
      req.wr_be    = new[payload_bytes];
      req.wr_body_aligned = 1'b0;

      for (int unsigned i = 0; i < payload_bytes; i++) begin
        int unsigned physical_idx;
        physical_idx = start_lane + i;

        if (physical_idx < bytes.size()) begin
          req.wr_bytes[i] = bytes[physical_idx];
          req.wr_be[i]    = be[physical_idx];
        end
        else begin
          req.wr_bytes[i] = 8'h00;
          req.wr_be[i]    = 1'b0;
          `uvm_error("RKNP_MON",
            $sformatf(
              "Write body too short: addr=0x%0h len=%0d start_lane=%0d collected=%0d",
              req.addr, req.len, start_lane, bytes.size()))
        end
      end
    end
    
    return req;
  endfunction

  function rknp_seq_item unpack_rsp(logic [axi_tniu_protocol_pkg::RSP_FLIT_WITH-1:0] f,
                                    byte unsigned bytes[$], bit be[$]);
    rknp_seq_item rsp = rknp_seq_item::type_id::create("mon_rsp");
    rsp.rsp_opc     = axi_tniu_protocol_pkg::rsp_opc_e'(axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::RSP_OPC_OFFSET, 2));
    rsp.rsp_status  = axi_tniu_protocol_pkg::status_e'(axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::RSP_STATUS_OFFSET, 2));
    rsp.rsp_errcode = axi_tniu_protocol_pkg::errcode_e'(axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::RSP_ERRC_OFFSET, 3));
    rsp.qos          = axi_tniu_protocol_pkg::urg2qos(
                         axi_tniu_protocol_pkg::get_field(
                           f,
                           axi_tniu_protocol_pkg::RSP_URGE_OFFSET,
                           axi_tniu_protocol_pkg::URGE_WITH));
    rsp.orderkey    = axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::RSP_ORDKEY_OFFSET, axi_tniu_protocol_pkg::ORDKEY_WITH);
    rsp.iid         = axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::RSP_IID_OFFSET, axi_tniu_protocol_pkg::IID_WITH);
    rsp.tid         = axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::RSP_TID_OFFSET, axi_tniu_protocol_pkg::TID_WITH);
    rsp.addr        = axi_tniu_protocol_pkg::get_field(f, axi_tniu_protocol_pkg::RSP_ADDR_OFFSET, axi_tniu_protocol_pkg::ADDR_WITH);
    rsp.unpack_user(axi_tniu_protocol_pkg::get_field(
                      f,
                      axi_tniu_protocol_pkg::RSP_USER_OFFSET,
                      axi_tniu_protocol_pkg::USER_WITH));
    rsp.rd_bytes = new[bytes.size()]; rsp.rd_be = new[be.size()];
    foreach (bytes[i]) rsp.rd_bytes[i] = bytes[i];
    foreach (be[i])    rsp.rd_be[i]    = be[i];
    return rsp;
  endfunction

endclass : rknp_monitor

`endif // RKNP_MONITOR_SV
