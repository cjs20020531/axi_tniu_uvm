//=============================================================================
// Copyright(c) 2011, Rockchips Electronics Co, Ltd
// Filename          : rreq_trans.v
// Auther            : cjs
// Email             : 
// Created On        : 2025-08-07
// Abstract          : RKNP read request to AXI AR bridge.
//
// The AR channel is driven directly from the current read-request head flit.
// addr_map/rsp_order keeps that flit stable while ARREADY is low, so no
// additional pipeline register is required here.  ARVALID is independent of
// ARREADY, as required by AXI.
// Parameter         :
// Modified History  :
//=============================================================================

module rreq_trans#(

     parameter URGE_WITH = 7
    ,parameter SUBR_WITH = 8
    ,parameter AXID_WITH = 4
    ,parameter LEN_WITH = 8 
    ,parameter USER_WITH = 10
    ,parameter NBYTEPERWORD = 8
    
    ,parameter AADDR_WITH = 40
    ,parameter AUSER_WITH = 1
    ,parameter AQOS_WITH = 3
    ,parameter DLY = 1
)(

     input                              clk
    ,input                              resetn
    // The interface signals of addr_map
    ,input                              am2rreqt_head
    ,input                              am2rreqt_tail
    ,input                              am2rreqt_valid
    ,output                             rreqt2am_ready
    ,input       [AADDR_WITH-1:0]       am2rreqt_araddr
    ,input       [AXID_WITH-1:0]        am2rreqt_axid
    ,input       [1:0]                  am2rreqt_opc
    ,input       [7:0]                  am2rreqt_arlen
    ,input       [USER_WITH-1:0]        am2rreqt_user
    ,input       [AQOS_WITH-1:0]        am2rreqt_arqos

    // The interface signals of AXI AR channel
    ,output reg                         axi_m_arvalid
    ,input                              axi_m_arready
    ,output reg  [AXID_WITH-1:0]        axi_m_arid
    ,output reg  [AADDR_WITH-1:0]       axi_m_araddr
    ,output reg  [7:0]                  axi_m_arlen
    ,output reg  [2:0]                  axi_m_arsize
    ,output reg  [1:0]                  axi_m_arburst
    ,output reg                         axi_m_arlock
    ,output reg  [3:0]                  axi_m_arcache
    ,output reg  [2:0]                  axi_m_arprot
    ,output reg  [AQOS_WITH-1:0]        axi_m_arqos
    ,output reg  [AUSER_WITH-1:0]       axi_m_aruser
    

);

// The upstream request is consumed in the same cycle as the AXI AR
// handshake.  When ARREADY is low, rsp_order holds the current head flit and
// therefore all direct payload connections below remain stable.
assign rreqt2am_ready = axi_m_arready;

always @(*) begin
    axi_m_arvalid = am2rreqt_valid & am2rreqt_head;
    axi_m_arid    = am2rreqt_axid;
    axi_m_araddr  = am2rreqt_araddr;
    axi_m_arlen   = am2rreqt_arlen;
    axi_m_arsize  = $clog2(NBYTEPERWORD);
    axi_m_arburst = am2rreqt_opc + 1'b1;
    axi_m_arlock  = am2rreqt_user[7];
    axi_m_arcache = am2rreqt_user[3:0];
    axi_m_arprot  = am2rreqt_user[6:4];
    axi_m_arqos   = am2rreqt_arqos;
    axi_m_aruser  = am2rreqt_user[8];
end

endmodule
