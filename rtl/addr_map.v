//=============================================================================
// Copyright(c) 2011, Rockchips Electronics Co, Ltd
// Filename          : req_order.v
// Auther            : cjs
// Email             : 
// Created On        : 2025-08-07
// Abstract          : 1.通过subrange索引偏移量并计算AXI地址
//                     2.将req分为写通路与读通路，提升读写并行性
//                     3.生成AXI4协议所需的len、qos信号
// Parameter         :
// Modified History  :
//=============================================================================
module addr_map#(

     parameter URGE_WITH = 7
    ,parameter SUBR_WITH = 8
    ,parameter ADDR_WITH = 32
    ,parameter AXID_WITH = 4
    ,parameter LEN_WITH = 8 
    ,parameter USER_WITH = 10
    ,parameter NBYTEPERWORD = 8
    
    ,parameter AADDR_WITH = 40
    ,parameter AQOS_WITH = 3

    ,parameter PS_SWITCH = 0      //0:并行输出，1：串行输出
)(
    // The interface signals of rsp_order
     input                              rspo2am_head
    ,input                              rspo2am_tail
    ,input                              rspo2am_valid
    ,output reg                         am2rspo_ready
    ,input       [URGE_WITH-1:0]        rspo2am_urg
    ,input       [SUBR_WITH-1:0]        rspo2am_subr
    ,input       [ADDR_WITH-1:0]        rspo2am_addr
    ,input       [AXID_WITH-1:0]        rspo2am_axid
    ,input       [3:0]                  rspo2am_opc
    ,input       [LEN_WITH-1:0]         rspo2am_len
    ,input       [USER_WITH-1:0]        rspo2am_user
    ,input       [9*NBYTEPERWORD:0]     rspo2am_data
    

    // The interface signals of rreq_trans
    ,output                             am2rreqt_head
    ,output                             am2rreqt_tail
    ,output                             am2rreqt_valid
    ,input                              rreqt2am_ready
    ,output      [AADDR_WITH-1:0]       am2rreqt_araddr
    ,output      [AXID_WITH-1:0]        am2rreqt_axid
    ,output      [1:0]                  am2rreqt_opc
    ,output      [7:0]                  am2rreqt_arlen
    ,output      [USER_WITH-1:0]        am2rreqt_user
    ,output      [AQOS_WITH-1:0]        am2rreqt_arqos

    // The interface signals of wreq_trans
    ,output                             am2wreqt_head
    ,output                             am2wreqt_tail
    ,output                             am2wreqt_valid
    ,input                              wreqt2am_ready
    ,output      [AADDR_WITH-1:0]       am2wreqt_awaddr
    ,output      [AXID_WITH-1:0]        am2wreqt_axid
    ,output      [1:0]                  am2wreqt_opc
    ,output      [7:0]                  am2wreqt_awlen
    ,output      [USER_WITH-1:0]        am2wreqt_user
    ,output      [AQOS_WITH-1:0]        am2wreqt_awqos
    ,output      [9*NBYTEPERWORD:0]     am2wreqt_data
);

parameter R = 2'b00;
parameter W = 2'b01;



//-----------------------------------------------------------------
//  地址译码表
//-----------------------------------------------------------------
reg [AADDR_WITH-1:0] addr_map_table [7:0];

initial begin
    addr_map_table[0] = 40'h08_0000_0000;
    addr_map_table[1] = 40'h10_0000_0000;
    addr_map_table[2] = 40'h18_0000_0000;
    addr_map_table[3] = 40'h20_0000_0000;
    addr_map_table[4] = 40'h28_0000_0000;
    addr_map_table[5] = 40'h30_0000_0000;
    addr_map_table[6] = 40'h38_0000_0000;
    addr_map_table[7] = 40'h40_0000_0000;
end


//-----------------------------------------------------------------
// 计算 AXI AxLEN
//
// RKNP:
//   rspo2am_len = 有效字节数 - 1
//
// AXI:
//   AxLEN = AXI beat 数 - 1
//
// 对于非对齐传输：
//   AxLEN = floor((起始 byte lane + RKNP len) / 每拍字节数)
//-----------------------------------------------------------------

localparam BYTE_OFFSET_WIDTH = $clog2(NBYTEPERWORD);

// 起始地址在一个 AXI data beat 内的 byte lane。
wire [BYTE_OFFSET_WIDTH-1:0] addr_offset;

wire [LEN_WITH:0] beat_count;

wire [7:0] total_flit;

assign addr_offset = rspo2am_addr[BYTE_OFFSET_WIDTH-1:0] & (NBYTEPERWORD-1'd1); 

assign beat_count = (addr_offset + rspo2am_len) >> $clog2(NBYTEPERWORD);

// total_flit 本身就是 AXI AxLEN，即 beat_count - 1。
assign total_flit = beat_count;


//-----------------------------------------------------------------
//   QoS转换
//-----------------------------------------------------------------
reg [AQOS_WITH-1:0] qos;
generate
    if(AQOS_WITH == 2) begin
        always @(*) begin
            case (rspo2am_urg)
                3'b000: qos = 2'b00;
                3'b001: qos = 2'b01;
                3'b011: qos = 2'b10;
                3'b111: qos = 2'b11;
            endcase
        end
    end else begin
        always @(*) begin
            case (rspo2am_urg)
                7'b0000000: qos = 3'b000;
                7'b0000001: qos = 3'b001;
                7'b0000011: qos = 3'b010;
                7'b0000111: qos = 3'b011;
                7'b0001111: qos = 3'b100;
                7'b0011111: qos = 3'b101;
                7'b0111111: qos = 3'b110;
                7'b1111111: qos = 3'b111;
            endcase
        end
    end
endgenerate

//-----------------------------------------------------------------
//  R通道信号透传
//-----------------------------------------------------------------

assign am2rreqt_head  = (rspo2am_opc[3:2] == R) ? rspo2am_head : 1'b0;
assign am2rreqt_tail  = (rspo2am_opc[3:2] == R) ? rspo2am_tail : 1'b0;
assign am2rreqt_valid = (rspo2am_opc[3:2] == R) ? rspo2am_valid : 1'b0;

assign am2rreqt_opc    = rspo2am_opc[1:0];
assign am2rreqt_urg    = rspo2am_urg;
assign am2rreqt_axid   = rspo2am_axid;
assign am2rreqt_arlen  = total_flit;
assign am2rreqt_user   = rspo2am_user;
assign am2rreqt_araddr = {addr_map_table[rspo2am_subr][AADDR_WITH-1:ADDR_WITH],rspo2am_addr};
assign am2rreqt_arqos  = qos;



//-----------------------------------------------------------------
//  W通道信号透传
//-----------------------------------------------------------------

assign am2wreqt_head  = (rspo2am_opc[3:2] == W) ? rspo2am_head : 1'b0;
assign am2wreqt_tail  = (rspo2am_opc[3:2] == W) ? rspo2am_tail : 1'b0;
assign am2wreqt_valid = (rspo2am_opc[3:2] == W) ? rspo2am_valid : 1'b0;

assign am2wreqt_opc  = rspo2am_opc[1:0];
assign am2wreqt_urg  = rspo2am_urg;
assign am2wreqt_axid = rspo2am_axid;
assign am2wreqt_awlen  = total_flit;
assign am2wreqt_user = rspo2am_user;
assign am2wreqt_awaddr = {addr_map_table[rspo2am_subr][AADDR_WITH-1:ADDR_WITH],rspo2am_addr};
assign am2wreqt_data = rspo2am_data;
assign am2wreqt_awqos = qos;



//-----------------------------------------------------------------
//  生成am2rspo_ready信号
//-----------------------------------------------------------------
generate
    if(PS_SWITCH == 1'b0) begin
        always@(*) begin
            if(rspo2am_opc[3:2] == R) am2rspo_ready = rreqt2am_ready;
            else am2rspo_ready = wreqt2am_ready;
        end
    end else begin
        always@(*) begin
            if((rspo2am_opc[2] == W && am2rreqt_valid == 1'b1) || (rspo2am_opc[2] == R && am2wreqt_tail == 1'b1)) am2rspo_ready = 1'b0;
            else if(rspo2am_opc[2] == W && am2rreqt_valid == 1'b0) am2rspo_ready = wreqt2am_ready;
            else if(rspo2am_opc[2] == R && am2wreqt_tail == 1'b0) am2rspo_ready = rreqt2am_ready;
            else am2rspo_ready = 1'b1;
        end
    end
endgenerate



endmodule
