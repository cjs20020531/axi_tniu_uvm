// =============================================================================
// File        : axi_tniu_protocol_pkg.sv
// Description : Compile-time protocol, structural, WITH, field-layout and DUT
//               mode constants shared by RTL and the UVM verification
//               environment.
//
//               This package is the single source of truth for:
//                 - AXI interface WITHs used by axi_tniu
//                 - RKNP request/response field WITHs and bit offsets
//                 - RKNP opcode/status/error encodings
//                 - RKNP flit and body layout
//                 - Fixed DUT structural parameters
//                 - Fixed DUT build-mode constants
//                 - Pure protocol helper functions
//
//               Runtime UVM policies such as back-pressure, delays, error
//               injection percentages and transaction counts belong in
//               axi_tniu_cfg.sv, not in this package.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_TNIU_PROTOCOL_PKG_SV
`define AXI_TNIU_PROTOCOL_PKG_SV

package axi_tniu_protocol_pkg;

  // ---------------------------------------------------------------------------
  // Field widths (match axi_tniu top-level parameters)
  // ---------------------------------------------------------------------------
  parameter int URGE_WITH     = 7;    // Urgency, bar-graph encoded
  parameter int SUBR_WITH     = 8;    // SubRange
  parameter int IID_WITH      = 10;   // Initiator ID
  parameter int TID_WITH      = 10;   // Target ID
  parameter int ADDR_WITH     = 32;   // RKNP address
  parameter int ORDKEY_WITH   = 8;    // OrderKey (un-mapped AXID) = 2 * AXID_WITH
  parameter int LEN_WITH      = 8;    // Len = byte number minus 1
  parameter int USER_WITH     = 10;   // User bits
  parameter int NBYTEPERWORD  = 8;    // bytes per flow-control word -> 64-bit data

  // ---------------------------------------------------------------------------
  // REQUEST packet field bit-offsets (match REQ_*_OFFSET on axi_tniu)
  // Layout : [URGE][IID][TID][SUBR][ORDKEY][OPC][STATUS][LEN][ADDR][USER][ERRC]...
  // ---------------------------------------------------------------------------
  parameter int REQ_URGE_OFFSET     = 0;    // [0  +: 7]  Urgency (bar-graph QoS)
  parameter int REQ_IID_OFFSET      = 7;    // [7  +: 10] Initiator ID
  parameter int REQ_TID_OFFSET      = 17;   // [17 +: 10] Target ID
  parameter int REQ_SUBR_OFFSET     = 27;   // [27 +: 8]  SubRange
  parameter int REQ_ORDKEY_OFFSET   = 35;   // [35 +: 8]  OrderKey (un-mapped AXID)
  parameter int REQ_OPC_OFFSET      = 43;   // [43 +: 4]  Opcode
  parameter int REQ_STATUS_OFFSET   = 47;   // [47 +: 2]  Status
  parameter int REQ_LEN_OFFSET      = 49;   // [49 +: 8]  Len (byte number - 1)
  parameter int REQ_ADDR_OFFSET     = 57;   // [57 +: 32] Address
  parameter int REQ_USER_OFFSET     = 89;   // [89 +: 10] User (bit0 = bufferable)
  parameter int REQ_ERRC_OFFSET     = 99;   // [99 +: 3]  ErrorCode ([103:102] reserved)
  parameter int REQ_HEAD_LEN_OFFSET = 102;  // head ends / first body word starts here
  parameter int REQ_FLIT_WITH       = 175;

  // ---------------------------------------------------------------------------
  // RESPONSE packet field bit-offsets (match RSP_*_OFFSET on axi_tniu)
  // Layout : [URGE][IID][TID][ORDKEY][OPC][STATUS][ADDR(8)][USER][ERRC]...
  // ---------------------------------------------------------------------------
  parameter int RSP_URGE_OFFSET     = 0;
  parameter int RSP_IID_OFFSET      = 7;
  parameter int RSP_TID_OFFSET      = 17;
  parameter int RSP_ORDKEY_OFFSET   = 27;
  parameter int RSP_OPC_OFFSET      = 35;   // 2 bits
  parameter int RSP_STATUS_OFFSET   = 37;   // 2 bits
  parameter int RSP_ADDR_OFFSET     = 39;   // [39 +: 32] Address field
  parameter int RSP_USER_OFFSET     = 71;
  parameter int RSP_ERRC_OFFSET     = 81;   // 3 bits
  parameter int RSP_HEAD_LEN_OFFSET = 84;
  parameter int RSP_FLIT_WITH       = 157;

  parameter int RSP_ADDR_LOW_WITH   = 8;    // rsp Addr field is 32b; typically only
                                            // the low 8 bits (byte offset) are used

  // ---------------------------------------------------------------------------
  // Body layout for HeadPenalty=0 : data field width = head + 1 + 9*NBYTEPERWORD
  // Per flow-control word: 1 LW bit, then per byte { Be(1), Byte(8) }.
  // ---------------------------------------------------------------------------
  parameter int BODY_WORD_WITH = 1 + 9*NBYTEPERWORD;   // LW + N*(Be+Byte) = 73



  // ===========================================================================
  // AXI fixed interface WITHs
  // ===========================================================================

  localparam int AXI_STRB_WITH  = NBYTEPERWORD;
  localparam int AXID_WITH      = 4;
  localparam int AUSER_WITH     = 1; 
  localparam int AADDR_WITH     = 40;
  localparam int ALEN_WITH      = 8;
  localparam int ASIZE_WITH     = 3;
  localparam int AQOS_WITH      = 3;  // implemented WITH in this DUT

  // ===========================================================================
  // Fixed DUT build-mode constants
  // ===========================================================================
  parameter int TIMOUT_VALUE    = 1024;  //支持最大请求个数

  parameter int SUP_REQ_NUM     = 8;  //支持最大请求个数
  parameter int ADDR_BLOCK_SIZE = 64;
  parameter int ADDR_BP_TYPE    = 0;  // 0:无同地址反压  1:写后读/写后写同地址反压   2:写后读/写后写/读后写同地址反压
  parameter int EARLY_RSP_MODE  = 1;  // 0：关闭early response模式    1：开启early response模式
  parameter int WRAP_ALIGN_MODE = 1;  // 0：关闭wrap align模式    1：开启wrap align模式
  parameter int RWRAP_CNT_MAX   = 4;
  parameter int PS_SWITCH       = 0;  //0:并行输出，1：串行输出




  

  // ===========================================================================
  // Strongly typed protocol vectors
  // ===========================================================================

  typedef logic [AXID_WITH-1:0]   axi_id_t;
  typedef logic [AADDR_WITH-1:0]  axi_addr_t;
  typedef logic [ORDKEY_WITH-1:0]   ordkey_t;
  typedef logic [REQ_FLIT_WITH-1:0] req_flit_t;
  typedef logic [RSP_FLIT_WITH-1:0] rsp_flit_t;
  typedef logic [URGE_WITH-1:0]   urg_t;
  typedef logic [AQOS_WITH-1:0]   qos_t;

  typedef logic [IID_WITH + TID_WITH + ORDKEY_WITH - 1:0] rknp_txn_key_t;

  // ===========================================================================
  // RKNP protocol encodings
  // ===========================================================================

  typedef enum logic [3:0] {
    OPC_RD  = 4'b0000,
    OPC_RDW = 4'b0001,
    OPC_WR  = 4'b0100,
    OPC_WRW = 4'b0101
  } req_opc_e;

  typedef enum logic [1:0] {
    RSP_OPC_RD = 2'b00,
    RSP_OPC_WR = 2'b01
  } rsp_opc_e;

  typedef enum logic [1:0] {
    ST_OK   = 2'b00,
    ST_ERR  = 2'b01,
    ST_CONT = 2'b10
  } status_e;

  typedef enum logic [2:0] {
    EC_TARGET     = 3'b000,
    EC_ADDR_DEC   = 3'b001,
    EC_UNSUP      = 3'b010,
    EC_DISCONN    = 3'b011,
    EC_SEC        = 3'b100,
    EC_HIDDEN_SEC = 3'b101,
    EC_TIMEOUT    = 3'b110,
    EC_RSVD       = 3'b111
  } errcode_e;

  // ===========================================================================
  // Pure protocol helpers
  // ===========================================================================

  function automatic axi_id_t map_ordkey_to_axid(input ordkey_t ordkey);
      axi_id_t low_part;
      axi_id_t mid_part;
      axi_id_t high_part;

      low_part  = axi_id_t'(ordkey);
      mid_part  = axi_id_t'(ordkey >> AXID_WITH);
      high_part = axi_id_t'(ordkey >> (2*AXID_WITH));

      if (ORDKEY_WITH <= AXID_WITH)
        return low_part;
      else if (ORDKEY_WITH <= 2*AXID_WITH)
        return low_part ^ mid_part;
      else if (ORDKEY_WITH <= 3*AXID_WITH)
        return low_part ^ mid_part ^ high_part;
      else
        return low_part;
  endfunction
  // ===========================================================================
  // SubRange + RKNP address -> AXI address mapping.
  // RDW: align downward to the Target NIU word boundary.
  // WRW: align upward   to the Target NIU word boundary.
  // ===========================================================================
  function automatic logic [AADDR_WITH-1:0] map_subr_addr_to_axaddr(
     input logic [SUBR_WITH-1:0] subr
    ,input logic [ADDR_WITH-1:0] addr
    ,input req_opc_e             opc
    ,input logic [7:0]           len
  );
    logic [ADDR_WITH-1:0] aligned_down_addr;
    logic [ADDR_WITH-1:0] mapped_local_addr;
    logic [AADDR_WITH-ADDR_WITH-1:0] subr_base;

    aligned_down_addr = (addr >> $clog2(NBYTEPERWORD)) << $clog2(NBYTEPERWORD);

    mapped_local_addr = addr;

    if(len > 6) begin
      case (opc)
        // Read WRAP: unaligned addresses are aligned downward.
        OPC_RDW: begin
          mapped_local_addr = aligned_down_addr;
        end
        // Write WRAP: unaligned addresses are aligned upward.
        // An already aligned address must remain unchanged; otherwise,
        // adding NBYTEPERWORD would incorrectly move it to the next word.
        OPC_WRW: begin
          if (addr == aligned_down_addr)
            mapped_local_addr = addr;
          else
            mapped_local_addr = aligned_down_addr + NBYTEPERWORD;
        end
        // Normal RD/WR and any other request types are not modified.
        default: begin
          mapped_local_addr = addr;
        end
    endcase
    end else begin
      mapped_local_addr = addr;
    end
    
    case (subr)
      8'd0:    subr_base = 8'h08;
      8'd1:    subr_base = 8'h10;
      8'd2:    subr_base = 8'h18;
      8'd3:    subr_base = 8'h20;
      8'd4:    subr_base = 8'h28;
      8'd5:    subr_base = 8'h30;
      8'd6:    subr_base = 8'h38;
      8'd7:    subr_base = 8'h40;
      // The sequence currently constrains subr to 0 through 7.
      // Keep a deterministic value if an illegal SubRange reaches here.
      default: subr_base = '0;
    endcase

    return {subr_base, mapped_local_addr};

  endfunction




  // QoS (binary) -> Urgency (bar-graph) encode, per RKNP spec table
  function automatic urg_t qos2urg(input qos_t qos);
    return (URGE_WITH'(1) << qos) - 1;   // QoS3 -> 0000111
  endfunction

  // Urgency (bar-graph) -> QoS (binary) decode = popcount
  function automatic qos_t urg2qos(input urg_t urg);
  qos_t q = '0;
    for (int i = 0; i < URGE_WITH; i++) q += urg[i];
    return q;
  endfunction

  // ---------------------------------------------------------------------------
  // Small helpers used by driver/monitor. Kept here so packing lives in ONE
  // place. get/set are bit-range accessors on the raw flit vector.
  // ---------------------------------------------------------------------------
  function automatic void set_field(ref req_flit_t flit,
                                    input int offset, input int width,
                                    input logic [63:0] value);
    for (int i = 0; i < width; i++) flit[offset+i] = value[i];
  endfunction

  function automatic logic [63:0] get_field(input req_flit_t flit,
                                            input int offset, input int width);
    logic [63:0] v = '0;
    for (int i = 0; i < width; i++) v[i] = flit[offset+i];
    return v;
  endfunction
  //---------------------------------------------------------------------------
  // 拼接生成请求-响应标签匹配键
  //---------------------------------------------------------------------------
  function automatic rknp_txn_key_t make_rknp_txn_key(
                                        input logic [IID_WITH-1:0] iid,
                                        input logic [TID_WITH-1:0] tid,
                                        input logic [ORDKEY_WITH-1:0] orderkey);
    return {iid, tid, orderkey};
  endfunction


endpackage : axi_tniu_protocol_pkg

`endif // AXI_TNIU_PROTOCOL_PKG_SV
