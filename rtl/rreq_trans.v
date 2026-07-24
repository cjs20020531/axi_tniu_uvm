//=============================================================================
// Copyright(c) 2011, Rockchips Electronics Co, Ltd
// Filename          : req_order.v
// Auther            : cjs
// Email             : 
// Created On        : 2025-08-07
// Abstract          : 1.将RKNP协议读请求head部分信号转化为AXI AR通道信号；
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

//-----------------------------------------------------------------
//  生成axi_m_arvalid信号
//-----------------------------------------------------------------

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) 
        axi_m_arvalid <= #DLY 1'b0;
    else if(am2rreqt_head == 1'b1 && rreqt2am_ready == 1'b1) 
        axi_m_arvalid <= #DLY 1'b1;
    else if(axi_m_arready == 1'b1)
        axi_m_arvalid <= #DLY 1'b0;
end

//-----------------------------------------------------------------
//  传输配置信息
//-----------------------------------------------------------------

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        axi_m_arid    <= #DLY 'd0 ; 
        axi_m_araddr  <= #DLY 'd0 ;   
        axi_m_arlen   <= #DLY 'd0 ;  
        axi_m_arsize  <= #DLY 'd0 ;  
        axi_m_arburst <= #DLY 'd0 ;     
        axi_m_arlock  <= #DLY 'd0 ;    
        axi_m_arcache <= #DLY 'd0 ;       
        axi_m_arprot  <= #DLY 'd0 ;    
        axi_m_arqos   <= #DLY 'd0 ;    
        axi_m_aruser  <= #DLY 'd0 ;     
    end else if(am2rreqt_head == 1'b1 && rreqt2am_ready == 1'b1) begin
        axi_m_arid    <= #DLY am2rreqt_axid;
        axi_m_araddr  <= #DLY am2rreqt_araddr;   
        axi_m_arlen   <= #DLY am2rreqt_arlen;       
        axi_m_arsize  <= #DLY $clog2(NBYTEPERWORD);         
        axi_m_arburst <= #DLY am2rreqt_opc + 1'b1;        
        axi_m_arlock  <= #DLY am2rreqt_user[7];          
        axi_m_arcache <= #DLY am2rreqt_user[3:0];           
        axi_m_arprot  <= #DLY am2rreqt_user[6:4];         
        axi_m_aruser  <= #DLY am2rreqt_user[8];   
        axi_m_arqos   <= #DLY am2rreqt_arqos;        
    end
end


//-----------------------------------------------------------------
//  生成rreqt2am_ready信号
//-----------------------------------------------------------------

assign rreqt2am_ready = axi_m_arready;


endmodule