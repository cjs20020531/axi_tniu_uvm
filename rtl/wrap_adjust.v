//=============================================================================
// Copyright(c) 2011, Rockchips Electronics Co, Ltd
// Filename          : wrap_align.v
// Auther            : cjs
// Email             : 
// Created On        : 2025-07-27
// Abstract          : 当本TNIU数据位宽大于NoC中任意一个AXI/AHB INIU数据位宽时，
//                     可能出现INIU WRAP请求地址与TNIU的WRAP地址不对齐的情况，
//                     需要对WRAP请求地址进行额外的对齐操作。
// Parameter         :
// Modified History  :
//=============================================================================

module wrap_adjust#(

     parameter RSP_IID_OFFSET = 7
    ,parameter RSP_TID_OFFSET = 17
    ,parameter RSP_ORDKEY_OFFSET = 27
    ,parameter RSP_OPC_OFFSET = 35
    ,parameter RSP_STATUS_OFFSET =37
    ,parameter RSP_ADDR_OFFSET = 39
    ,parameter RSP_USER_OFFSET = 71
    ,parameter RSP_ERRC_OFFSET = 81
    ,parameter RSP_HEAD_LEN_OFFSET = 84
    ,parameter RSP_FLIT_WITH = 157
    ,parameter NBYTEPERWORD = 8

    ,parameter USER_WITH = 10
    ,parameter ADDR_WITH = 32
    ,parameter AXID_WITH = 4
    ,parameter RWRAP_CNT_MAX = 4
    ,parameter DLY = 1
    
)(
     input                               clk
    ,input                               resetn
    // The interface signals of rsp channel of rsp_order
    ,input                               rspo2wad_head
    ,input                               rspo2wad_tail
    ,input                               rspo2wad_valid
    ,output                              wad2rspo_ready
    ,input        [RSP_FLIT_WITH-1:0]    rspo2wad_data
    ,input        [7:0]                  rspo2wad_offset_addr
    ,input        [AXID_WITH-1:0]        rspo2wad_axid

    // The interface signals of rsp channel of rknp_xx
    ,output wire                         wad2rknp_xx_head
    ,output reg                          wad2rknp_xx_tail
    ,output wire                         wad2rknp_xx_valid
    ,input                               rknp_xx2wad_ready
    ,output reg   [RSP_FLIT_WITH-1:0]    wad2rknp_xx_data

    // The interface signals of wrap_align 
    ,output                              rwrap_rsp_fin
);
parameter R = 2'b00;
parameter W = 2'b01;

parameter OK   = 2'b00;
parameter ERR  = 2'b01;
parameter CONT = 2'b10;
//------------------------------------------------------
// 声明rwrap_buffer数组
//------------------------------------------------------
reg [9*NBYTEPERWORD+AXID_WITH:0] rwrap_buffer [RWRAP_CNT_MAX-1:0]; 
localparam BUFF_AXID_OFFSET = 1;
localparam BUFF_BODY_OFFSET = BUFF_AXID_OFFSET + AXID_WITH;


//------------------------------------------------------
// 寄存offset_addr、Opc与AXID，在tail时使用
//------------------------------------------------------
wire [1:0] rspo2wad_opc;
wire       rspo2wad_lw;
wire [1:0] rspo2wad_status;
reg  [7:0] rspo2wad_offset_addr_d; //rspo2wad_offset_addr寄存
reg  [1:0] rspo2wad_opc_d;
reg        rspo2wad_lw_d;
reg  [AXID_WITH-1:0] rspo2wad_axid_d;

assign rspo2wad_opc = rspo2wad_data[RSP_OPC_OFFSET +: 2];
assign rspo2wad_lw = rspo2wad_data[RSP_HEAD_LEN_OFFSET]; 
assign rspo2wad_status = rspo2wad_data[RSP_STATUS_OFFSET +: 2];

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rspo2wad_offset_addr_d <= #DLY 8'd0;
        rspo2wad_opc_d <= #DLY R;
        rspo2wad_axid_d <= #DLY 'd0;
        
    end else if(rspo2wad_head == 1'b1 && wad2rspo_ready == 1'b1) begin
        rspo2wad_offset_addr_d <= #DLY rspo2wad_offset_addr;
        rspo2wad_opc_d <= #DLY rspo2wad_opc;
        rspo2wad_axid_d <= #DLY rspo2wad_axid;
    end
end

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rspo2wad_lw_d <= #DLY 1'b0;
    end else if(rspo2wad_lw == 1'b1 && wad2rspo_ready == 1'b1) begin
        rspo2wad_lw_d <= #DLY 1'b1;
    end else if(rknp_xx2wad_ready == 1'b1) begin
        rspo2wad_lw_d <= #DLY 1'b0;
    end
end






//------------------------------------------------------
//  生成idle_rwrap_buff_index值
//------------------------------------------------------
genvar i,j;
localparam INDEX_WITH = $clog2(RWRAP_CNT_MAX);
wire [RWRAP_CNT_MAX-1:0] idle_rwrap_buff_used; //生成idle_buff_index_hot的中间变量
wire [RWRAP_CNT_MAX-1:0] idle_rwrap_buff_index_hot;
wire [INDEX_WITH-1:0] idle_rwrap_buff_index;
//索引spec_req_buffer为idle的单元
generate 
    for (i = 0 ; i < RWRAP_CNT_MAX ; i = i + 1) begin 
        assign idle_rwrap_buff_used[i] = ~rwrap_buffer[i][0];
    end
endgenerate
//保留二进制最低位1操作-生成独热码
assign idle_rwrap_buff_index_hot = idle_rwrap_buff_used & (~idle_rwrap_buff_used+1);
//独热码转二进制码
wire [INDEX_WITH-1 : 0] idle_rwrap_buff_index_hot2bin_temp1 [RWRAP_CNT_MAX-1 : 0]; 
wire [RWRAP_CNT_MAX-1 : 0] idle_rwrap_buff_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
generate
	for(i = 0; i < RWRAP_CNT_MAX; i = i+1)begin 
		assign idle_rwrap_buff_index_hot2bin_temp1[i] = idle_rwrap_buff_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < RWRAP_CNT_MAX; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign idle_rwrap_buff_index_hot2bin_temp2[j][i] = idle_rwrap_buff_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign idle_rwrap_buff_index[j] = |idle_rwrap_buff_index_hot2bin_temp2[j];
	end
endgenerate

//------------------------------------------------------
//  生成rwrap_buff_index值
//------------------------------------------------------
wire [RWRAP_CNT_MAX-1:0] rwrap_buff_index_hot;
wire [INDEX_WITH-1:0] rwrap_buff_index;
//索引spec_req_buffer对应单元
generate
	for(i = 0; i < RWRAP_CNT_MAX; i = i+1)begin 
		assign rwrap_buff_index_hot[i] = ({rspo2wad_axid, 1'b1} == rwrap_buffer[i][0 +: AXID_WITH+1]) ? 1'b1 : 1'b0;
	end
endgenerate

//独热码转二进制码
wire [INDEX_WITH-1 : 0] rwrap_buff_index_hot2bin_temp1 [RWRAP_CNT_MAX-1 : 0]; 
wire [RWRAP_CNT_MAX-1 : 0] rwrap_buff_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
generate
	for(i = 0; i < RWRAP_CNT_MAX; i = i+1)begin 
		assign rwrap_buff_index_hot2bin_temp1[i] = rwrap_buff_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < RWRAP_CNT_MAX; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign rwrap_buff_index_hot2bin_temp2[j][i] = rwrap_buff_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign rwrap_buff_index[j] = |rwrap_buff_index_hot2bin_temp2[j];
	end
endgenerate



//------------------------------------------------------
//  对tail信号打拍
//------------------------------------------------------
reg rspo2wad_tail_d;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0)
        rspo2wad_tail_d <= #DLY 1'b0;
    else if(rspo2wad_tail == 1'b1 && wad2rspo_ready == 1'b1)
        rspo2wad_tail_d <= #DLY 1'b1;
    else if(rknp_xx2wad_ready == 1'b1)
        rspo2wad_tail_d <= #DLY 1'b0;
end



//------------------------------------------------------
//  1、写入rwrap_buffer操作
//  2、删除rwrap_buffer操作
//------------------------------------------------------
integer a;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        for(a = 0; a < RWRAP_CNT_MAX; a = a + 1) begin
            rwrap_buffer[a] <= #DLY 'd0;
        end
    end else if(rspo2wad_head == 1'b1 && wad2rspo_ready == 1'b1 && rspo2wad_opc == R && rspo2wad_offset_addr != 8'd0 && rspo2wad_status != CONT) begin
        rwrap_buffer[idle_rwrap_buff_index] <= #DLY {rspo2wad_data[RSP_HEAD_LEN_OFFSET+1 +: NBYTEPERWORD*9], rspo2wad_axid, 1'b1}; 
    end else if(rspo2wad_lw_d == 1'b1 && rknp_xx2wad_ready == 1'b1 && rspo2wad_opc == R && rspo2wad_offset_addr_d != 8'd0) begin
        rwrap_buffer[rwrap_buff_index][0] <= #DLY 1'b0;    //删除该单元
    end
end

//------------------------------------------------------
//  生成第一笔body偏移量
//------------------------------------------------------
wire [9:0] fir_offset_body;  //body偏移长度
assign fir_offset_body = (rspo2wad_offset_addr << 3) + rspo2wad_offset_addr; //偏移长度=offset_addr×9

//------------------------------------------------------
//  生成最后一笔body偏移量
//------------------------------------------------------
wire [9:0] lw_offset_body;  //body偏移长度
assign lw_offset_body = (NBYTEPERWORD*9 - ((rspo2wad_offset_addr_d << 3) + rspo2wad_offset_addr_d)); //反向偏移长度

//------------------------------------------------------
//  生成body部分（不含LW位）
//------------------------------------------------------

always @(*) begin
    if(rspo2wad_lw_d == 1'b1 && rspo2wad_opc_d == R && rspo2wad_offset_addr_d != 8'd0) begin //读WRAP非对齐响应调整后的最后一拍
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET+1 +: 9*NBYTEPERWORD] = (rwrap_buffer[rwrap_buff_index][BUFF_BODY_OFFSET +: NBYTEPERWORD*9] << lw_offset_body) >> lw_offset_body; //body部分（不含LW位）
    end else if(rspo2wad_head == 1'b1 && rspo2wad_opc == R && rspo2wad_offset_addr != 8'd0 && rspo2wad_status != CONT) begin      //读WRAP非对齐响应调整后的第一拍,排除交织
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET+1 +: 9*NBYTEPERWORD] = (rspo2wad_data[RSP_HEAD_LEN_OFFSET+1 +: NBYTEPERWORD*9] >> fir_offset_body) << fir_offset_body; //body部分（不含LW位）
    end else begin
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET+1 +: 9*NBYTEPERWORD] = rspo2wad_data[RSP_HEAD_LEN_OFFSET+1 +: NBYTEPERWORD*9]; //body部分（不含LW位）
    end
end

//------------------------------------------------------
//  生成head部分（包含LW位）
//------------------------------------------------------
reg [ADDR_WITH-1:0] adjust_addr; //调整地址
always @(*) begin
    if(rspo2wad_opc == R)
        adjust_addr = rspo2wad_data[RSP_ADDR_OFFSET +: ADDR_WITH] + rspo2wad_offset_addr;
    else
        adjust_addr = rspo2wad_data[RSP_ADDR_OFFSET +: ADDR_WITH] - rspo2wad_offset_addr;
end

//head字段打拍
reg [RSP_HEAD_LEN_OFFSET-1 : 0] rrsp_head_d; //head部分（不含LW位）
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rrsp_head_d <= #DLY 'd0;
    end else begin
        rrsp_head_d <= #DLY rspo2wad_data[RSP_HEAD_LEN_OFFSET-1 : 0];
    end
end

always @(*) begin
    if(rspo2wad_head == 1'b1 && wad2rspo_ready == 1'b1 && rspo2wad_offset_addr != 8'd0 && rspo2wad_status != CONT) begin      //若为交织则无需修正地址
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET-1 : 0] = {rspo2wad_data[RSP_USER_OFFSET +: USER_WITH+4] , adjust_addr , rspo2wad_data[RSP_ADDR_OFFSET-1 : 0]}; //head部分（含LW位）
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET] = 1'b0;
    end else if(rspo2wad_lw_d == 1'b1 && rspo2wad_opc_d == R && rspo2wad_offset_addr_d != 8'd0) begin//读WRAP非对齐响应调整后的最后一拍
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET-1 : 0] = rrsp_head_d;
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET] = 1'b1;
    end else if(rspo2wad_lw == 1'b1 && rspo2wad_opc == R && rspo2wad_offset_addr != 8'd0)begin
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET-1 : 0] = rspo2wad_data[RSP_HEAD_LEN_OFFSET-1 : 0]; //head部分（不含LW位）
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET] = 1'b0;
    end else begin
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET-1 : 0] = rspo2wad_data[RSP_HEAD_LEN_OFFSET-1 : 0]; //head部分（不含LW位）
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET] = rspo2wad_lw;
    end
end

//------------------------------------------------------
//  生成head信号
//------------------------------------------------------
assign wad2rknp_xx_head = rspo2wad_head;

//------------------------------------------------------
//  生成tail信号
//------------------------------------------------------
//如果是读WRAP非对齐响应，则使用打拍的tail信号，否则使用原始的tail信号
                          
always @(*) begin
    if(rspo2wad_opc == R && rspo2wad_offset_addr != 8'd0 && rspo2wad_tail == 1'b1) begin
        wad2rknp_xx_tail = 1'b0;
    end else if(rspo2wad_opc_d == R && rspo2wad_offset_addr_d != 8'd0 && rspo2wad_lw_d == 1'b1) begin
        wad2rknp_xx_tail = 1'b1;
    end else begin
        wad2rknp_xx_tail = rspo2wad_tail;
    end
end

//------------------------------------------------------
//  生成valid信号
//------------------------------------------------------
assign wad2rknp_xx_valid = (wad2rknp_xx_tail == 1'b1) ? 1'b1 : rspo2wad_valid; 


//------------------------------------------------------
//  生成ready信号
//------------------------------------------------------
assign wad2rspo_ready = (rspo2wad_opc_d == R && rspo2wad_offset_addr_d != 8'd0 && rspo2wad_lw_d == 1'b1) ? 1'b0 : rknp_xx2wad_ready; //如果是读WRAP非对齐响应的最后一拍，需要反压

//------------------------------------------------------
//  生成rwrap_rsp_fin信号
//------------------------------------------------------
assign rwrap_rsp_fin = (rspo2wad_opc_d == R && rspo2wad_offset_addr_d != 8'd0 && rspo2wad_lw_d == 1'b1 && rknp_xx2wad_ready == 1'b1) ? 1'b1 : 1'b0;
endmodule