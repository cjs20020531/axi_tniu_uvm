//=============================================================================
// Copyright(c) 2011, Rockchips Electronics Co, Ltd
// Filename          : wreq_trans.v
// Abstract          : RKNP write request to AXI AW/W bridge.
//
// AW and W are independent AXI channels.  The bridge keeps the current
// addr_map flit stable until W is accepted and, for a head flit, AW is
// accepted too.  This prevents a shared-ready/registered-valid race from
// dropping a one-flit W burst when the slave applies back-pressure.
//=============================================================================

module wreq_trans#(
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
    ,input                              am2wreqt_head
    ,input                              am2wreqt_tail
    ,input                              am2wreqt_valid
    ,output                             wreqt2am_ready
    ,input       [AADDR_WITH-1:0]       am2wreqt_awaddr
    ,input       [AXID_WITH-1:0]        am2wreqt_axid
    ,input       [1:0]                  am2wreqt_opc
    ,input       [7:0]                  am2wreqt_awlen
    ,input       [USER_WITH-1:0]        am2wreqt_user
    ,input       [9*NBYTEPERWORD:0]     am2wreqt_data
    ,input       [AQOS_WITH-1:0]        am2wreqt_awqos

    // The interface signals of the AXI AW channel
    ,output reg                         axi_m_awvalid
    ,input                              axi_m_awready
    ,output reg  [AXID_WITH-1:0]        axi_m_awid
    ,output reg  [AADDR_WITH-1:0]       axi_m_awaddr
    ,output reg  [7:0]                  axi_m_awlen
    ,output reg  [2:0]                  axi_m_awsize
    ,output reg  [1:0]                  axi_m_awburst
    ,output reg                         axi_m_awlock
    ,output reg  [3:0]                  axi_m_awcache
    ,output reg  [2:0]                  axi_m_awprot
    ,output reg  [AQOS_WITH-1:0]        axi_m_awqos
    ,output reg  [AUSER_WITH-1:0]       axi_m_awuser

    // The interface signals of the AXI W channel
    ,output reg                         axi_m_wvalid
    ,input                              axi_m_wready
    ,output reg                         axi_m_wlast
    ,output reg  [AXID_WITH-1:0]        axi_m_wid
    ,output reg  [8*NBYTEPERWORD-1:0]   axi_m_wdata
    ,output reg  [NBYTEPERWORD-1:0]     axi_m_wstrb
);

wire [8*NBYTEPERWORD-1:0] wdata;
wire [NBYTEPERWORD-1:0]   wstrb;
genvar i;
generate
    for(i=0;i<NBYTEPERWORD;i=i+1) begin
        assign wdata[8*(i+1)-1 : 8*i] = am2wreqt_data[9*(i+1) : 9*i+2];
        assign wstrb[i] = am2wreqt_data[9*i+1];
    end
endgenerate

// A head flit transfers AW and W together.  Body flits only require W.
assign wreqt2am_ready = am2wreqt_head ? (axi_m_awready & axi_m_wready) : axi_m_wready;

// The addr_map source is held whenever wreqt2am_ready is low, so the
// combinational outputs below remain stable for an arbitrarily stalled AXI
// channel and satisfy the ready/valid protocol.
always @(*) begin

    // For the head flit, do not let either AXI channel handshake alone:
    // AWVALID waits for WREADY and WVALID waits for AWREADY.  This keeps
    // the shared upstream flit stable until both channels can transfer.
    axi_m_awvalid = am2wreqt_head & axi_m_wready;
    axi_m_awid    = am2wreqt_axid;
    axi_m_awaddr  = am2wreqt_awaddr;
    axi_m_awlen   = am2wreqt_awlen;
    axi_m_awsize  = $clog2(NBYTEPERWORD);
    axi_m_awburst = am2wreqt_opc + 1'b1;
    axi_m_awlock  = am2wreqt_user[7];
    axi_m_awcache = am2wreqt_user[3:0];
    axi_m_awprot  = am2wreqt_user[6:4];
    axi_m_awqos   = am2wreqt_awqos;
    axi_m_awuser  = am2wreqt_user[8];

    axi_m_wvalid  = am2wreqt_valid & (~am2wreqt_head | axi_m_awready);
    axi_m_wlast   = am2wreqt_tail & am2wreqt_valid;
    axi_m_wid     = am2wreqt_axid;
    axi_m_wdata   = wdata;
    axi_m_wstrb   = wstrb;
    
end

endmodule
