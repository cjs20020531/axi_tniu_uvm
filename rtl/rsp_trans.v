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

// Two-entry AXI R look-ahead buffer.
//
// For a non-RLAST beat, the bridge must see the following accepted beat before
// it can decide whether the current RKNP flit is a packet TAIL.  A one-entry
// buffer cannot make that decision when RVALID has a gap before RID changes.
reg  [1:0]                  rbuf_count;
reg  [AXID_WITH-1:0]        rbuf0_rid;
reg  [8*NBYTEPERWORD-1:0]   rbuf0_rdata;
reg  [1:0]                  rbuf0_rresp;
reg  [AUSER_WITH-1:0]       rbuf0_ruser;
reg                         rbuf0_rlast;
reg                         rbuf0_rhead;
reg  [AXID_WITH-1:0]        rbuf1_rid;
reg  [8*NBYTEPERWORD-1:0]   rbuf1_rdata;
reg  [1:0]                  rbuf1_rresp;
reg  [AUSER_WITH-1:0]       rbuf1_ruser;
reg                         rbuf1_rlast;
reg                         rbuf1_rhead;
reg                         prev_rbeat_last;
reg  [AXID_WITH-1:0]        prev_rid;

wire axi_r_hs;
wire r_rsp_valid;
wire r_rsp_tail;
wire r_rsp_hs;

assign axi_r_hs = axi_m_rvalid & axi_m_rready;

// RLAST determines its own packet boundary.  Otherwise the second buffered
// beat is the look-ahead information needed to distinguish continuation from
// an interleaving RID switch.
assign r_rsp_valid = (rbuf_count != 2'd0) &&
                     (rbuf0_rlast || (rbuf_count == 2'd2));
assign r_rsp_tail  = rbuf0_rlast ||
                     ((rbuf_count == 2'd2) &&
                      (rbuf1_rid != rbuf0_rid));
assign r_rsp_hs    = r_rsp_valid & rspo2rspt_ready;

// Do not accept a third beat.  The one-cycle READY bubble after a full-buffer
// pop is intentional and keeps the implementation free of a combinational
// READY path through rsp_order.
assign axi_m_rready = resetn && (rbuf_count < 2'd2);

// Buffer maintenance and packet-HEAD history are updated only by real AXI R
// handshakes.  Therefore a RVALID gap never creates a false transaction HEAD.
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rbuf_count     <= #DLY 2'd0;
        rbuf0_rid      <= #DLY 'd0;
        rbuf0_rdata    <= #DLY 'd0;
        rbuf0_rresp    <= #DLY 2'd0;
        rbuf0_ruser    <= #DLY 'd0;
        rbuf0_rlast    <= #DLY 1'b0;
        rbuf0_rhead    <= #DLY 1'b0;
        rbuf1_rid      <= #DLY 'd0;
        rbuf1_rdata    <= #DLY 'd0;
        rbuf1_rresp    <= #DLY 2'd0;
        rbuf1_ruser    <= #DLY 'd0;
        rbuf1_rlast    <= #DLY 1'b0;
        rbuf1_rhead    <= #DLY 1'b0;
        prev_rbeat_last <= #DLY 1'b0;
        prev_rid        <= #DLY 'd0;
    end else begin
        if(axi_r_hs == 1'b1) begin
            prev_rbeat_last <= #DLY axi_m_rlast;
            prev_rid        <= #DLY axi_m_rid;
        end

        case ({axi_r_hs, r_rsp_hs})
            2'b10: begin
                if(rbuf_count == 2'd0) begin
                    // The buffer cannot become empty in the middle of a read
                    // transaction: a non-RLAST beat is held until its look-ahead
                    // beat is available, and that look-ahead beat is shifted into
                    // rbuf0 when the current beat is popped.  Therefore every beat
                    // accepted into an empty buffer starts a new RKNP packet.
                    rbuf0_rid   <= #DLY axi_m_rid;
                    rbuf0_rdata <= #DLY axi_m_rdata;
                    rbuf0_rresp <= #DLY axi_m_rresp;
                    rbuf0_ruser <= #DLY axi_m_ruser;
                    rbuf0_rlast <= #DLY axi_m_rlast;
                    rbuf0_rhead <= #DLY 1'b1;
                    rbuf_count  <= #DLY 2'd1;
                end else begin
                    rbuf1_rid   <= #DLY axi_m_rid;
                    rbuf1_rdata <= #DLY axi_m_rdata;
                    rbuf1_rresp <= #DLY axi_m_rresp;
                    rbuf1_ruser <= #DLY axi_m_ruser;
                    rbuf1_rlast <= #DLY axi_m_rlast;
                    rbuf1_rhead <= #DLY (prev_rbeat_last ||
                                         (axi_m_rid != prev_rid));
                    rbuf_count  <= #DLY 2'd2;
                end
            end

            2'b01: begin
                if(rbuf_count == 2'd2) begin
                    rbuf0_rid   <= #DLY rbuf1_rid;
                    rbuf0_rdata <= #DLY rbuf1_rdata;
                    rbuf0_rresp <= #DLY rbuf1_rresp;
                    rbuf0_ruser <= #DLY rbuf1_ruser;
                    rbuf0_rlast <= #DLY rbuf1_rlast;
                    rbuf0_rhead <= #DLY rbuf1_rhead;
                    rbuf_count  <= #DLY 2'd1;
                end else begin
                    rbuf_count  <= #DLY 2'd0;
                end
            end

            2'b11: begin
                // Simultaneous pop/push is possible only when the sole buffered
                // beat is RLAST.  The accepted beat therefore always starts the
                // next RKNP packet, even when it reuses the same RID.
                rbuf0_rid   <= #DLY axi_m_rid;
                rbuf0_rdata <= #DLY axi_m_rdata;
                rbuf0_rresp <= #DLY axi_m_rresp;
                rbuf0_ruser <= #DLY axi_m_ruser;
                rbuf0_rlast <= #DLY axi_m_rlast;
                rbuf0_rhead <= #DLY 1'b1;
                rbuf_count  <= #DLY 2'd1;
            end

            default: begin
                rbuf_count <= #DLY rbuf_count;
            end
        endcase
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
// Any buffered R beat keeps read priority, including the look-ahead wait across
// an AXI beat gap.  A B response remains safely buffered until the read packet
// reaches a legal boundary.
wire rrsp_phase;
assign rrsp_phase = (rbuf_count != 2'd0);

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
        case (rbuf0_rresp)
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
assign rspt2rspo_auser = (rrsp_phase == 1'b0) ? buser : rbuf0_ruser;
assign rspt2rspo_axid  = (rrsp_phase == 1'b0) ? bid : rbuf0_rid;
assign rspt2rspo_opc   = (rrsp_phase == 1'b0) ? W : R;

//-----------------------------------------------------------------
//  生成rspt2rspo_data信号byte部分，LW与BE位在rsp_order中生成
//-----------------------------------------------------------------
genvar i;
generate 
    for(i=0;i<NBYTEPERWORD;i=i+1) begin
        assign rspt2rspo_data[9*(i+1) : 9*i+2] = (rrsp_phase == 1'b1) ? rbuf0_rdata[8*i+7 : 8*i] : 'd0;
        assign rspt2rspo_data[9*i+1] = (rrsp_phase == 1'b1) ? 1'b1 : 'd0; //BE位全部拉高
        assign rspt2rspo_data[0] = 1'b0;     //LW全拉低
    end
endgenerate


//-----------------------------------------------------------------
//  生成LW提示信号，具体LW位生成在rsp_order中实现
//-----------------------------------------------------------------
assign rspt2rspo_lw = ((rrsp_phase == 1'b0 && bvalid == 1'b1) ||
                       (rrsp_phase == 1'b1 && r_rsp_valid == 1'b1 &&
                        rbuf0_rlast == 1'b1)) ? 1'b1 : 1'b0;

//-----------------------------------------------------------------
//  生成tail信号
//-----------------------------------------------------------------

assign rspt2rspo_tail =
       (rrsp_phase == 1'b0 && bvalid == 1'b1) ||
       (rrsp_phase == 1'b1 && r_rsp_valid == 1'b1 &&
        r_rsp_tail == 1'b1);

//-----------------------------------------------------------------
//  生成head信号
//-----------------------------------------------------------------
always @(*) begin
    if(rrsp_phase == 1'b0)
        rspt2rspo_head = bvalid;
    else
        rspt2rspo_head = r_rsp_valid & rbuf0_rhead;
end

//-----------------------------------------------------------------
//  生成valid信号
//-----------------------------------------------------------------
assign rspt2rspo_valid = (rrsp_phase == 1'b0) ? bvalid : r_rsp_valid;





endmodule
