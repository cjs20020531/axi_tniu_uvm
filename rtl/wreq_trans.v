//=============================================================================
// Copyright(c) 2011, Rockchips Electronics Co, Ltd
// Filename          : req_order.v
// Auther            : cjs
// Email             : 
// Created On        : 2025-08-07
// Abstract          : 1.将RKNP协议写请求head部分信号转化为AXI AW通道信号；
//                     2.将RKNP协议写请求body部分信号转化为AXI W通道信号；
// Parameter         :
// Modified History  :
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

    // The interface signals of AXI AW channel
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
    
    // The interface signals of AXI W channel
    ,output reg                         axi_m_wvalid
    ,input                              axi_m_wready
    ,output reg                         axi_m_wlast
    ,output reg  [AXID_WITH-1:0]        axi_m_wid
    ,output reg  [8*NBYTEPERWORD-1:0]   axi_m_wdata
    ,output reg  [NBYTEPERWORD-1:0]     axi_m_wstrb

);

//-----------------------------------------------------------------
//  生成axi_m_awvalid信号
//-----------------------------------------------------------------

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) 
        axi_m_awvalid <= #DLY 1'b0;
    else if(am2wreqt_head == 1'b1 && wreqt2am_ready == 1'b1) 
        axi_m_awvalid <= #DLY 1'b1;
    else if(axi_m_awready == 1'b1)
        axi_m_awvalid <= #DLY 1'b0;
end

//-----------------------------------------------------------------
//  传输配置信息
//-----------------------------------------------------------------

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        axi_m_awid    <= #DLY 'd0 ; 
        axi_m_wid     <= #DLY 'd0 ;
        axi_m_awaddr  <= #DLY 'd0 ;   
        axi_m_awlen   <= #DLY 'd0 ;  
        axi_m_awsize  <= #DLY 'd0 ;  
        axi_m_awburst <= #DLY 'd0 ;     
        axi_m_awlock  <= #DLY 'd0 ;    
        axi_m_awcache <= #DLY 'd0 ;       
        axi_m_awprot  <= #DLY 'd0 ;    
        axi_m_awqos   <= #DLY 'd0 ;    
        axi_m_awuser  <= #DLY 'd0 ;     
    end else if(am2wreqt_head == 1'b1 && wreqt2am_ready == 1'b1) begin
        axi_m_awid    <= #DLY am2wreqt_axid;
        axi_m_wid     <= #DLY am2wreqt_axid;
        axi_m_awaddr  <= #DLY am2wreqt_awaddr;   
        axi_m_awlen   <= #DLY am2wreqt_awlen;       
        axi_m_awsize  <= #DLY $clog2(NBYTEPERWORD);         
        axi_m_awburst <= #DLY am2wreqt_opc + 1'b1;        
        axi_m_awlock  <= #DLY am2wreqt_user[7];          
        axi_m_awcache <= #DLY am2wreqt_user[3:0];           
        axi_m_awprot  <= #DLY am2wreqt_user[6:4];         
        axi_m_awuser  <= #DLY am2wreqt_user[8];   
        axi_m_awqos   <= #DLY am2wreqt_awqos;        
    end
end

//-----------------------------------------------------------------
//  传输数据与选通信号
//-----------------------------------------------------------------
wire [8*NBYTEPERWORD-1:0] wdata;
wire [NBYTEPERWORD-1:0] wstrb;
genvar i;
generate
    for(i=0;i<NBYTEPERWORD;i=i+1) begin
        assign wdata[8*(i+1)-1 : 8*i] = am2wreqt_data[9*(i+1) : 9*i+2];
        assign wstrb[i] = am2wreqt_data[9*i+1];
    end
endgenerate

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        axi_m_wdata <= #DLY 'd0 ;  
        axi_m_wstrb <= #DLY 'd0;      
    end else if(am2wreqt_valid == 1'b1 && wreqt2am_ready == 1'b1) begin
        axi_m_wdata <= #DLY wdata;               
        axi_m_wstrb <= #DLY wstrb;
    end
end

//-----------------------------------------------------------------
//  生成wlast信号
//-----------------------------------------------------------------
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) 
        axi_m_wlast <= #DLY 'd0 ;     
    else if(am2wreqt_tail == 1'b1 && wreqt2am_ready == 1'b1) 
        axi_m_wlast <= #DLY 'd1;              
    else if(axi_m_wready == 1'b1)
        axi_m_wlast <= #DLY 'd0; 
end

//-----------------------------------------------------------------
//  生成awvalid信号
//-----------------------------------------------------------------

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) 
        axi_m_awvalid <= #DLY 'd0 ;     
    else if(am2wreqt_head == 1'b1 && wreqt2am_ready == 1'b1) 
        axi_m_awvalid <= #DLY 'd1;              
    else if(axi_m_awready == 1'b1)
        axi_m_awvalid <= #DLY 'd0; 
end

//-----------------------------------------------------------------
//  生成wvalid信号
//-----------------------------------------------------------------

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) 
        axi_m_wvalid <= #DLY 'd0 ;     
    else if(am2wreqt_valid == 1'b1 && wreqt2am_ready == 1'b1) 
        axi_m_wvalid <= #DLY 'd1;              
    else if(axi_m_wready == 1'b1) 
        axi_m_wvalid <= #DLY 'd0; 
end

//-----------------------------------------------------------------
//  生成wreqt2am_ready信号
//-----------------------------------------------------------------

assign wreqt2am_ready = (am2wreqt_head == 1'b1) ? (axi_m_awready & axi_m_wready) : axi_m_wready;


endmodule