//=============================================================================
// Copyright(c) 2011, Rockchips Electronics Co, Ltd
// Filename          : rsp_trans.v
// Auther            : cjs
// Email             : 
// Created On        : 2025-08-04
// Abstract          : 该模块需要判断对特殊保序、超时响应与常规响应进行保序，其中特殊响应包括（对请求阶段的错误组织响应、组织early response）
// Parameter         :
// Modified History  :
//=============================================================================
module rsp_trans#(
     parameter AXID_WITH = 4
    ,parameter USER_WITH = 10

    ,parameter NBYTEPERWORD = 8
    ,parameter AUSER_WITH = 1
    ,parameter DLY = 1

)(
     input                              clk
    ,input                              resetn

    // The interface signals of AXI R channel
    ,input                              axi_m_rvalid
    ,output wire                        axi_m_rready
    ,input       [AXID_WITH-1:0]        axi_m_rid
    ,input       [8*NBYTEPERWORD-1:0]   axi_m_rdata
    ,input       [1:0]                  axi_m_rresp
    ,input       [AUSER_WITH-1:0]       axi_m_ruser
    ,input                              axi_m_rlast
    
    // The interface signals of AXI B channel
    ,input                              axi_m_bvalid
    ,output wire                        axi_m_bready
    ,input       [AXID_WITH-1:0]        axi_m_bid
    ,input       [1:0]                  axi_m_bresp
    ,input       [AUSER_WITH-1:0]       axi_m_buser

    // The interface signals of rsp_order
    ,output reg                         rspt2rspo_head
    ,output                             rspt2rspo_tail
    ,output                             rspt2rspo_valid
    ,input                              rspo2rspt_ready
    ,output      [AXID_WITH-1:0]        rspt2rspo_axid
    ,output      [AUSER_WITH-1:0]       rspt2rspo_auser
    ,output      [1:0]                  rspt2rspo_opc
    ,output reg  [2:0]                  rspt2rspo_errcode
    ,output reg  [1:0]                  rspt2rspo_status
    ,output      [9*NBYTEPERWORD:0]     rspt2rspo_data
    ,output                             rspt2rspo_lw

);

parameter R = 2'b00;
parameter W = 2'b01;

parameter OK   = 2'b00;
parameter ERR  = 2'b01;

parameter TIM_OUT = 3'b110;
//==========================================================  R/B通道选择功能  ===========================================================//
//-----------------------------------------------------------------
// 输入响应信号打拍，不打拍的化生成不了tail
//-----------------------------------------------------------------

reg                         rvalid;
reg  [AXID_WITH-1:0]        rid   ;
reg  [8*NBYTEPERWORD-1:0]  rdata ;
reg  [1:0]                  rresp ;
reg  [AUSER_WITH-1:0]       ruser ;
reg                         rlast ;
reg                         rhead ;
reg                         prev_rbeat_seen;
reg                         prev_rbeat_last;
reg  [AXID_WITH-1:0]        prev_rid;



always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rid    <= #DLY 'd0;
        rdata  <= #DLY 'd0;
        rresp  <= #DLY 2'd0;
        ruser  <= #DLY 'd0;
    end else if(axi_m_rready == 1'b1 && axi_m_rvalid == 1'b1)begin
        rid    <= #DLY axi_m_rid;
        rdata  <= #DLY axi_m_rdata;
        rresp  <= #DLY axi_m_rresp;
        ruser  <= #DLY axi_m_ruser;
    end
end

// HEAD marks the first accepted beat of an AXI read transaction, or the first
// beat of a resumed interleaving segment.  A RVALID gap by itself is not a
// packet boundary: when the next accepted beat carries the same RID and the
// previous accepted beat was not RLAST, it remains inside the current RKNP
// response packet and HEAD must stay low.
//
// Update the history only on a real AXI R handshake.  Looking at RID while
// RVALID is low would allow stale/idle bus values to create a false HEAD after
// an ordinary beat gap.
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rhead           <= #DLY 1'b0;
        prev_rbeat_seen <= #DLY 1'b0;
        prev_rbeat_last <= #DLY 1'b0;
        prev_rid        <= #DLY 'd0;
    end else if(axi_m_rready == 1'b1 && axi_m_rvalid == 1'b1) begin
        rhead <= #DLY (!prev_rbeat_seen ||
                       prev_rbeat_last ||
                       (axi_m_rid != prev_rid));
        prev_rbeat_seen <= #DLY 1'b1;
        prev_rbeat_last <= #DLY axi_m_rlast;
        prev_rid        <= #DLY axi_m_rid;
    end else if(rspo2rspt_ready == 1'b1) begin
        rhead <= #DLY 1'b0;
    end
end

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rlast <= #DLY 1'b0;
    end else if(axi_m_rready == 1'b1 && axi_m_rvalid == 1'b1 &&
                axi_m_rlast == 1'b1)begin
        rlast <= #DLY 1'b1;
    end else if(rspo2rspt_ready == 1'b1) begin
        rlast <= #DLY 1'b0;
    end
end

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rvalid <= #DLY 1'b0;
    end else if(axi_m_rready == 1'b1 && axi_m_rvalid == 1'b1)begin
        rvalid <= #DLY 1'b1;
    end else if(rspo2rspt_ready == 1'b1) begin
        rvalid <= #DLY 1'b0;
    end
end

reg                         bvalid;
reg  [AXID_WITH-1:0]        bid   ;
reg  [1:0]                  bresp ;
reg  [AUSER_WITH-1:0]       buser ;
wire                        axi_b_hs;
wire                        b_rsp_hs;

assign axi_b_hs = axi_m_bvalid & axi_m_bready;

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        bid    <= #DLY 'd0;
        bresp  <= #DLY 2'd0;
        buser  <= #DLY 'd0;
    end else if(axi_b_hs == 1'b1)begin
        bid    <= #DLY axi_m_bid;
        bresp  <= #DLY axi_m_bresp;
        buser  <= #DLY axi_m_buser;
    end
end

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        bvalid <= #DLY 1'b0;
    end else if(axi_b_hs == 1'b1)begin
        bvalid <= #DLY 1'b1;
    end else if(b_rsp_hs == 1'b1)begin
        bvalid <= #DLY 1'b0;
    end
end

//-----------------------------------------------------------------
//  生成rrsp_phase信号
//-----------------------------------------------------------------
// read_active describes whether the last accepted AXI R beat says that more
// beats are still expected.  It keeps R selected across legal inter-beat gaps;
// the independent B buffer below retains a B response while R has priority.
reg  read_active;
wire axi_r_hs;
wire rrsp_phase;

assign axi_r_hs = axi_m_rvalid & axi_m_rready;

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0)
        read_active <= #DLY 1'b0;
    else if(axi_r_hs == 1'b1)
        read_active <= #DLY ~axi_m_rlast;
end

// rvalid keeps read selection asserted while the accepted final beat is still
// buffered for rsp_order; read_active covers gaps between non-final beats.
assign rrsp_phase = rvalid | read_active;

//-----------------------------------------------------------------
//  生成bready信号
//-----------------------------------------------------------------
// Keep one AXI B response in an independent buffer.  BREADY describes space
// in this buffer; it must not depend on the transient R-channel arbitration or
// directly on rsp_order's READY.  Most importantly, bvalid is retired only by
// b_rsp_hs below, i.e. when B is actually selected and accepted downstream.
// The old code cleared bvalid on any rspo2rspt_ready cycle.  If an R response
// won arbitration while a B response was buffered, that silently discarded B
// and left the corresponding request permanently resident in req_order.
assign axi_m_bready = resetn & ~bvalid;

assign b_rsp_hs = bvalid & ~rrsp_phase & rspo2rspt_ready;

//-----------------------------------------------------------------
//  生成rready信号
//-----------------------------------------------------------------
assign axi_m_rready = rspo2rspt_ready;

//==========================================================  协议转换功能  ===========================================================//
//-----------------------------------------------------------------
//  1、生成rspt2rspo_status信号
//  2、生成rspt2rspo_errcode信号
//-----------------------------------------------------------------
always @(*) begin
    if(rrsp_phase == 1'b0) begin
        case (bresp)
            2'b10: begin //SLERR
                rspt2rspo_status = ERR;
                rspt2rspo_errcode = 3'b000;
            end
            2'b11: begin //DECERR
                rspt2rspo_status = ERR;
                rspt2rspo_errcode = 3'b000; 
            end
            default: begin //OKEY
                rspt2rspo_status = OK;
                rspt2rspo_errcode = 3'b000; 
            end
        endcase
    end else begin
        case (rresp)
            2'b10: begin //SLERR
                rspt2rspo_status = ERR;
                rspt2rspo_errcode = 3'b000;
            end
            2'b11: begin //DECERR
                rspt2rspo_status = ERR;
                rspt2rspo_errcode = 3'b000; 
            end
            default: begin //OKEY
                rspt2rspo_status = OK;
                rspt2rspo_errcode = 3'b000; 
            end
        endcase
    end
end

//-----------------------------------------------------------------
//  1、生成rspt2rspo_auser信号
//  2、生成rspt2rspo_axid信号
//  3、生成rspt2rspo_opc信号
//-----------------------------------------------------------------
assign rspt2rspo_auser = (rrsp_phase == 1'b0) ? buser : ruser;
assign rspt2rspo_axid  = (rrsp_phase == 1'b0) ? bid : rid;
assign rspt2rspo_opc   = (rrsp_phase == 1'b0) ? W : R;

//-----------------------------------------------------------------
//  生成rspt2rspo_data信号byte部分，LW与BE位在rsp_order中生成
//-----------------------------------------------------------------
genvar i;
generate 
    for(i=0;i<NBYTEPERWORD;i=i+1) begin
        assign rspt2rspo_data[9*(i+1) : 9*i+2] = (rrsp_phase == 1'b1) ? rdata[8*i+7 : 8*i] : 'd0;
        assign rspt2rspo_data[9*i+1] = (rrsp_phase == 1'b1) ? 1'b1 : 'd0; //BE位全部拉高
        assign rspt2rspo_data[0] = 1'b0;     //LW全拉低
    end
endgenerate


//-----------------------------------------------------------------
//  生成LW提示信号，具体LW位生成在rsp_order中实现
//-----------------------------------------------------------------
// RLAST marks completion of the complete AXI read transaction.
assign rspt2rspo_lw = ((rrsp_phase == 1'b0 && bvalid == 1'b1) ||
                       (rrsp_phase == 1'b1 && rvalid == 1'b1 &&
                        rlast == 1'b1)) ? 1'b1 : 1'b0;

//-----------------------------------------------------------------
//  生成tail信号
//-----------------------------------------------------------------
// A normal, non-interleaved burst closes only on RLAST.  If the next AXI beat
// is already presented back-to-back with a different RID, close the current
// interleaving segment before the new RID is captured into the beat buffer.
// Most importantly, do not assert TAIL on every non-final beat; doing so would
// split an ordinary multi-beat response into one RKNP packet per AXI beat.
assign rspt2rspo_tail =
       (rrsp_phase == 1'b0 && bvalid == 1'b1) ||
       (rrsp_phase == 1'b1 && rvalid == 1'b1 &&
        (rlast == 1'b1 ||
         (axi_m_rvalid == 1'b1 && axi_m_rid != rid)));

//-----------------------------------------------------------------
//  生成head信号
//-----------------------------------------------------------------
always @(*) begin
    if(rrsp_phase == 1'b0)
        rspt2rspo_head = bvalid;
    else
        rspt2rspo_head = rvalid & rhead;
end

//-----------------------------------------------------------------
//  生成valid信号
//-----------------------------------------------------------------
assign rspt2rspo_valid = (rrsp_phase == 1'b0) ? bvalid : rvalid;





endmodule
