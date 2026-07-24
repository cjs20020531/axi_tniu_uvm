// =============================================================================
// File        : axi_tniu_refmodel.sv
// Description : Reference model / predictor for the axi_tniu conversion.
//               Given an observed RKNP request packet it predicts the
//               attributes of the AXI transaction the DUT must launch and the
//               attributes of the RKNP response packet that must eventually
//               return. It does NOT re-implement the DUT's internal buffering;
//               instead it computes the *relational* golden values that the
//               scoreboard cross-checks against what actually appears on the
//               AXI bus and the RKNP response channel.
//
//               Predictions produced:
//                 - AXI direction (RD->AR, WR->AW/W)
//                 - AxID          (OrderKey -> AxID mapping)
//                 - AxADDR        (SubRange base + RKNP addr)   [base modelled 0]
//                 - AxLEN/SIZE/BURST (INCR vs WRAP, 64-bit beats)
//                 - AxCACHE[0]    (bufferable / early-response)
//                 - AxQOS         (urgency popcount)
//                 - rsp opcode/status/errcode
//
//               ERR requests are accepted and processed through the normal TNIU request
//               path. The reference model therefore still predicts the corresponding AXI
//               transaction. The request error status only affects the predicted RKNP
//               response status and ErrorCode.
//               downstream AXI transaction and must reflect an ERR response
//
//               WRW realignment modelling:
//                 - unaligned WRAP-write payload and byte enables are rotated
//                   exactly as wrap_align.v before AXI WDATA/WSTRB prediction
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_TNIU_REFMODEL_SV
`define AXI_TNIU_REFMODEL_SV

// -----------------------------------------------------------------------------
// Predicted-transaction descriptor produced by the reference model.
// -----------------------------------------------------------------------------
class axi_tniu_expect extends uvm_object;

  // source request (kept for scoreboard reporting / data correlation)
  rknp_seq_item                                          req;

  // predicted AXI attributes
  axi_dir_e                                               dir;          // AXI_READ / AXI_WRITE
  logic [axi_tniu_protocol_pkg::AXID_WITH-1:0]            axid;
  logic [axi_tniu_protocol_pkg::AADDR_WITH-1:0]           axaddr;
  logic [axi_tniu_protocol_pkg::ALEN_WITH-1:0]            axlen;        // beats - 1
  logic [axi_tniu_protocol_pkg::ASIZE_WITH-1:0]           axsize;       // 3 => 8 bytes/beat
  logic [1:0]                                             axburst;      // 01 INCR / 10 WRAP
  bit                                                     cache_buf;    // AxCACHE[0]
  logic [axi_tniu_protocol_pkg::AQOS_WITH-1:0]            axqos;
  bit                                                     axi_valid;

  logic [axi_tniu_protocol_pkg::NBYTEPERWORD*8-1:0]       axi_wdata[];
  logic [axi_tniu_protocol_pkg::AXI_STRB_WITH-1:0]        axi_wstrb[];

  int unsigned                                            txn_no;       //请求-响应编号，方便log查找

  // predicted RKNP response attributes
  axi_tniu_protocol_pkg::rsp_opc_e    rsp_opc;
  axi_tniu_protocol_pkg::status_e     rsp_status;
  axi_tniu_protocol_pkg::errcode_e    rsp_errcode;

  `uvm_object_utils(axi_tniu_expect)

  function new(string name = "axi_tniu_expect");
    super.new(name);
  endfunction
endclass : axi_tniu_expect


// -----------------------------------------------------------------------------
// Reference model component.
// -----------------------------------------------------------------------------
class axi_tniu_refmodel extends uvm_component;
  `uvm_component_utils(axi_tniu_refmodel)

  axi_tniu_cfg cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(axi_tniu_cfg)::get(this, "", "cfg", cfg))
      `uvm_fatal("REFMODEL", "axi_tniu_cfg not found on config-db")
  endfunction

  // ---------------------------------------------------------------------------
  // Main prediction entry point.
  // ---------------------------------------------------------------------------
  function axi_tniu_expect predict(rknp_seq_item req);
    axi_tniu_expect e = axi_tniu_expect::type_id::create("expect");
    int unsigned nbyte      = axi_tniu_protocol_pkg::NBYTEPERWORD;
    int unsigned start_off  = req.addr % nbyte;
    int unsigned total_byte = int'(req.len) + 1;
    int unsigned num_beats;

    bit          axi_wrap;        // WRAP that remains WRAP after width conversion
    int unsigned data_start_off;  // first AXI byte lane for non-WRAP/short-WRAP writes
    int unsigned wrap_rotate;     // WRW payload rotation, same as DUT offset_addr
    int unsigned src_byte_idx;    // source payload byte after WRW realignment
    int unsigned byte_pos;        // AXI byte position
    int unsigned beat_idx;        // AXI beat index
    int unsigned lane_idx;        // AXI byte lane

    e.req = req;
    e.txn_no = req.txn_no;
    // --- AXID mapping : OrderKey -> AxID -----------
    e.axid = axi_tniu_protocol_pkg::map_ordkey_to_axid(req.orderkey);


    // --- address mapping : SubRange selects AXI high address bits ------------
    if (req.subr inside {[0:7]}) begin
      e.axaddr = axi_tniu_protocol_pkg::map_subr_addr_to_axaddr(req.subr, req.addr, req.opc, req.len);
    end else begin
      e.axaddr = 'x;
      `uvm_error("REFMODEL",$sformatf("No.%d Illegal RKNP SubRange: subr=0x%0h, valid range is 0~7",req.txn_no,req.subr))
    end

    // --- size fixed to full 64-bit beat -------------------------------------
    e.axsize = clog2_local(nbyte);

    // --- bufferable -> AxCACHE[0] -------------------------------------------
    e.cache_buf = req.bufferable;

    // --- QoS : urgency popcount == stored qos -------------------------------
    e.axqos = req.qos;

    // --- burst type + beat count --------------------------------------------
    // The DUT converts a WRAP shorter than one local flit into INCR.
    axi_wrap = req.is_wrap() && (req.len > 6);

    if (axi_wrap) begin
      e.axburst = 2'b10;                       // WRAP
      num_beats = (total_byte + nbyte - 1) / nbyte;
      if (num_beats < 1) num_beats = 1;
    end else begin
      e.axburst = 2'b01;                       // INCR
      num_beats = (start_off + total_byte + nbyte - 1) / nbyte;
      if (num_beats < 1) num_beats = 1;
    end
    e.axlen = num_beats - 1;

    // --- direction ----------------------------------------------------------
    e.dir = req.is_write() ? AXI_WRITE : AXI_READ;

    // --- ERR request : no downstream AXI txn, reflect ERR response ----------
    if (req.status == axi_tniu_protocol_pkg::ST_ERR) begin
      e.axi_valid   = 0;
      e.rsp_status  = axi_tniu_protocol_pkg::ST_ERR;
      e.rsp_errcode = axi_tniu_protocol_pkg::EC_ADDR_DEC;
    end else begin
      e.axi_valid   = 1;
      e.rsp_status  = axi_tniu_protocol_pkg::ST_OK;         // may be upgraded to ERR by SLVERR
      e.rsp_errcode = req.errcode;
    end

    // --- response opcode ----------------------------------------------------
    e.rsp_opc = req.is_write() ? axi_tniu_protocol_pkg::RSP_OPC_WR : axi_tniu_protocol_pkg::RSP_OPC_RD;

    // --- RKNP write body -> AXI WDATA/WSTRB -------------------------------
    e.axi_wdata = new[0];
    e.axi_wstrb = new[0];

    if (req.is_write()) begin
      e.axi_wdata = new[num_beats];
      e.axi_wstrb = new[num_beats];

      foreach (e.axi_wdata[i]) begin
        e.axi_wdata[i] = '0;
        e.axi_wstrb[i] = '0;
      end

      // INCR (including a short WRAP converted to INCR) keeps the original
      // address byte-lane offset. A real AXI WRAP is emitted from lane0.
      data_start_off = axi_wrap ? 0 : start_off;

      // wrap_align.v aligns an unaligned WRW address upward to the next local
      // beat and suppresses the original head flit. Consequently the first
      // AXI W beat starts at payload byte (NBYTEPERWORD - addr_offset), and
      // the skipped bytes wrap around to the end of the burst.
      //
      // Example for 8-byte AXI data and addr[2:0]==2:
      //   wrap_rotate = 6
      //   AXI payload = original_payload[6:$] + original_payload[0:5]
      wrap_rotate = 0;
      if (axi_wrap && (start_off != 0))
        wrap_rotate = nbyte - start_off;

      if (req.wr_bytes.size() < total_byte)
        `uvm_error("REFMODEL",
                   $sformatf("No.%d Write byte count mismatch: len=%0d expects %0d bytes, wr_bytes.size=%0d",
                             req.txn_no, req.len, total_byte, req.wr_bytes.size()))

      if (req.wr_be.size() < total_byte)
        `uvm_error("REFMODEL",
                   $sformatf("No.%d Write byte-enable count mismatch: len=%0d expects %0d bytes, wr_be.size=%0d",
                             req.txn_no, req.len, total_byte, req.wr_be.size()))

      for (int i = 0; i < total_byte; i++) begin
        src_byte_idx = axi_wrap ? ((i + wrap_rotate) % total_byte) : i;
        byte_pos     = data_start_off + i;
        beat_idx     = byte_pos / nbyte;
        lane_idx     = byte_pos % nbyte;

        if (beat_idx < num_beats) begin
          if (src_byte_idx < req.wr_bytes.size())
            e.axi_wdata[beat_idx][lane_idx*8 +: 8] = req.wr_bytes[src_byte_idx];

          if (src_byte_idx < req.wr_be.size())
            e.axi_wstrb[beat_idx][lane_idx] = req.wr_be[src_byte_idx];
          else
            e.axi_wstrb[beat_idx][lane_idx] = 1'b0;
        end
      end
    end



    return e;
  endfunction

  // local clog2 helper (avoids depending on $clog2 in a function context)
  function int clog2_local(int unsigned v);
    int r = 0;
    v = v - 1;
    while (v > 0) begin r++; v >>= 1; end
    return r;
  endfunction

endclass : axi_tniu_refmodel

`endif // AXI_TNIU_REFMODEL_SV
