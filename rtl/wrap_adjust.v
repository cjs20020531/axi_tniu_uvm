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
// 解析当前输入flit
//------------------------------------------------------
wire [1:0] rspo2wad_opc;
wire       rspo2wad_lw;
wire [1:0] rspo2wad_status;

assign rspo2wad_opc = rspo2wad_data[RSP_OPC_OFFSET +: 2];
assign rspo2wad_lw = rspo2wad_data[RSP_HEAD_LEN_OFFSET];
assign rspo2wad_status = rspo2wad_data[RSP_STATUS_OFFSET +: 2];

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
// 补拍状态及其上下文
//
// append_pending=1表示原始AXI RLAST flit已经输出，但非对齐WRAP
// 缓存在首拍低地址lane中的数据还需要额外输出一个flit。
//------------------------------------------------------
reg                         append_pending;
reg [7:0]                   pending_offset;
reg [AXID_WITH-1:0]         pending_axid;
reg [RSP_HEAD_LEN_OFFSET-1:0] pending_rsp_head;

wire append_hs;
wire first_wrap_flit;
wire first_wrap_hs;
wire cur_wrap_final;
wire cur_wrap_final_hs;

// status=CONT的head来自读交织恢复，不能再次缓存首拍。
assign first_wrap_flit =
       rspo2wad_valid
    && rspo2wad_head
    && (rspo2wad_opc == R)
    && (rspo2wad_offset_addr != 8'd0)
    && (rspo2wad_status != CONT);

assign first_wrap_hs = first_wrap_flit && wad2rspo_ready;

// tail=1、LW=0仅表示交织packet结束；只有tail和LW同时为1
// 才是需要执行WRAP补拍的事务最终flit。
assign cur_wrap_final =
       rspo2wad_valid
    && rspo2wad_tail
    && rspo2wad_lw
    && (rspo2wad_opc == R)
    && (rspo2wad_offset_addr != 8'd0);

assign cur_wrap_final_hs = cur_wrap_final && wad2rspo_ready;
assign append_hs = append_pending && rknp_xx2wad_ready;

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        append_pending  <= #DLY 1'b0;
        pending_offset  <= #DLY 8'd0;
        pending_axid    <= #DLY 'd0;
        pending_rsp_head <= #DLY 'd0;
    end else if(append_pending == 1'b1) begin
        if(rknp_xx2wad_ready == 1'b1)
            append_pending <= #DLY 1'b0;
    end else if(cur_wrap_final_hs == 1'b1) begin
        append_pending   <= #DLY 1'b1;
        pending_offset   <= #DLY rspo2wad_offset_addr;
        pending_axid     <= #DLY rspo2wad_axid;
        pending_rsp_head <= #DLY rspo2wad_data[RSP_HEAD_LEN_OFFSET-1:0];
    end
end

//------------------------------------------------------
//  生成rwrap_buff_index值
//------------------------------------------------------
wire [RWRAP_CNT_MAX-1:0] rwrap_buff_index_hot;
wire [INDEX_WITH-1:0] rwrap_buff_index;
//索引spec_req_buffer对应单元
generate
	for(i = 0; i < RWRAP_CNT_MAX; i = i+1)begin
		assign rwrap_buff_index_hot[i] = ({pending_axid, 1'b1} == rwrap_buffer[i][0 +: AXID_WITH+1]) ? 1'b1 : 1'b0;
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
//  1、写入rwrap_buffer操作
//  2、删除rwrap_buffer操作
//------------------------------------------------------
integer a;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        for(a = 0; a < RWRAP_CNT_MAX; a = a + 1) begin
            rwrap_buffer[a] <= #DLY 'd0;
        end
    end else begin
        if(first_wrap_hs == 1'b1) begin
            rwrap_buffer[idle_rwrap_buff_index] <= #DLY {
                rspo2wad_data[RSP_HEAD_LEN_OFFSET+1 +: NBYTEPERWORD*9],
                rspo2wad_axid,
                1'b1
            };
        end
        // 只有补拍flit真正被下游接收后才能释放缓存。
        if(append_hs == 1'b1 && rwrap_buff_index_hot != 'd0) begin
            rwrap_buffer[rwrap_buff_index][0] <= #DLY 1'b0;
        end
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
assign lw_offset_body = (NBYTEPERWORD*9 - ((pending_offset << 3) + pending_offset)); //反向偏移长度

//------------------------------------------------------
//  生成body部分（不含LW位）
//------------------------------------------------------

always @(*) begin
    if(append_pending == 1'b1) begin //读WRAP非对齐响应调整后的补拍
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET+1 +: 9*NBYTEPERWORD] = (rwrap_buffer[rwrap_buff_index][BUFF_BODY_OFFSET +: NBYTEPERWORD*9] << lw_offset_body) >> lw_offset_body; //body部分（不含LW位）
    end else if(first_wrap_flit == 1'b1) begin      //读WRAP非对齐响应调整后的第一拍,排除交织
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

always @(*) begin
    if(append_pending == 1'b1) begin
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET-1 : 0] = pending_rsp_head;
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET] = 1'b1;
    end else if(first_wrap_flit == 1'b1) begin      //若为交织则无需修正地址
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET-1 : 0] = {rspo2wad_data[RSP_USER_OFFSET +: USER_WITH+4] , adjust_addr , rspo2wad_data[RSP_ADDR_OFFSET-1 : 0]}; //head部分（含LW位）
        wad2rknp_xx_data[RSP_HEAD_LEN_OFFSET] = 1'b0;
    end else if(cur_wrap_final == 1'b1)begin
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
// 补拍属于前一个packet，不能再次带head。
assign wad2rknp_xx_head = append_pending ? 1'b0 : rspo2wad_head;

//------------------------------------------------------
//  生成tail信号
//------------------------------------------------------
// 优先级必须是：补拍 > 当前WRAP最终flit > 普通透传。
// 补拍期间上游被反压，原始final flit会保持在输入端，因此如果先判断
// 当前输入final，补拍的tail将永远无法拉高。
always @(*) begin
    if(append_pending == 1'b1) begin
        wad2rknp_xx_tail = 1'b1;
    end else if(cur_wrap_final == 1'b1) begin
        wad2rknp_xx_tail = 1'b0;
    end else begin
        wad2rknp_xx_tail = rspo2wad_tail;
    end
end

//------------------------------------------------------
//  生成valid信号
//------------------------------------------------------
// tail是valid的伴随信号，不能用tail反向生成valid。
assign wad2rknp_xx_valid = append_pending ? 1'b1 : rspo2wad_valid;


//------------------------------------------------------
//  生成ready信号
//------------------------------------------------------
assign wad2rspo_ready = append_pending ? 1'b0 : rknp_xx2wad_ready;

//------------------------------------------------------
//  生成rwrap_rsp_fin信号
//------------------------------------------------------
assign rwrap_rsp_fin = append_hs;
endmodule
