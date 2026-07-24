// =============================================================================
// File        : tb_top.sv
// Description : Top-level testbench module. Generates clock/reset, instantiates
//               the DUT (axi_tniu) together with the RKNP and AXI interfaces,
//               publishes the virtual interface handles on the config-db and
//               starts the UVM test.
//
//               IMPORTANT - the DUT is elaborated with THIS verification
//               configuration's mode parameters:
//                 WRAP_ALIGN_MODE = 1  (wrap realign ON)
//                 EARLY_RSP_MODE  = 1  (bufferable / early response ON)
//                 ADDR_BP_TYPE    = 2  (WAW/WAR/RAW same-address ordering ON)
//                 NBYTEPERWORD    = 8  (64-bit AXI data)
//                 ORDKEY_WITH = 8, AXID_WITH = 4  (AXID mapping, 2x width)
//
//               The DUT instantiates several sub-modules (wrap_align,
//               wrap_adjust, req_order, rsp_order, addr_map, rreq_trans,
//               wreq_trans, rsp_trans, watchdog, ely_rsp_detect). Their RTL is
//               NOT part of this testbench package and MUST be supplied through
//               the compile filelist ($RTL_HOME) for elaboration to succeed.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`timescale 1ns/1ps

module tb_top;

  import uvm_pkg::*;
  import axi_tniu_pkg::*;

  // ---- DUT compile-time configuration --------------------------------------

  // ---------------------------------------------------------------------------
  // Field widths (match axi_tniu top-level parameters)
  // ---------------------------------------------------------------------------
  parameter int URGE_WITH     = axi_tniu_protocol_pkg::URGE_WITH;   // Urgency, bar-graph encoded
  parameter int SUBR_WITH     = axi_tniu_protocol_pkg::SUBR_WITH;   // SubRange
  parameter int IID_WITH      = axi_tniu_protocol_pkg::IID_WITH;   // Initiator ID
  parameter int TID_WITH      = axi_tniu_protocol_pkg::TID_WITH;   // Target ID
  parameter int ADDR_WITH     = axi_tniu_protocol_pkg::ADDR_WITH;   // RKNP address
  parameter int ORDKEY_WITH   = axi_tniu_protocol_pkg::ORDKEY_WITH;   // OrderKey (un-mapped AXID) = 2 * AXID_WITH
  parameter int LEN_WITH      = axi_tniu_protocol_pkg::LEN_WITH;   // Len = byte number minus 1
  parameter int USER_WITH     = axi_tniu_protocol_pkg::USER_WITH;   // User bits
  parameter int NBYTEPERWORD  = axi_tniu_protocol_pkg::NBYTEPERWORD;   // bytes per flow-control word -> 64-bit data

  // ---------------------------------------------------------------------------
  // REQUEST packet field bit-offsets (match REQ_*_OFFSET on axi_tniu)
  // Layout : [URGE][IID][TID][SUBR][ORDKEY][OPC][STATUS][LEN][ADDR][USER][ERRC]...
  // ---------------------------------------------------------------------------
  parameter int REQ_URGE_OFFSET     = axi_tniu_protocol_pkg::REQ_URGE_OFFSET;  // [0  +: 7]  Urgency (bar-graph QoS)
  parameter int REQ_IID_OFFSET      = axi_tniu_protocol_pkg::REQ_IID_OFFSET;  // [7  +: 10] Initiator ID
  parameter int REQ_TID_OFFSET      = axi_tniu_protocol_pkg::REQ_TID_OFFSET;  // [17 +: 10] Target ID
  parameter int REQ_SUBR_OFFSET     = axi_tniu_protocol_pkg::REQ_SUBR_OFFSET;  // [27 +: 8]  SubRange
  parameter int REQ_ORDKEY_OFFSET   = axi_tniu_protocol_pkg::REQ_ORDKEY_OFFSET;  // [35 +: 8]  OrderKey (un-mapped AXID)
  parameter int REQ_OPC_OFFSET      = axi_tniu_protocol_pkg::REQ_OPC_OFFSET;  // [43 +: 4]  Opcode
  parameter int REQ_STATUS_OFFSET   = axi_tniu_protocol_pkg::REQ_STATUS_OFFSET;  // [47 +: 2]  Status
  parameter int REQ_LEN_OFFSET      = axi_tniu_protocol_pkg::REQ_LEN_OFFSET;  // [49 +: 8]  Len (byte number - 1)
  parameter int REQ_ADDR_OFFSET     = axi_tniu_protocol_pkg::REQ_ADDR_OFFSET;  // [57 +: 32] Address
  parameter int REQ_USER_OFFSET     = axi_tniu_protocol_pkg::REQ_USER_OFFSET;  // [89 +: 10] User (bit0 = bufferable)
  parameter int REQ_ERRC_OFFSET     = axi_tniu_protocol_pkg::REQ_ERRC_OFFSET;  // [99 +: 3]  ErrorCode ([103:102] reserved)
  parameter int REQ_HEAD_LEN_OFFSET = axi_tniu_protocol_pkg::REQ_HEAD_LEN_OFFSET;  // head ends / first body word starts here
  parameter int REQ_FLIT_WITH       = axi_tniu_protocol_pkg::REQ_FLIT_WITH;

  // ---------------------------------------------------------------------------
  // RESPONSE packet field bit-offsets (match RSP_*_OFFSET on axi_tniu)
  // Layout : [URGE][IID][TID][ORDKEY][OPC][STATUS][ADDR(8)][USER][ERRC]...
  // ---------------------------------------------------------------------------
  parameter int RSP_URGE_OFFSET     = axi_tniu_protocol_pkg::RSP_URGE_OFFSET;
  parameter int RSP_IID_OFFSET      = axi_tniu_protocol_pkg::RSP_IID_OFFSET;
  parameter int RSP_TID_OFFSET      = axi_tniu_protocol_pkg::RSP_TID_OFFSET;
  parameter int RSP_ORDKEY_OFFSET   = axi_tniu_protocol_pkg::RSP_ORDKEY_OFFSET;
  parameter int RSP_OPC_OFFSET      = axi_tniu_protocol_pkg::RSP_OPC_OFFSET;  // 2 bits
  parameter int RSP_STATUS_OFFSET   = axi_tniu_protocol_pkg::RSP_STATUS_OFFSET;  // 2 bits
  parameter int RSP_ADDR_OFFSET     = axi_tniu_protocol_pkg::RSP_ADDR_OFFSET;  // [39 +: 32] Address field
  parameter int RSP_USER_OFFSET     = axi_tniu_protocol_pkg::RSP_USER_OFFSET;
  parameter int RSP_ERRC_OFFSET     = axi_tniu_protocol_pkg::RSP_ERRC_OFFSET;  // 3 bits
  parameter int RSP_HEAD_LEN_OFFSET = axi_tniu_protocol_pkg::RSP_HEAD_LEN_OFFSET;
  parameter int RSP_FLIT_WITH       = axi_tniu_protocol_pkg::RSP_FLIT_WITH;




  // ===========================================================================
  // AXI fixed interface WITHs
  // ===========================================================================

  localparam int AXID_WITH      = axi_tniu_protocol_pkg::AXID_WITH;
  localparam int AUSER_WITH     = axi_tniu_protocol_pkg::AUSER_WITH;
  localparam int AADDR_WITH     = axi_tniu_protocol_pkg::AADDR_WITH;
  localparam int AQOS_WITH      = axi_tniu_protocol_pkg::AQOS_WITH;  // implemented WITH in this DUT

  // ===========================================================================
  // Fixed DUT build-mode constants
  // ===========================================================================
  parameter int TIMOUT_VALUE    = axi_tniu_protocol_pkg::TIMOUT_VALUE;  //支持最大请求个数
  parameter int SUP_REQ_NUM     = axi_tniu_protocol_pkg::SUP_REQ_NUM; //支持最大请求个数
  parameter int ADDR_BLOCK_SIZE = axi_tniu_protocol_pkg::ADDR_BLOCK_SIZE;
  parameter int ADDR_BP_TYPE    = axi_tniu_protocol_pkg::ADDR_BP_TYPE; // 0:无同地址反压  1:写后读/写后写同地址反压   2:写后读/写后写/读后写同地址反压
  parameter int EARLY_RSP_MODE  = axi_tniu_protocol_pkg::EARLY_RSP_MODE; // 0：关闭early response模式    1：开启early response模式
  parameter int WRAP_ALIGN_MODE = axi_tniu_protocol_pkg::WRAP_ALIGN_MODE; // 0：关闭wrap align模式    1：开启wrap align模式
  parameter int RWRAP_CNT_MAX   = axi_tniu_protocol_pkg::RWRAP_CNT_MAX;
  parameter int PS_SWITCH       = axi_tniu_protocol_pkg::PS_SWITCH; //0:并行输出，1：串行输出

  // ---- clock / reset -------------------------------------------------------
  logic aclk;
  logic aresetn;

  initial begin
    aclk = 1'b0;
    forever #5ns aclk = ~aclk;      // 100 MHz
  end

  initial begin
    aresetn = 1'b0;
    repeat (5) @(posedge aclk);
    aresetn = 1'b1;
  end

  // ---- interfaces ----------------------------------------------------------
  rknp_if #(
    .REQ_FLIT_WITH (REQ_FLIT_WITH),
    .RSP_FLIT_WITH (RSP_FLIT_WITH)
  ) rknp_vif (.aclk(aclk), .aresetn(aresetn));

  axi_if #(
    .AXID_WITH    (AXID_WITH),
    .AADDR_WITH   (AADDR_WITH),
    .NBYTEPERWORD (NBYTEPERWORD),
    .AUSER_WITH   (AUSER_WITH),
    .AQOS_WITH    (AQOS_WITH)
  ) axi_vif (.aclk(aclk), .aresetn(aresetn));

  // ---- DUT -----------------------------------------------------------------
  axi_tniu #(
     //RKNoC可配置位宽域段参数
     .URGE_WITH            (URGE_WITH)      
    ,.SUBR_WITH            (SUBR_WITH)        
    ,.IID_WITH             (IID_WITH)   
    ,.TID_WITH             (TID_WITH)      
    ,.ADDR_WITH            (ADDR_WITH)        
    ,.AXID_WITH            (AXID_WITH)          
    ,.ORDKEY_WITH          (ORDKEY_WITH)         
    ,.LEN_WITH             (LEN_WITH)         
    ,.USER_WITH            (USER_WITH)          
    ,.NBYTEPERWORD         (NBYTEPERWORD)            

    //req packet域段偏移量参数
    ,.REQ_IID_OFFSET       (REQ_IID_OFFSET) 
    ,.REQ_TID_OFFSET       (REQ_TID_OFFSET)          
    ,.REQ_SUBR_OFFSET      (REQ_SUBR_OFFSET)     
    ,.REQ_ORDKEY_OFFSET    (REQ_ORDKEY_OFFSET)       
    ,.REQ_OPC_OFFSET       (REQ_OPC_OFFSET)    
    ,.REQ_STATUS_OFFSET    (REQ_STATUS_OFFSET)       
    ,.REQ_LEN_OFFSET       (REQ_LEN_OFFSET)    
    ,.REQ_ADDR_OFFSET      (REQ_ADDR_OFFSET)      
    ,.REQ_USER_OFFSET      (REQ_USER_OFFSET)     
    ,.REQ_ERRC_OFFSET      (REQ_ERRC_OFFSET)      
    ,.REQ_HEAD_LEN_OFFSET  (REQ_HEAD_LEN_OFFSET)          
    ,.REQ_FLIT_WITH        (REQ_FLIT_WITH)     

    //rsp packet域段偏移量参数
    ,.RSP_IID_OFFSET       (RSP_IID_OFFSET)        
    ,.RSP_TID_OFFSET       (RSP_TID_OFFSET)        
    ,.RSP_ORDKEY_OFFSET    (RSP_ORDKEY_OFFSET)           
    ,.RSP_OPC_OFFSET       (RSP_OPC_OFFSET)        
    ,.RSP_STATUS_OFFSET    (RSP_STATUS_OFFSET)           
    ,.RSP_ADDR_OFFSET      (RSP_ADDR_OFFSET)          
    ,.RSP_USER_OFFSET      (RSP_USER_OFFSET)         
    ,.RSP_ERRC_OFFSET      (RSP_ERRC_OFFSET)          
    ,.RSP_HEAD_LEN_OFFSET  (RSP_HEAD_LEN_OFFSET)              
    ,.RSP_FLIT_WITH        (RSP_FLIT_WITH)        

    //AXI可配置接口位宽参数
    ,.AADDR_WITH           (AADDR_WITH)        
    ,.AUSER_WITH           (AUSER_WITH)        
    ,.AQOS_WITH            (AQOS_WITH)       
    
    //watchdog计数器配置参数
    ,.TIMOUT_VALUE         (TIMOUT_VALUE)         //可配置最大超时值（限制大于3，默认值为1024）  

    //模式配置参数
    ,.SUP_REQ_NUM          (SUP_REQ_NUM)          //支持最大请求个数
    ,.ADDR_BLOCK_SIZE      (ADDR_BLOCK_SIZE)             
    ,.ADDR_BP_TYPE         (ADDR_BP_TYPE)         // 0:无同地址反压  1:写后读/写后写同地址反压   2:写后读/写后写/读后写同地址反压
    ,.EARLY_RSP_MODE       (EARLY_RSP_MODE)       // 0：关闭early response模式    1：开启early response模式
    ,.WRAP_ALIGN_MODE      (WRAP_ALIGN_MODE)      // 0：关闭wrap align模式    1：开启wrap align模式
    ,.RWRAP_CNT_MAX        (RWRAP_CNT_MAX)           
    ,.PS_SWITCH            (PS_SWITCH)            //0:并行输出，1：串行输出
  ) dut (
    .aclk    (aclk),
    .aresetn (aresetn),

    // RKNP request channel
    .rknp_rxreq_head  (rknp_vif.rxreq_head),
    .rknp_rxreq_tail  (rknp_vif.rxreq_tail),
    .rknp_rxreq_valid (rknp_vif.rxreq_valid),
    .rknp_rxreq_ready (rknp_vif.rxreq_ready),
    .rknp_rxreq_data  (rknp_vif.rxreq_data),
    // RKNP response channel
    .rknp_txrsp_head  (rknp_vif.txrsp_head),
    .rknp_txrsp_tail  (rknp_vif.txrsp_tail),
    .rknp_txrsp_valid (rknp_vif.txrsp_valid),
    .rknp_txrsp_ready (rknp_vif.txrsp_ready),
    .rknp_txrsp_data  (rknp_vif.txrsp_data),

    // AXI AW
    .axi_m_awvalid (axi_vif.awvalid),
    .axi_m_awready (axi_vif.awready),
    .axi_m_awid    (axi_vif.awid),
    .axi_m_awaddr  (axi_vif.awaddr),
    .axi_m_awlen   (axi_vif.awlen),
    .axi_m_awsize  (axi_vif.awsize),
    .axi_m_awburst (axi_vif.awburst),
    .axi_m_awlock  (axi_vif.awlock),
    .axi_m_awcache (axi_vif.awcache),
    .axi_m_awprot  (axi_vif.awprot),
    .axi_m_awqos   (axi_vif.awqos),
    .axi_m_awuser  (axi_vif.awuser),
    // AXI W
    .axi_m_wvalid  (axi_vif.wvalid),
    .axi_m_wready  (axi_vif.wready),
    .axi_m_wlast   (axi_vif.wlast),
    .axi_m_wid     (axi_vif.wid),
    .axi_m_wdata   (axi_vif.wdata),
    .axi_m_wstrb   (axi_vif.wstrb),
    // AXI AR
    .axi_m_arvalid (axi_vif.arvalid),
    .axi_m_arready (axi_vif.arready),
    .axi_m_arid    (axi_vif.arid),
    .axi_m_araddr  (axi_vif.araddr),
    .axi_m_arlen   (axi_vif.arlen),
    .axi_m_arsize  (axi_vif.arsize),
    .axi_m_arburst (axi_vif.arburst),
    .axi_m_arlock  (axi_vif.arlock),
    .axi_m_arcache (axi_vif.arcache),
    .axi_m_arprot  (axi_vif.arprot),
    .axi_m_arqos   (axi_vif.arqos),
    .axi_m_aruser  (axi_vif.aruser),
    // AXI R
    .axi_m_rvalid  (axi_vif.rvalid),
    .axi_m_rready  (axi_vif.rready),
    .axi_m_rid     (axi_vif.rid),
    .axi_m_rdata   (axi_vif.rdata),
    .axi_m_rresp   (axi_vif.rresp),
    .axi_m_ruser   (axi_vif.ruser),
    .axi_m_rlast   (axi_vif.rlast),
    // AXI B
    .axi_m_bvalid  (axi_vif.bvalid),
    .axi_m_bready  (axi_vif.bready),
    .axi_m_bid     (axi_vif.bid),
    .axi_m_bresp   (axi_vif.bresp),
    .axi_m_buser   (axi_vif.buser)
  );

  // ---- publish virtual interfaces + start test -----------------------------
  initial begin
    uvm_config_db#(virtual rknp_if)::set(null, "uvm_test_top.env.rknp_agt.*", "vif", rknp_vif);
    uvm_config_db#(virtual rknp_if)::set(null, "uvm_test_top.env.rknp_agt",   "vif", rknp_vif);
    uvm_config_db#(virtual axi_if )::set(null, "uvm_test_top.env.axi_agt.*",  "vif", axi_vif);
    uvm_config_db#(virtual axi_if )::set(null, "uvm_test_top.env.axi_agt",    "vif", axi_vif);
    run_test();
  end

  // ---- global watchdog : avoid hangs if a response is lost -----------------
  initial begin
    #2ms;
    `uvm_fatal("TB_TOP", "global timeout reached - simulation stuck")
  end

  // ---- optional FSDB waveform dump (Verdi) ---------------------------------
//`ifdef FSDB
  initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0, tb_top, "+all");
    $fsdbDumpMDA();          // dump multi-dimensional arrays / memories
  end
//`endif

endmodule : tb_top
