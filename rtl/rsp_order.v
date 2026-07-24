//=============================================================================
// Copyright(c) 2011, Rockchips Electronics Co, Ltd
// Filename          : rsp_order.v
// Auther            : cjs
// Email             : 
// Created On        : 2025-08-04
// Abstract          : 该模块需要判断对特殊保序、超时响应与常规响应进行保序，其中特殊响应包括（对请求阶段的错误组织响应、组织early response）
// Parameter         :
// Modified History  :
//=============================================================================
module rsp_order#(

     parameter URGE_WITH = 7
    ,parameter SUBR_WITH = 8
    ,parameter IID_WITH = 10
    ,parameter TID_WITH = 10
    ,parameter ADDR_WITH = 32
    ,parameter AXID_WITH = 4
    ,parameter ORDKEY_WITH = 8
    ,parameter LEN_WITH = 8 
    ,parameter USER_WITH = 10

    ,parameter RSP_IID_OFFSET = 7
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
    ,parameter TAG_CNT_WITH = 3

    ,parameter SPEC_REQ_BUFF_DEEP = 8

    ,parameter ADDR_BLOCK_SIZE = 64
    ,parameter ADDR_BP_TYPE = 1  // 0:无同地址反压  1:写后读/写后写同地址反压   2:写后读/写后写/读后写同地址反压
    ,parameter AUSER_WITH = 1

    ,parameter EARLY_RSP_MODE = 0 // 0：关闭early response模式    1：开启early response模式
    ,parameter DLY = 1
)(
     input                              clk
    ,input                              resetn

    // The interface signals of req channel of req_order 
    ,input                              reqo2rspo_head
    ,input                              reqo2rspo_tail
    ,input                              reqo2rspo_valid
    ,output                             rspo2reqo_ready
    ,input       [URGE_WITH-1:0]        reqo2rspo_urg   
    ,input       [SUBR_WITH-1:0]        reqo2rspo_subr 
    ,input       [ADDR_WITH-1:0]        reqo2rspo_addr
    ,input       [AXID_WITH-1:0]        reqo2rspo_axid
    ,input       [3:0]                  reqo2rspo_opc
    ,input       [2:0]                  reqo2rspo_errcode
    ,input       [1:0]                  reqo2rspo_status
    ,input       [LEN_WITH-1:0]         reqo2rspo_len   
    ,input       [USER_WITH-1:0]        reqo2rspo_user
    ,input       [NBYTEPERWORD*9:0]     reqo2rspo_data
    ,input       [TAG_CNT_WITH-1:0]     reqo2rspo_tag_cnt
    ,input                              fir_req_flag

    ,input wire [SPEC_REQ_BUFF_DEEP*(AXID_WITH+3)-1:0] reqo2rspo_tag_name

    // The interface signals of addr_map
    ,output reg                         rspo2am_head
    ,output reg                         rspo2am_tail
    ,output reg                         rspo2am_valid
    ,input                              am2rspo_ready
    ,output wire [URGE_WITH-1:0]        rspo2am_urg
    ,output wire [SUBR_WITH-1:0]        rspo2am_subr
    ,output wire [ADDR_WITH-1:0]        rspo2am_addr
    ,output wire [AXID_WITH-1:0]        rspo2am_axid
    ,output wire [3:0]                  rspo2am_opc
    ,output wire [LEN_WITH-1:0]         rspo2am_len
    ,output wire [USER_WITH-1:0]        rspo2am_user
    ,output wire [9*NBYTEPERWORD:0]     rspo2am_data
    

    // The interface signals of rsp_trans
    ,input                              rspt2rspo_head
    ,input                              rspt2rspo_tail
    ,input                              rspt2rspo_valid
    ,output reg                         rspo2rspt_ready
    ,input       [AXID_WITH-1:0]        rspt2rspo_axid
    ,input       [AUSER_WITH-1:0]       rspt2rspo_auser
    ,input       [1:0]                  rspt2rspo_opc
    ,input       [2:0]                  rspt2rspo_errcode
    ,input       [1:0]                  rspt2rspo_status
    ,input       [9*NBYTEPERWORD:0]     rspt2rspo_data
    ,input                              rspt2rspo_lw
    

    // The interface signals of rsp channel of req_order 
    ,input       [URGE_WITH-1:0]        reqo2rspo_rsp_urg   
    ,input       [ADDR_WITH-1:0]        reqo2rspo_rsp_addr
    ,input       [ORDKEY_WITH-1:0]      reqo2rspo_rsp_ordkey
    ,input       [LEN_WITH-1:0]         reqo2rspo_rsp_len   
    ,input       [USER_WITH-1:0]        reqo2rspo_rsp_user
    ,input       [IID_WITH-1:0]         reqo2rspo_rsp_iid
    ,input       [TID_WITH-1:0]         reqo2rspo_rsp_tid
    ,input       [1:0]                  reqo2rspo_rsp_status
    ,input       [7:0]                  reqo2rspo_rsp_offset_addr
    ,output reg  [AXID_WITH+TAG_CNT_WITH+1: 0] rspo2reqo_head_index
    ,output reg                         rspo2reqo_rhead_en
    ,output reg                         rspo2reqo_rsp_valid
    ,output reg                         del_head_en
    ,output reg                         rspo2reqo_timout
    ,input                              reqo2rspo_timout

    


    // The interface signals of rsp channel of rknp_xx/wrap_adjust
    ,output reg                          rspo2rknp_xx_head
    ,output reg                          rspo2rknp_xx_tail
    ,output reg                          rspo2rknp_xx_valid
    ,input                               rknp_xx2rspo_ready
    ,output reg   [RSP_FLIT_WITH-1:0]    rspo2rknp_xx_data

    // The interface signals of wrap_adjust
    ,output wire  [7:0]                  rspo2wad_offset_addr
    ,output wire  [AXID_WITH-1:0]        rspo2wad_axid

    // The interface signals of watchdog
    ,input         [AXID_WITH-1:0]        wd2rspo_axid
    ,input         [1:0]                  wd2rspo_opc
    ,input                                timout_fifo_empty
    ,output reg                           timout_fifo_rden
    ,output reg    [AXID_WITH-1:0]        rspo2wd_axid
    ,output reg    [1:0]                  rspo2wd_opc
    ,output reg    [TAG_CNT_WITH-1:0]     rspo2wd_tag_cnt
    ,output reg                           rspo2wd_timoff_en

    // The interface signals of ely_rsp_detect
    ,output                               rspo2erd_head
    ,output        [AXID_WITH-1:0]        rspo2erd_axid
    ,output        [3:0]                  rspo2erd_opc
    ,output        [USER_WITH-1:0]        rspo2erd_user
    ,input                                erd2rspo_tag_cnt
    ,input                                buff_rsp_flag
    ,output        [TAG_CNT_WITH-1:0]     rspo2erd_tag_cnt


);
parameter NORM_RSP = 0;
parameter SPEC_RSP = 1;

parameter RD = 2'b00;
parameter WR = 2'b01;

parameter OK   = 2'b00;
parameter ERR  = 2'b01;
parameter CONT = 2'b10;

parameter TIM_OUT = 3'b110;



//------------------------------------------------------
// 声明spec_req_buffer
//------------------------------------------------------
//2:opc[3:2] , 3:errorcode , 2:status , 1:fir_flag , 1:used
localparam SPEC_REQ_BUFF_WITH = AXID_WITH + 2 + TAG_CNT_WITH + 3 + 2 + 1 + 1;
reg [SPEC_REQ_BUFF_WITH-1:0] spec_req_buffer [SPEC_REQ_BUFF_DEEP-1:0];

localparam BUFF_FIR_FLAG_OFFSET = 1;
localparam BUFF_STAT_OFFSET = BUFF_FIR_FLAG_OFFSET + 1;
localparam BUFF_ERRC_OFFSET = BUFF_STAT_OFFSET + 2;
localparam BUFF_TAGCNT_OFFSET = BUFF_ERRC_OFFSET + 3;
localparam BUFF_OPC_OFFSET = BUFF_ERRC_OFFSET + TAG_CNT_WITH;
localparam BUFF_AXID_OFFSET = BUFF_OPC_OFFSET + 2;


reg cur_state;
reg next_state;

wire follo_err_en; //buffer中存在下一笔请求为err的有效标志位
wire fir_err_en;   //buffer中存在第一笔该类型请求为err的有效标志位
reg [SPEC_REQ_BUFF_DEEP-1:0] buff_index;  //选择特殊请求缓冲的索引值

//------------------------------------------------------
//  生成idle_buff_index值
//------------------------------------------------------
genvar i,j;
localparam INDEX_WITH = $clog2(SPEC_REQ_BUFF_DEEP);
wire [SPEC_REQ_BUFF_DEEP-1:0] buff_used; //生成idle_buff_index_hot的中间变量
wire [SPEC_REQ_BUFF_DEEP-1:0] idle_buff_index_hot;
wire [INDEX_WITH-1:0] idle_buff_index;
//索引spec_req_buffer为idle的单元
generate 
    for (i = 0 ; i < SPEC_REQ_BUFF_DEEP ; i = i + 1) begin 
        assign buff_used[i] = ~spec_req_buffer[i][0];
    end
endgenerate
//保留二进制最低位1操作-生成独热码
assign idle_buff_index_hot = buff_used & (~buff_used+1);
//独热码转二进制码
wire [INDEX_WITH-1 : 0] idle_buff_index_hot2bin_temp1 [SPEC_REQ_BUFF_DEEP-1 : 0]; 
wire [SPEC_REQ_BUFF_DEEP-1 : 0] idle_buff_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
generate
	for(i = 0; i < SPEC_REQ_BUFF_DEEP; i = i+1)begin 
		assign idle_buff_index_hot2bin_temp1[i] = idle_buff_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < SPEC_REQ_BUFF_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign idle_buff_index_hot2bin_temp2[j][i] = idle_buff_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign idle_buff_index[j] = |idle_buff_index_hot2bin_temp2[j];
	end
endgenerate


//------------------------------------------------------
//  判断buffer中是否有该类型第一笔请求即ERR的
//------------------------------------------------------

wire [SPEC_REQ_BUFF_DEEP-1:0] buffer_fir_falg; //表示buffer中的fir_flag位
generate
    for(i=0; i<SPEC_REQ_BUFF_DEEP; i=i+1) begin
        assign buffer_fir_falg[i] = spec_req_buffer[i][1];
    end
endgenerate
assign fir_err_en = (buffer_fir_falg !='d0) ? 1'b1 : 1'b0;

//------------------------------------------------------
//  生成fir_req_buff_index值
//------------------------------------------------------
wire [SPEC_REQ_BUFF_DEEP-1:0] fir_req_buff_index_hot;
wire [INDEX_WITH-1:0] fir_req_buff_index;

//保留二进制最低位1操作-生成独热码
assign fir_req_buff_index_hot = buffer_fir_falg & (~buffer_fir_falg+1);
//独热码转二进制码
wire [INDEX_WITH-1 : 0] fir_req_buff_index_hot2bin_temp1 [SPEC_REQ_BUFF_DEEP-1 : 0]; 
wire [SPEC_REQ_BUFF_DEEP-1 : 0] fir_req_buff_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
generate
	for(i = 0; i < SPEC_REQ_BUFF_DEEP; i = i+1)begin 
		assign fir_req_buff_index_hot2bin_temp1[i] = fir_req_buff_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < SPEC_REQ_BUFF_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign fir_req_buff_index_hot2bin_temp2[j][i] = fir_req_buff_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign fir_req_buff_index[j] = |fir_req_buff_index_hot2bin_temp2[j];
	end
endgenerate







//------------------------------------------------------
// 1、判断Status类型是否为ERR
// 2、判断bufferable、non-bufferable类型
// 3、判断为ERR或bufferable类型则写入buffer
// 4、buffer删除操作
//------------------------------------------------------
integer a;
generate 
    if(EARLY_RSP_MODE == 0) begin  //关闭early response功能

        always @(posedge clk or negedge resetn) begin
            if(resetn == 1'b0) begin
                for(a=0; a<SPEC_REQ_BUFF_DEEP; a=a+1)
                    spec_req_buffer[a] <= #DLY 'd0;
            end else begin
                if(reqo2rspo_head == 1'b1 && rspo2reqo_ready == 1'b1 && reqo2rspo_status == ERR) begin  //写入操作
                    spec_req_buffer[idle_buff_index] <= #DLY {
                        reqo2rspo_axid,
                        reqo2rspo_opc[3:2],
                        reqo2rspo_tag_cnt,
                        reqo2rspo_errcode,
                        reqo2rspo_status,
                        fir_req_flag,
                        1'b1
                        };
                end
                if(rspo2reqo_rhead_en == 1'b1) begin // 删除操作
                    if(follo_err_en == 1'b1 || fir_err_en == 1'b1)
                        spec_req_buffer[buff_index][0] <= #DLY 1'b0;
                    
                end
            end
        end

    end else begin   //开启early response功能

        always @(posedge clk or negedge resetn) begin
            if(resetn == 1'b0) begin
                for(a=0; a<SPEC_REQ_BUFF_DEEP; a=a+1)
                    spec_req_buffer[a] <= #DLY 'd0;
            end else begin                                                  // 暂时规定用user的第零位表示bufferable
                if(reqo2rspo_head == 1'b1 && rspo2reqo_ready == 1'b1 && (reqo2rspo_status == ERR || reqo2rspo_user[0] == 1'b1 )) begin  //写入操作
                    spec_req_buffer[idle_buff_index] <= #DLY {
                        reqo2rspo_axid,
                        reqo2rspo_opc[3:2],
                        reqo2rspo_tag_cnt,
                        reqo2rspo_errcode,
                        reqo2rspo_status,
                        fir_req_flag,
                        1'b1
                        };
                end 
                if(rspo2reqo_rhead_en == 1'b1) begin // 删除操作
                    if(follo_err_en == 1'b1 || fir_err_en == 1'b1)
                        spec_req_buffer[buff_index][0] <= #DLY 1'b0;
                end
            end
        end
    end
endgenerate




//------------------------------------------------------
// 1、请求通道数据透传，本模块无自主反压逻辑
// 2、SPECIAL信号不进行透传
//------------------------------------------------------
always @(*) begin
    if(reqo2rspo_status == OK) begin
        rspo2am_head = reqo2rspo_head;
        rspo2am_tail = reqo2rspo_tail;
        rspo2am_valid = reqo2rspo_valid;

    end else begin
        rspo2am_head = 1'b0;
        rspo2am_tail = 1'b0;
        rspo2am_valid = 1'b0;

    end
end

assign rspo2reqo_ready = am2rspo_ready;

assign rspo2am_urg = reqo2rspo_urg;
assign rspo2am_subr = reqo2rspo_subr;
assign rspo2am_addr = reqo2rspo_addr;
assign rspo2am_axid = reqo2rspo_axid;
assign rspo2am_opc = reqo2rspo_opc;
assign rspo2am_len = reqo2rspo_len;
assign rspo2am_user = reqo2rspo_user;
assign rspo2am_data = reqo2rspo_data;


//------------------------------------------------------
//  tag_name赋值
//------------------------------------------------------
// wire [AXID_WITH+3:0] tag_name [SPEC_REQ_BUFF_DEEP-1:0];

// generate
//     for(i=0; i<SPEC_REQ_BUFF_DEEP; i=i+1) begin
//         assign tag_name[i] = reqo2rspo_tag_name[(i+1)*(AXID_WITH+3)-1:i*(AXID_WITH+3)];
//     end
// endgenerate

reg [AXID_WITH+2:0] tag_name [SPEC_REQ_BUFF_DEEP-1:0];

generate
    for(i=0; i<SPEC_REQ_BUFF_DEEP; i=i+1) begin
        always @(*) begin
            tag_name[i] = reqo2rspo_tag_name[(i+1)*(AXID_WITH+3)-1:i*(AXID_WITH+3)];
        end
    end
endgenerate



//------------------------------------------------------
//  生成tag_name_index值
//------------------------------------------------------
wire [SPEC_REQ_BUFF_DEEP-1:0] tag_name_index_hot;
wire [INDEX_WITH-1:0] tag_name_index;
//独热码转二进制码
wire [INDEX_WITH-1 : 0] tag_name_index_hot2bin_temp1 [SPEC_REQ_BUFF_DEEP-1 : 0];
wire [SPEC_REQ_BUFF_DEEP-1 : 0] tag_name_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
//生成独热码
generate 
    for (i = 0 ; i < SPEC_REQ_BUFF_DEEP ; i = i + 1) begin 
        assign tag_name_index_hot[i] = {rspt2rspo_axid , rspt2rspo_opc , 1'b1} == tag_name[i] ? 1'b1 : 1'b0;
    end
endgenerate
//独热码转二进制码
generate
	for(i = 0; i < SPEC_REQ_BUFF_DEEP; i = i+1)begin 
		assign tag_name_index_hot2bin_temp1[i] = tag_name_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < SPEC_REQ_BUFF_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign tag_name_index_hot2bin_temp2[j][i] = tag_name_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign tag_name_index[j] = |tag_name_index_hot2bin_temp2[j];
	end
endgenerate

//------------------------------------------------------
//  tag_cnt自增操作
//------------------------------------------------------
reg [$clog2(SPEC_REQ_BUFF_DEEP)-1:0] tag_cnt [SPEC_REQ_BUFF_DEEP-1:0];

integer b;
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) begin
        for (b = 0; b < SPEC_REQ_BUFF_DEEP; b = b + 1)
            tag_cnt[b] <= #DLY 'd0;
    end else if(rspt2rspo_lw == 1'b1 && rspo2rspt_ready == 1'b1) begin
        if(tag_cnt[tag_name_index] < SPEC_REQ_BUFF_DEEP)
            tag_cnt[tag_name_index] <= #DLY tag_cnt[tag_name_index] + 1;
        else
            tag_cnt[tag_name_index] <= #DLY 'd0; 
    end else if(next_state == SPEC_RSP && rspo2reqo_rhead_en == 1'b1 && timout_fifo_rden == 1'b0) begin// 当传输特殊响应时，在索引head时就让cnt自增，对超时响应不自增
        if(tag_cnt[tag_name_index] < SPEC_REQ_BUFF_DEEP)
            tag_cnt[tag_name_index] <= #DLY tag_cnt[tag_name_index] + 1;
        else
            tag_cnt[tag_name_index] <= #DLY 'd0; 
    end
end



//------------------------------------------------------
//  接收由rsp_trans发送的响应信息
//------------------------------------------------------
reg [AXID_WITH-1:0]  rsp_axid;
reg [AUSER_WITH-1:0] rsp_user;
reg [1:0]            rsp_opc;
reg [2:0]            rsp_errcode;
reg [9*NBYTEPERWORD:0] rsp_data;

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rsp_axid <= #DLY 'd0;
        rsp_user <= #DLY 'd0;
        rsp_opc  <= #DLY 'd0;
        rsp_errcode <= #DLY 'd0;
    end else if(rspt2rspo_head == 1'b1 && rspo2rspt_ready == 1'b1)begin
        rsp_axid <= #DLY rspt2rspo_axid;
        rsp_user <= #DLY rspt2rspo_auser;
        rsp_opc  <= #DLY rspt2rspo_opc;
        rsp_errcode <= #DLY rspt2rspo_errcode;
    end
end
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rsp_data <= #DLY 'd0;
    end else if(rspt2rspo_valid == 1'b1 && rspo2rspt_ready == 1'b1)begin
        rsp_data <= #DLY rspt2rspo_data;
    end
end

//------------------------------------------------------
//  生成follo_req_buff_index值
//------------------------------------------------------
reg [$clog2(SPEC_REQ_BUFF_DEEP):0] next_tag_cnt;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        next_tag_cnt <= #DLY 'd0;
    end else if(tag_cnt[tag_name_index] == SPEC_REQ_BUFF_DEEP)begin
        next_tag_cnt[tag_name_index] <= #DLY 'd0;
    end else begin
        next_tag_cnt[tag_name_index] <= #DLY tag_cnt[tag_name_index] + 1'b1;
    end
end

wire [SPEC_REQ_BUFF_DEEP-1:0] follo_req_buff_index_hot;
wire [INDEX_WITH-1:0] follo_req_buff_index;
//独热码转二进制码
wire [INDEX_WITH-1 : 0] follo_req_buff_index_hot2bin_temp1 [SPEC_REQ_BUFF_DEEP-1 : 0];
wire [SPEC_REQ_BUFF_DEEP-1 : 0] follo_req_buff_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
//生成独热码
generate 
    for (i = 0 ; i < SPEC_REQ_BUFF_DEEP ; i = i + 1) begin 
        assign follo_req_buff_index_hot[i] = 
            ({rsp_axid , rsp_opc} == spec_req_buffer[i][BUFF_OPC_OFFSET +: 2+AXID_WITH] && spec_req_buffer[i][0] == 1'b1) 
            ? 1'b1 : 1'b0;
    end
endgenerate
//独热码转二进制码
generate
	for(i = 0; i < SPEC_REQ_BUFF_DEEP; i = i+1)begin 
		assign follo_req_buff_index_hot2bin_temp1[i] = follo_req_buff_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < SPEC_REQ_BUFF_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign follo_req_buff_index_hot2bin_temp2[j][i] = follo_req_buff_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign follo_req_buff_index[j] = |follo_req_buff_index_hot2bin_temp2[j];
	end
endgenerate


//------------------------------------------------------
//  判断该响应对应请求的下一笔请求是否为ERR
//------------------------------------------------------

assign follo_err_en = (follo_req_buff_index_hot !='d0) ? 1'b1 : 1'b0;






//------------------------------------------------------
//  生成特殊请求自组包的body部分
//------------------------------------------------------
wire [ADDR_WITH-1:0] addr_begin_align;  //原地址的向下对齐地址
wire [ADDR_WITH-1:0] addr_end_align;  //原地址的向下对齐地址
wire [ADDR_WITH-1:0] addr_end;
wire [7:0] valid_len_min;  //有效长度下限
wire [7:0] valid_len_max;  //有效长度上限
wire [7:0] total_flit;    //总flit数


assign addr_begin_align = reqo2rspo_rsp_addr & ~(NBYTEPERWORD-1);
assign valid_len_min = reqo2rspo_rsp_addr - addr_begin_align;
assign valid_len_max = reqo2rspo_rsp_addr + reqo2rspo_rsp_len;

assign addr_end = reqo2rspo_rsp_addr + reqo2rspo_rsp_len;  // 0x07 + 28 = 0x23

assign addr_end_align = (addr_end + (NBYTEPERWORD-1)) & ~(NBYTEPERWORD-1); 

assign total_flit = (addr_end_align - addr_begin_align) >> $clog2(NBYTEPERWORD) - 1;


reg [7:0] flit_cnt;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        flit_cnt <= #DLY 'd0;
    end else if(rspo2rknp_xx_tail == 1'b1) begin
        flit_cnt <= #DLY 'd0;
    end else if(rspo2rknp_xx_valid == 1'b1) begin
        flit_cnt <= #DLY flit_cnt + 1'b1;
    end
end


wire [9*NBYTEPERWORD:0] spec_rsp_data;  //自组织特殊响应的body部分
//------------------------------------------------------
//   生成特殊响应be位序列
//------------------------------------------------------
reg [NBYTEPERWORD-1:0] be_temp;

always @(*) begin
    if(flit_cnt == 'd0) begin
        be_temp = ({NBYTEPERWORD{1'b1}} >> valid_len_min) << valid_len_min;
    end else if(flit_cnt == valid_len_max)begin
        be_temp = ({NBYTEPERWORD{1'b1}} << valid_len_min) >> valid_len_min;
    end else begin
        be_temp = {NBYTEPERWORD{1'b1}};
    end
end
//------------------------------------------------------
//   1、填充byte位
//   2、填充be位
//------------------------------------------------------
reg rspt2rspo_lw_d;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rspt2rspo_lw_d <= #DLY 1'b0;
    end else begin
        rspt2rspo_lw_d <= #DLY rspt2rspo_lw;
    end 
end


reg [9*NBYTEPERWORD:0] norm_rsp_data;  //由slave发回的响应的body部分
localparam ADDR_OFFSET_WIDTH = 8 + $clog2(NBYTEPERWORD);


// 计算头尾be有效位置，支持交织
wire [$clog2(NBYTEPERWORD)-1:0] low_byte_disable_position;
wire [$clog2(NBYTEPERWORD)-1:0] high_byte_disable_position;

reg [$clog2(NBYTEPERWORD)-1:0] low_byte_disable_position_d;
reg [$clog2(NBYTEPERWORD)-1:0] high_byte_disable_position_d;

reg rhead_en_d;

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rhead_en_d <= #DLY 1'b0;
    end else begin
        rhead_en_d <= #DLY rspo2reqo_rhead_en;
    end
end

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        low_byte_disable_position_d <= #DLY 'd0;
        high_byte_disable_position_d <= #DLY 'd0;
    end else if(rhead_en_d == 1'b1)begin
        low_byte_disable_position_d <= #DLY low_byte_disable_position;
        high_byte_disable_position_d <= #DLY high_byte_disable_position;
    end
end

assign low_byte_disable_position = (rhead_en_d == 1'b1) ? reqo2rspo_rsp_addr[$clog2(NBYTEPERWORD)-1:0] : 0;
assign high_byte_disable_position = (rhead_en_d == 1'b1) ? reqo2rspo_rsp_addr[$clog2(NBYTEPERWORD)-1:0] + reqo2rspo_rsp_len : high_byte_disable_position_d;

generate 
    for(i=0; i<NBYTEPERWORD; i=i+1) begin
        always @(*) begin
            if(rspo2rknp_xx_head == 1'b1 && rspt2rspo_lw_d == 1'b0) begin // 如果多拍，则头部按规则拉低be
                norm_rsp_data[i*9+1] = (i < low_byte_disable_position) ? 1'b0 : 1'b1;  
            end else if(rspt2rspo_lw_d == 1'b1) begin // 如果多拍，则尾部按规则拉低be
                norm_rsp_data[i*9+1] = (i > high_byte_disable_position) ? 1'b0 : 1'b1;  
            end else if(rspo2rknp_xx_head == 1'b0 && rspt2rspo_lw_d == 1'b0 && rspo2rknp_xx_valid == 1'b1) begin
                norm_rsp_data[i*9+1] = 1'b1;  
            end else begin
                norm_rsp_data[i*9+1] = 1'b1;
            end
        end
        always @(*) begin
            norm_rsp_data[i*9+9:i*9+2] = rsp_data[i*9+9:i*9+2];
        end
        assign spec_rsp_data[i*9+9:i*9+2] = 1'b0;
        // assign norm_rsp_data[i*9+9:i*9+2] = rsp_data[i*9+9:i*9+2];

        assign spec_rsp_data[i*9+1] = be_temp[i];  //特殊响应的be填充
        // assign norm_rsp_data[i*9+1] = () ? 1'b0 : 1'b1;  

        //不应该在这里写LW
        // if(i == NBYTEPERWORD-1) begin
        //     assign spec_rsp_data[0] = 1'b1; //特殊响应的LW填充
        //     assign norm_rsp_data[0] = 1'b1; //常规响应的LW填充
        // end else begin
        //     assign spec_rsp_data[0] = 1'b0;
        //     assign norm_rsp_data[0] = 1'b0;
        // end

    end
endgenerate

//合并到上面了
// generate 
//     for(i=0; i<NBYTEPERWORD; i=i+1) begin
//         assign spec_rsp_data[i*9+9:i*9+2] = 1'b0;
//         assign norm_rsp_data[i*9+9:i*9+2] = rsp_data[i*9-1:i*9-8];
//     end
// endgenerate



//------------------------------------------------------
//  索引值选择
//------------------------------------------------------

reg [SPEC_REQ_BUFF_DEEP-1:0] buff_index_d;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) 
        buff_index_d <= #DLY 'd0;
    else 
        buff_index_d <= #DLY buff_index;
end

always @(*) begin
    if(follo_err_en == 1'b1) 
        buff_index = follo_req_buff_index;
    else if(fir_err_en == 1'b1)
        buff_index = fir_req_buff_index;
    else
        buff_index = buff_index_d; //其他情况保持
end

//------------------------------------------------------
//  更改 spec rsp ErrorCode、Status
//------------------------------------------------------
reg [2:0] spec_rsp_errcode;
reg [1:0] spec_rsp_status;

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        spec_rsp_errcode <= #DLY 3'd0;
        spec_rsp_status <= #DLY 2'd0;
    end else if(rspo2wd_timoff_en == 1'b1) begin
        spec_rsp_errcode <= #DLY TIM_OUT;
        spec_rsp_status <= #DLY ERR;
    end else begin
        spec_rsp_errcode <= #DLY spec_req_buffer[buff_index][BUFF_ERRC_OFFSET +: 3];
        spec_rsp_status <= #DLY spec_req_buffer[buff_index][BUFF_STAT_OFFSET +: 2];
    end
end

//------------------------------------------------------
//  在spec_req_buffer被删除后保持spec_req_buffer值
//------------------------------------------------------
reg [1:0] spec_rsp_opc;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        spec_rsp_opc <= #DLY 2'd0;
    end else if(rspo2wd_timoff_en == 1'b1) begin
        spec_rsp_opc <= #DLY wd2rspo_opc;
    end else begin
        spec_rsp_opc <= #DLY spec_req_buffer[buff_index][BUFF_OPC_OFFSET +: 2];
    end
end

//------------------------------------------------------
//  生成常规响应的status值
//------------------------------------------------------



// reg [1:0] norm_rsp_status;
// always @(*) begin
//     if(rspt2rspo_status == ERR)
//         norm_rsp_status = ERR;
//     else
//         if(rspt2rspo_lw_d == 1'b1) 
//             norm_rsp_status = OK;
//         else
//             norm_rsp_status = CONT;
// end

//------------------------------------------------------
//  RKNP协议组包输出
//------------------------------------------------------

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        cur_state <= #DLY NORM_RSP;
    end else begin
        cur_state <= #DLY next_state;
    end
end

always @(*) begin
    case(cur_state)
        NORM_RSP: begin
            if((rspo2reqo_rhead_en == 1'b1 && rspo2rspt_ready == 1'b0)&& (follo_err_en == 1'b1 || fir_err_en == 1'b1 || timout_fifo_rden == 1'b1)) begin
                next_state = SPEC_RSP;
            end else if((rspt2rspo_lw == 1'b1 && rspo2rspt_ready == 1'b0)&& (follo_err_en == 1'b1 || fir_err_en == 1'b1 || timout_fifo_rden == 1'b1)) begin
                next_state = SPEC_RSP;
            end else begin
                next_state = NORM_RSP;
            end
        end
        SPEC_RSP: begin
            if(rspo2reqo_rhead_en == 1'b1 && follo_err_en == 1'b0 && fir_err_en == 1'b0 && timout_fifo_rden == 1'b0) begin
                next_state = NORM_RSP;
            end else begin
                next_state = SPEC_RSP;
            end
        end
    endcase
end


always @(*) begin
    case(cur_state)
        NORM_RSP: begin
            if(rspo2rknp_xx_valid == 1'b1 && rknp_xx2rspo_ready == 1'b1 && reqo2rspo_timout == 1'b0 && buff_rsp_flag == 1'b0) begin  //对常规响应，忽略超时响应与bufferable响应

                rspo2rknp_xx_data = {
                    norm_rsp_data,
                    rsp_errcode,
                    reqo2rspo_rsp_user[AUSER_WITH+8], //RKNUSER
                    rsp_user,                         //AxUSER
                    reqo2rspo_rsp_user[7:0],          //AxLOCL\AxPORT\AxCACHE
                    reqo2rspo_rsp_addr,
                    reqo2rspo_rsp_status,             //status
                    rsp_opc,
                    reqo2rspo_rsp_ordkey,
                    reqo2rspo_rsp_tid,
                    reqo2rspo_rsp_iid,
                    reqo2rspo_rsp_urg};
                
            end else begin
                rspo2rknp_xx_data = 'd0;
            end
        end
        SPEC_RSP: begin
            if(rspo2rknp_xx_valid == 1'b1 && rknp_xx2rspo_ready == 1'b1) begin
                rspo2rknp_xx_data = {
                    spec_rsp_data,
                    spec_rsp_errcode,
                    reqo2rspo_user,
                    reqo2rspo_rsp_addr,
                    spec_rsp_status,
                    spec_rsp_opc,
                    reqo2rspo_rsp_ordkey,
                    reqo2rspo_rsp_tid,
                    reqo2rspo_rsp_iid,
                    reqo2rspo_rsp_urg
                    };
            end
        end
    endcase
end


//------------------------------------------------------
//   1、传输rspo2wad_offset_addr
//   2、传输rspo2wad_axid
//------------------------------------------------------
assign rspo2wad_axid = rsp_axid;
assign rspo2wad_offset_addr = reqo2rspo_rsp_offset_addr;


//------------------------------------------------------
//   1、生成rspo2rknp_xx_head
//   2、生成rspo2rknp_xx_tail
//   3、生成rspo2rknp_xx_valid
//------------------------------------------------------
reg rspt2rspo_head_d;
reg rspt2rspo_tail_d;
reg rspt2rspo_valid_d;

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rspt2rspo_head_d <= #DLY 1'b0;
    end else if(rspt2rspo_head == 1'b1 && rspo2rspt_ready == 1'b1) begin
        rspt2rspo_head_d <= #DLY 1'b1;
    end else if(rknp_xx2rspo_ready == 1'b1) begin
        rspt2rspo_head_d <= #DLY 1'b0;
    end
end
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rspt2rspo_tail_d <= #DLY 1'b0;
    end else if(rspt2rspo_tail == 1'b1 && rspo2rspt_ready == 1'b1) begin
        rspt2rspo_tail_d <= #DLY 1'b1;
    end else if(rknp_xx2rspo_ready == 1'b1) begin
        rspt2rspo_tail_d <= #DLY 1'b0;
    end
end
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rspt2rspo_valid_d <= #DLY 1'b0;
    end else if(rspt2rspo_valid == 1'b1 && rspo2rspt_ready == 1'b1) begin
        rspt2rspo_valid_d <= #DLY 1'b1;
    end else if(rknp_xx2rspo_ready == 1'b1) begin
        rspt2rspo_valid_d <= #DLY 1'b0;
    end
end




always @(*) begin
    case(cur_state)
        NORM_RSP: begin
            // if(reqo2rspo_timout == 1'b0 && reqo2rspo_rsp_status != CONT && rsp_opc == WR) begin //若该响应为已经超时响应或early response的real response，则不传输
            if(reqo2rspo_timout == 1'b0 && buff_rsp_flag == 1'b0) begin //若该响应为已经超时响应或early response的real response，则不传输
                rspo2rknp_xx_head = rspt2rspo_head_d;
                rspo2rknp_xx_tail = rspt2rspo_tail_d;
                rspo2rknp_xx_valid = rspt2rspo_valid_d;
            end else begin
                rspo2rknp_xx_head = 1'b0;
                rspo2rknp_xx_tail = 1'b0;
                rspo2rknp_xx_valid = 1'b0;
            end
        end
        SPEC_RSP: begin
            if(rspo2rknp_xx_data[RSP_OPC_OFFSET +: 2] == RD || reqo2rspo_rsp_len != 'd0) begin
                if(flit_cnt == 'd0) begin
                    rspo2rknp_xx_head = 1'b1;
                    rspo2rknp_xx_tail = 1'b0;
                    rspo2rknp_xx_valid = 1'b0;
                end else if(flit_cnt == total_flit)begin
                    rspo2rknp_xx_head = 1'b0;
                    rspo2rknp_xx_tail = 1'b1;
                    rspo2rknp_xx_valid = 1'b0;
                end else begin
                    rspo2rknp_xx_head = 1'b0;
                    rspo2rknp_xx_tail = 1'b1;
                    rspo2rknp_xx_valid = 1'b0;
                end
            end else begin
                rspo2rknp_xx_head = 1'b1;
                rspo2rknp_xx_tail = 1'b1;
                rspo2rknp_xx_valid = 1'b1;
            end
        end
    endcase
end


//------------------------------------------------------
//   填充LW位
//------------------------------------------------------

//assign norm_rsp_data[0] = (flit_cnt == total_flit) ? 1'b1 : 1'b0;  //交织时这个是错的,flit_cnt只能给特殊响应用

assign norm_rsp_data[0] = (rspt2rspo_lw_d == 1'b1) ? 1'b1 : 1'b0;
assign spec_rsp_data[0] = (flit_cnt == total_flit) ? 1'b1 : 1'b0;


//------------------------------------------------------
//  生成timout_fifo_rden
//------------------------------------------------------
wire timout_fifo_empty_neg;
reg timout_fifo_empty_d;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0)
        timout_fifo_empty_d <= #DLY 1'b1;
    else
        timout_fifo_empty_d <= #DLY timout_fifo_empty;
    
end
assign  timout_fifo_empty_neg = timout_fifo_empty_d & ~timout_fifo_empty;

always @(*) begin
    if(rspo2rknp_xx_tail == 1'b1 && rknp_xx2rspo_ready == 1'b1 && timout_fifo_empty == 1'b0)
        timout_fifo_rden = 1'b1;
    // else if(timout_fifo_empty_neg == 1'b1) // bug,2026_07_07
    //     timout_fifo_rden = 1'b1;
    else
        timout_fifo_rden = 1'b0;
end

//------------------------------------------------------
//  生成rspo2reqo_timout
//------------------------------------------------------
assign rspo2reqo_timout = (timout_fifo_rden == 1'd1) ? 1'd1 : 1'd0; 

//------------------------------------------------------
//  当前模块正在传输响应，并且同时接收一笔同类型的请求时，需判断此请求是不是此响应的下一笔请求，防止这笔请求在响应走无法被索引
//------------------------------------------------------
wire conflict_flag;  //冲突标志位
reg tag_name_index_d;
always @(posedge clk or negedge resetn) begin
    if(resetn) begin
        tag_name_index_d = 'd0;
    end else begin
        tag_name_index_d = tag_name_index;
    end
end
generate
    if(EARLY_RSP_MODE == 0) begin
        assign conflict_flag = (rspo2rknp_xx_tail == 1'b1 && rknp_xx2rspo_ready == 1'b1 
                                && reqo2rspo_head == 1'b1 && rspo2reqo_ready == 1'b1 && reqo2rspo_errcode == ERR
                                && spec_rsp_opc == reqo2rspo_axid && rsp_axid == reqo2rspo_axid && tag_cnt[tag_name_index_d] == reqo2rspo_tag_cnt) 
                                ? 1'b1 : 1'b0;
    end else begin
        assign conflict_flag = (rspo2rknp_xx_tail == 1'b1 && rknp_xx2rspo_ready == 1'b1 
                                && reqo2rspo_head == 1'b1 && rspo2reqo_ready == 1'b1 && (reqo2rspo_errcode == ERR || reqo2rspo_user[0] == 1'b1) 
                                && spec_rsp_opc == reqo2rspo_axid && rsp_axid == reqo2rspo_axid && tag_cnt[tag_name_index_d] == reqo2rspo_tag_cnt) 
                                ? 1'b1 : 1'b0;
    end
endgenerate
//------------------------------------------------------
//  1、rsp_order向req_order索引head信息
//  2、rsp_order提示req_order删除head信息
//  3、rsp_order提示req_order更改head addr信息
//  4、分eraly response模式和非early response模式
//------------------------------------------------------
generate
    if(EARLY_RSP_MODE == 0) begin
        always @(*) begin
            case(next_state)
                NORM_RSP: begin
                    rspo2reqo_head_index = {rspt2rspo_axid , rspt2rspo_opc , tag_cnt[tag_name_index]};
                    rspo2reqo_rhead_en = (rspt2rspo_head == 1'b1 && rspo2rspt_ready == 1'b1) ? 1'd1 : 1'b0;
                    del_head_en = (rspt2rspo_lw == 1'b1 && rspo2rspt_ready == 1'b1) ? 1'd1 : 1'b0;
                    rspo2reqo_rsp_valid = (rspt2rspo_valid == 1'b1 && rspo2rspt_ready == 1'b1) ? 1'd1 : 1'b0;
                    
                end
                SPEC_RSP: begin
                    if(timout_fifo_rden == 1'b1) begin 
                        rspo2reqo_head_index = {wd2rspo_axid,wd2rspo_opc,tag_cnt[tag_name_index]};
                        rspo2reqo_rhead_en = 1'b1;
                        del_head_en = 1'b0;
                    end else if(rspo2rknp_xx_tail == 1'b1 && rknp_xx2rspo_ready == 1'b1 && conflict_flag == 1'b1) begin  // 当前模块正在传输响应，并且同时接收一笔同类型的请求时，需判断此请求是不是此响应的下一笔请求
                        rspo2reqo_head_index = {reqo2rspo_axid,reqo2rspo_opc,reqo2rspo_tag_cnt};
                        rspo2reqo_rhead_en = 1'b1;
                        del_head_en = 1'b1;
                    end else if(rspo2rknp_xx_tail == 1'b1 && rknp_xx2rspo_ready == 1'b1 && (follo_err_en == 1'b1 && fir_err_en == 1'b1)) begin  // 当前模块正在传输响应，且存在follo_req\fir_req时
                        rspo2reqo_head_index = {spec_req_buffer[buff_index][BUFF_TAGCNT_OFFSET +: AXID_WITH+TAG_CNT_WITH+2]};
                        rspo2reqo_rhead_en = 1'b1;
                        del_head_en = 1'b1;
                    end else if(rspo2rknp_xx_valid == 1'b0 && fir_err_en == 1'b1) begin  // 当前模块未在传输响应，且存在fir_err时
                        rspo2reqo_head_index = {spec_req_buffer[buff_index][BUFF_TAGCNT_OFFSET +: AXID_WITH+TAG_CNT_WITH+2]};
                        rspo2reqo_rhead_en = 1'b1;
                        del_head_en = 1'b1;
                    end else begin
                        rspo2reqo_head_index = 'd0;
                        rspo2reqo_rhead_en = 1'b0;
                        del_head_en = 1'b0;
                    end
                end
            endcase
        end
    end else begin
        always @(*) begin
            case(next_state)
                NORM_RSP: begin
                    if(buff_rsp_flag == 1'b0) begin
                        rspo2reqo_head_index = {rspt2rspo_axid , rspt2rspo_opc , tag_cnt[tag_name_index]};
                        rspo2reqo_rhead_en = (rspt2rspo_head == 1'b1 && rspo2rspt_ready == 1'b1) ? 1'd1 : 1'b0;
                        del_head_en = (rspt2rspo_lw == 1'b1 && rspo2rspt_ready == 1'b1) ? 1'd1 : 1'b0;
                        rspo2reqo_rsp_valid = (rspt2rspo_valid == 1'b1 && rspo2rspt_ready == 1'b1) ? 1'd1 : 1'b0;
                        
                    end else begin
                        rspo2reqo_head_index = {rspt2rspo_axid , rspt2rspo_opc , erd2rspo_tag_cnt};
                        rspo2reqo_rhead_en = 1'b0;     //仅删除，不读取
                        del_head_en = (rspt2rspo_lw == 1'b1 && rspo2rspt_ready == 1'b1) ? 1'd1 : 1'b0;  //删除early response的real response
                        rspo2reqo_rsp_valid = 1'b0;    //仅删除，无需修改地址
                    end
                    
                end
                SPEC_RSP: begin
                    if(timout_fifo_rden == 1'b1) begin 
                        rspo2reqo_head_index = {wd2rspo_axid,wd2rspo_opc,tag_cnt[tag_name_index]};
                        rspo2reqo_rhead_en = 1'b1;
                        del_head_en = 1'b0;
                    end else if(rspo2rknp_xx_tail == 1'b1 && rknp_xx2rspo_ready == 1'b1 && conflict_flag == 1'b1) begin  // 当前模块正在传输响应，并且同时接收一笔同类型的请求时，需判断此请求是不是此响应的下一笔请求
                        rspo2reqo_head_index = {reqo2rspo_axid,reqo2rspo_opc,reqo2rspo_tag_cnt};
                        rspo2reqo_rhead_en = 1'b1;
                        del_head_en = 1'b1;
                    end else if(rspo2rknp_xx_tail == 1'b1 && rknp_xx2rspo_ready == 1'b1 && (follo_err_en == 1'b1 || fir_err_en == 1'b1)) begin  // 当前模块正在传输响应，且存在follo_req\fir_req时
                        rspo2reqo_head_index = {spec_req_buffer[buff_index][BUFF_TAGCNT_OFFSET +: AXID_WITH+TAG_CNT_WITH+2]};
                        rspo2reqo_rhead_en = 1'b1;
                        if(spec_req_buffer[buff_index][BUFF_STAT_OFFSET] == OK) del_head_en = 1'b0; //若该请求为bufferable，则不删除
                        else                                                    del_head_en = 1'b1; //若该请求本身为ERR请求，则删除
                    end else if(rspo2rknp_xx_valid == 1'b0 && fir_err_en == 1'b1) begin  // 当前模块未在传输响应，且存在fir_err时
                        rspo2reqo_head_index = {spec_req_buffer[buff_index][BUFF_TAGCNT_OFFSET +: AXID_WITH+TAG_CNT_WITH+2]};
                        rspo2reqo_rhead_en = 1'b1;
                        if(spec_req_buffer[buff_index][BUFF_STAT_OFFSET] == OK) del_head_en = 1'b0; //若该请求为bufferable，则不删除
                        else                                                    del_head_en = 1'b1; //若该请求本身为ERR请求，则删除
                    end else begin
                        rspo2reqo_head_index = 'd0;
                        rspo2reqo_rhead_en = 1'b0;
                        del_head_en = 1'b0;
                    end
                end
            endcase
        end
    end
endgenerate



always @(*) begin
    case(next_state)
        NORM_RSP: begin
            rspo2reqo_rsp_valid = rspo2rknp_xx_valid;
        end
        SPEC_RSP: begin
            rspo2reqo_rsp_valid = 1'b0;
        end
    endcase
end

//------------------------------------------------------
//   生成rspo2rspt_ready信号
//------------------------------------------------------
always @(*) begin
    if(next_state == SPEC_RSP) //当处于处理特殊响应（包括超时响应）时需反压rsp_trans模块
        rspo2rspt_ready = 1'b0;
    else
        rspo2rspt_ready = rknp_xx2rspo_ready;
end


//------------------------------------------------------
//  停止watchdog计时
//------------------------------------------------------

always @(*) begin
    
    if(rspt2rspo_head == 1'b1 && rspo2rspt_ready == 1'b1) begin
        rspo2wd_timoff_en = 1'b1;
        rspo2wd_axid = rspt2rspo_axid;
        rspo2wd_opc = rspt2rspo_opc;
        rspo2wd_tag_cnt = tag_cnt[tag_name_index]; 
    end else begin
        rspo2wd_timoff_en = 1'b0;
        rspo2wd_axid = 'd0;
        rspo2wd_opc = 'd0;
        rspo2wd_tag_cnt = 'd0; 
    end
end


//------------------------------------------------------
//  early response模式下开启与ely_rsp_detect模块的通信
//------------------------------------------------------

generate
    if(EARLY_RSP_MODE == 0) begin
        assign rspo2erd_head = 1'b0;
        assign rspo2erd_axid = 'd0;
        assign rspo2erd_opc  = 4'd0;
        assign rspo2erd_user = 'd0;
        assign rspo2erd_tag_cnt = 'd0;
    end else begin
        assign rspo2erd_head = (rspo2am_head == 1'b1 && am2rspo_ready == 1'b1) ? 1'b1 : 1'b0;
        assign rspo2erd_axid = rspo2am_axid;
        assign rspo2erd_opc  = rspo2am_opc;
        assign rspo2erd_user = rspo2am_user;
        assign rspo2erd_tag_cnt = reqo2rspo_tag_cnt;
    end
endgenerate











endmodule