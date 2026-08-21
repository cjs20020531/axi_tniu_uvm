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
    ,input         [TAG_CNT_WITH-1:0]     erd2rspo_tag_cnt
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
localparam BUFF_OPC_OFFSET = BUFF_TAGCNT_OFFSET + TAG_CNT_WITH;
localparam BUFF_AXID_OFFSET = BUFF_OPC_OFFSET + 2;
localparam INDEX_WITH = $clog2(SPEC_REQ_BUFF_DEEP);


reg cur_state;
reg next_state;

wire follo_err_en; //buffer中存在下一笔请求为err的有效标志位
wire fir_err_en;   //buffer中存在第一笔该类型请求为err的有效标志位
wire spec_dispatch_en; //本拍明确读取并启动一笔特殊响应
wire rsp_tail_hs;
wire spec_err_pending;
wire rsp_path_idle;    //响应通路空闲，可直接启动一笔特殊响应
wire timeout_pending;  //timeout FIFO中存在待处理响应
wire dispatch_boundary;//可以启动下一笔特殊响应的时机
wire spec_req_ready_en;
reg [SPEC_REQ_BUFF_DEEP-1:0] spec_req_ready_hot;
reg [INDEX_WITH-1:0] spec_req_ready_index;
reg [INDEX_WITH-1:0] buff_index;  //选择特殊请求缓冲的索引值

//------------------------------------------------------
//  生成idle_buff_index值
//------------------------------------------------------
genvar i,j;
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

reg [AXID_WITH-1:0] reqo2rspo_axid_d;  // tail拉高时spec请求才能存入spec buffer，所以要寄存
reg [3:0]           reqo2rspo_opc_d;
reg [2:0]           reqo2rspo_tag_cnt_d;
reg [2:0]           reqo2rspo_errcode_d;
reg [1:0]           reqo2rspo_status_d;
reg                 fir_req_flag_d;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        reqo2rspo_axid_d    <= #DLY 'd0;      
        reqo2rspo_opc_d     <= #DLY 4'd0;         
        reqo2rspo_tag_cnt_d <= #DLY 3'd0;            
        reqo2rspo_errcode_d <= #DLY 3'd0;           
        reqo2rspo_status_d  <= #DLY 2'd0;           
        fir_req_flag_d      <= #DLY 1'b0;          
    end else if(reqo2rspo_head == 1'b1 && rspo2reqo_ready == 1'b1)begin
        reqo2rspo_axid_d    <= #DLY reqo2rspo_axid;      
        reqo2rspo_opc_d     <= #DLY reqo2rspo_opc;         
        reqo2rspo_tag_cnt_d <= #DLY reqo2rspo_tag_cnt;            
        reqo2rspo_errcode_d <= #DLY reqo2rspo_errcode;           
        reqo2rspo_status_d  <= #DLY reqo2rspo_status;           
        fir_req_flag_d      <= #DLY fir_req_flag;  
    end else if(reqo2rspo_tail == 1'b1 && rspo2reqo_ready == 1'b1) begin
        fir_req_flag_d      <= #DLY 1'b0;  
    end
end


integer a;
generate 
    if(EARLY_RSP_MODE == 0) begin  //关闭early response功能

        always @(posedge clk or negedge resetn) begin
            if(resetn == 1'b0) begin
                for(a=0; a<SPEC_REQ_BUFF_DEEP; a=a+1)
                    spec_req_buffer[a] <= #DLY 'd0;
            end else begin
                if(reqo2rspo_status == ERR) begin
                    if(reqo2rspo_head == 1'b1 && reqo2rspo_tail == 1'b1 && rspo2reqo_ready == 1'b1) begin
                        spec_req_buffer[idle_buff_index] <= #DLY {
                            reqo2rspo_axid,
                            reqo2rspo_opc[3:2],
                            reqo2rspo_tag_cnt,
                            reqo2rspo_errcode,
                            reqo2rspo_status,
                            fir_req_flag,
                            1'b1
                        };
                    end else if(reqo2rspo_tail == 1'b1 && rspo2reqo_ready == 1'b1) begin  //写入操作
                        spec_req_buffer[idle_buff_index] <= #DLY {
                            reqo2rspo_axid_d,
                            reqo2rspo_opc_d[3:2],
                            reqo2rspo_tag_cnt_d,
                            reqo2rspo_errcode_d,
                            reqo2rspo_status_d,
                            fir_req_flag_d,
                            1'b1
                        };
                    end
                end
                
                // 只有真正为特殊响应读取head时，才能释放对应的特殊请求。
                // 普通响应同样会拉高rspo2reqo_rhead_en，不能据此误删尚未发送的ERR。
                if(spec_dispatch_en == 1'b1 &&
                   timout_fifo_rden == 1'b0 &&
                   spec_req_ready_en == 1'b1)
                    spec_req_buffer[buff_index][1:0] <= #DLY 2'b00;
            end
        end

    end else begin   //开启early response功能

        always @(posedge clk or negedge resetn) begin
            if(resetn == 1'b0) begin
                for(a=0; a<SPEC_REQ_BUFF_DEEP; a=a+1)
                    spec_req_buffer[a] <= #DLY 'd0;
            end else begin                                                  // 暂时规定用user的第零位表示bufferable
                if(reqo2rspo_status == ERR || reqo2rspo_user[0] == 1'b1) begin
                    
                    if(reqo2rspo_head == 1'b1 && reqo2rspo_tail == 1'b1 && rspo2reqo_ready == 1'b1) begin
                        spec_req_buffer[idle_buff_index] <= #DLY {
                            reqo2rspo_axid,
                            reqo2rspo_opc[3:2],
                            reqo2rspo_tag_cnt,
                            reqo2rspo_errcode,
                            reqo2rspo_status,
                            fir_req_flag,
                            1'b1
                        };
                    end else if(reqo2rspo_tail == 1'b1 && rspo2reqo_ready == 1'b1) begin  //写入操作
                        spec_req_buffer[idle_buff_index] <= #DLY {
                            reqo2rspo_axid_d,
                            reqo2rspo_opc_d[3:2],
                            reqo2rspo_tag_cnt_d,
                            reqo2rspo_errcode_d,
                            reqo2rspo_status_d,
                            fir_req_flag_d,
                            1'b1
                        };
                    end
                end
                
                // early response模式也必须区分普通rhead与特殊rhead。
                if(spec_dispatch_en == 1'b1 &&
                   timout_fifo_rden == 1'b0 &&
                   spec_req_ready_en == 1'b1)
                    spec_req_buffer[buff_index][1:0] <= #DLY 2'b00;
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
reg  [INDEX_WITH-1:0] tag_name_index_d;
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

// 保持当前常规响应所对应的tag_name索引。多拍响应仅在HEAD拍提供
// 新的响应类型，LW拍必须使用HEAD拍锁存的索引推进tag计数器。
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0)
        tag_name_index_d <= #DLY 'd0;
    else if(rspt2rspo_head == 1'b1 && rspt2rspo_valid == 1'b1 &&
            rspo2rspt_ready == 1'b1)
        tag_name_index_d <= #DLY tag_name_index;
end

wire [INDEX_WITH-1:0] norm_rsp_tag_name_index;
assign norm_rsp_tag_name_index =
    (rspt2rspo_head == 1'b1) ? tag_name_index : tag_name_index_d;

//------------------------------------------------------
//  生成当前特殊响应对应的tag_name索引
//------------------------------------------------------
reg [INDEX_WITH-1:0] spec_tag_name_index;
reg [INDEX_WITH-1:0] wd_tag_name_index;
integer tag_lookup_i;
always @(*) begin
    spec_tag_name_index = 'd0;
    wd_tag_name_index = 'd0;
    for(tag_lookup_i=0; tag_lookup_i<SPEC_REQ_BUFF_DEEP;
        tag_lookup_i=tag_lookup_i+1) begin
        if({spec_req_buffer[buff_index][BUFF_OPC_OFFSET +: AXID_WITH+2],
            1'b1} == tag_name[tag_lookup_i])
            spec_tag_name_index = tag_lookup_i;
        if({wd2rspo_axid, wd2rspo_opc, 1'b1} == tag_name[tag_lookup_i])
            wd_tag_name_index = tag_lookup_i;
    end
end

//------------------------------------------------------
//  tag_cnt自增操作
//------------------------------------------------------
reg [$clog2(SPEC_REQ_BUFF_DEEP)-1:0] tag_cnt [SPEC_REQ_BUFF_DEEP-1:0];
reg [INDEX_WITH-1:0] spec_rsp_tag_name_index;
reg [AXID_WITH-1:0] spec_rsp_axid;
reg [1:0] spec_rsp_opc;
reg [2:0] spec_rsp_errcode;
reg [1:0] spec_rsp_status;

integer b;
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) begin
        for (b = 0; b < SPEC_REQ_BUFF_DEEP; b = b + 1)
            tag_cnt[b] <= #DLY 'd0;
    // A bufferable write already advanced this ordering tag when its early
    // response was dispatched.  Its later real B response only retires the
    // request/watchdog state and must not advance the same tag a second time.
    end else if(rspt2rspo_valid == 1'b1 &&
                rspt2rspo_lw == 1'b1 &&
                rspo2rspt_ready == 1'b1 &&
                buff_rsp_flag == 1'b0) begin
        if(tag_cnt[norm_rsp_tag_name_index] == SPEC_REQ_BUFF_DEEP-1)
            tag_cnt[norm_rsp_tag_name_index] <= #DLY 'd0;
        else
            tag_cnt[norm_rsp_tag_name_index] <= #DLY
                tag_cnt[norm_rsp_tag_name_index] + 1'b1;
    end else if(spec_dispatch_en == 1'b1 &&
                timout_fifo_rden == 1'b0) begin// 启动特殊响应时推进对应类型tag，超时响应不推进
        if(tag_cnt[spec_tag_name_index] == SPEC_REQ_BUFF_DEEP-1)
            tag_cnt[spec_tag_name_index] <= #DLY 'd0;
        else
            tag_cnt[spec_tag_name_index] <= #DLY
                tag_cnt[spec_tag_name_index] + 1'b1;
    end
end

//------------------------------------------------------
//  对全部特殊请求逐项判断是否已经到达各自类型的响应顺序头
//------------------------------------------------------
integer spec_ready_i;
integer spec_ready_tag_i;
always @(*) begin
    spec_req_ready_hot = 'd0;
    for(spec_ready_i=0;
        spec_ready_i<SPEC_REQ_BUFF_DEEP;
        spec_ready_i=spec_ready_i+1) begin
        if(spec_req_buffer[spec_ready_i][0] == 1'b1) begin
            // fir_flag用于新类型首次分配时的快速路径。
            if(spec_req_buffer[spec_ready_i][BUFF_FIR_FLAG_OFFSET] == 1'b1)
                spec_req_ready_hot[spec_ready_i] = 1'b1;
            else begin
                // follower必须和该条目自己的{AXID,OPC,TAG}比较，
                // 不能只依赖最后一笔普通响应的类型。
                for(spec_ready_tag_i=0;
                    spec_ready_tag_i<SPEC_REQ_BUFF_DEEP;
                    spec_ready_tag_i=spec_ready_tag_i+1) begin
                    if(tag_name[spec_ready_tag_i][0] == 1'b1 &&
                       tag_name[spec_ready_tag_i][1 +: AXID_WITH+2] ==
                           spec_req_buffer[spec_ready_i]
                               [BUFF_OPC_OFFSET +: AXID_WITH+2] &&
                       tag_cnt[spec_ready_tag_i] ==
                           spec_req_buffer[spec_ready_i]
                               [BUFF_TAGCNT_OFFSET +: TAG_CNT_WITH])
                        spec_req_ready_hot[spec_ready_i] = 1'b1;
                end
            end
        end
    end
end

assign spec_req_ready_en = |spec_req_ready_hot;

integer spec_ready_sel_i;
always @(*) begin
    spec_req_ready_index = 'd0;
    // 从高到低覆盖，最终保留最低有效下标。
    for(spec_ready_sel_i=SPEC_REQ_BUFF_DEEP-1;
        spec_ready_sel_i>=0;
        spec_ready_sel_i=spec_ready_sel_i-1)
        if(spec_req_ready_hot[spec_ready_sel_i] == 1'b1)
            spec_req_ready_index = spec_ready_sel_i;
end



//------------------------------------------------------
//  接收由rsp_trans发送的响应信息
//------------------------------------------------------
reg [AXID_WITH-1:0]  rsp_axid;
reg [AUSER_WITH-1:0] rsp_user;
reg [1:0]            rsp_opc;
reg [2:0]            rsp_errcode;
reg [1:0]            rsp_status;
reg [9*NBYTEPERWORD:0] rsp_data;

// Keep the complete req_order lookup key for the current normal response
// packet.  rsp_trans only guarantees a new AXID/OPC on HEAD; body flits must
// continue to update the same head-buffer entry even when another AXID is
// interleaved afterwards.
wire [AXID_WITH+TAG_CNT_WITH+1:0] norm_rsp_head_index;
assign norm_rsp_head_index =
    (rspt2rspo_head == 1'b1) ?
        {rspt2rspo_axid, rspt2rspo_opc, tag_cnt[tag_name_index]} :
        {rsp_axid,       rsp_opc,       tag_cnt[tag_name_index_d]};

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rsp_axid <= #DLY 'd0;
        rsp_user <= #DLY 'd0;
        rsp_opc  <= #DLY 'd0;
        rsp_errcode <= #DLY 'd0;
        rsp_status <= #DLY OK;
    end else if(rspt2rspo_head == 1'b1 && rspt2rspo_valid == 1'b1 &&
                rspo2rspt_ready == 1'b1)begin
        rsp_axid <= #DLY rspt2rspo_axid;
        rsp_user <= #DLY rspt2rspo_auser;
        rsp_opc  <= #DLY rspt2rspo_opc;
        rsp_errcode <= #DLY rspt2rspo_errcode;
        rsp_status <= #DLY rspt2rspo_status;
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
wire [SPEC_REQ_BUFF_DEEP-1:0] follo_req_buff_index_hot;
wire [INDEX_WITH-1:0] follo_req_buff_index;
//独热码转二进制码
wire [INDEX_WITH-1 : 0] follo_req_buff_index_hot2bin_temp1 [SPEC_REQ_BUFF_DEEP-1 : 0];
wire [SPEC_REQ_BUFF_DEEP-1 : 0] follo_req_buff_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
//生成独热码
generate
    for (i = 0 ; i < SPEC_REQ_BUFF_DEEP ; i = i + 1) begin
        assign follo_req_buff_index_hot[i] =
            ({((cur_state == SPEC_RSP) ? spec_rsp_axid : rsp_axid),
              ((cur_state == SPEC_RSP) ? spec_rsp_opc  : rsp_opc)}
                 == spec_req_buffer[i][BUFF_OPC_OFFSET +: 2+AXID_WITH] &&
             spec_req_buffer[i][BUFF_TAGCNT_OFFSET +: TAG_CNT_WITH]
                 == tag_cnt[(cur_state == SPEC_RSP) ?
                            spec_rsp_tag_name_index : tag_name_index_d] &&
             spec_req_buffer[i][0] == 1'b1)
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
// reqo2rspo_rsp_len is the payload byte count minus one. Calculate all
// positions relative to the first aligned response flit so that byte lanes
// are never compared directly with a flit index.
wire [LEN_WITH:0] first_valid_lane;
wire [LEN_WITH:0] last_byte_offset;
wire [LEN_WITH:0] last_valid_lane;
wire [LEN_WITH:0] total_flit;       // Last flit index, starting from zero

assign first_valid_lane = reqo2rspo_rsp_addr & (NBYTEPERWORD-1);
assign last_byte_offset = first_valid_lane + {1'b0, reqo2rspo_rsp_len};
assign last_valid_lane  = last_byte_offset & (NBYTEPERWORD-1);
assign total_flit       = last_byte_offset >> $clog2(NBYTEPERWORD);


reg [7:0] flit_cnt;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        flit_cnt <= #DLY 'd0;
    end else if(rspo2rknp_xx_tail == 1'b1 && rknp_xx2rspo_ready == 1'b1) begin
        flit_cnt <= #DLY 'd0;
    end else if(rspo2rknp_xx_valid == 1'b1 && rknp_xx2rspo_ready == 1'b1) begin
        flit_cnt <= #DLY flit_cnt + 1'b1;
    end
end


wire [9*NBYTEPERWORD:0] spec_rsp_data;  //自组织特殊响应的body部分
//------------------------------------------------------
//   生成特殊响应be位序列
//------------------------------------------------------
reg [NBYTEPERWORD-1:0] be_temp;

always @(*) begin
    be_temp = {NBYTEPERWORD{1'b1}};

    // Mask the unused low lanes of the first flit.
    if(flit_cnt == 'd0)
        be_temp = be_temp & ({NBYTEPERWORD{1'b1}} << first_valid_lane);

    // Mask the unused high lanes of the last flit. This is a separate if so
    // that a single-flit response receives both the head and tail masks.
    if(flit_cnt == total_flit)
        be_temp = be_temp &
                  ({NBYTEPERWORD{1'b1}} >>
                   (NBYTEPERWORD - 1 - last_valid_lane));
end
//------------------------------------------------------
//   1、填充byte位
//   2、填充be位
//------------------------------------------------------
reg rspt2rspo_lw_d;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rspt2rspo_lw_d <= #DLY 1'b0;
    end else if(rspt2rspo_valid == 1'b1 && rspt2rspo_lw == 1'b1 &&
                rspo2rspt_ready == 1'b1)begin
        rspt2rspo_lw_d <= #DLY 1'b1;
    end else if(rknp_xx2rspo_ready == 1'b1) begin
        rspt2rspo_lw_d <= #DLY 1'b0;
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

assign low_byte_disable_position = (rhead_en_d == 1'b1) ? reqo2rspo_rsp_addr[$clog2(NBYTEPERWORD)-1:0] : low_byte_disable_position_d;
assign high_byte_disable_position = (rhead_en_d == 1'b1) ? reqo2rspo_rsp_addr[$clog2(NBYTEPERWORD)-1:0] + reqo2rspo_rsp_len : high_byte_disable_position_d;

// A transaction can be split into several RKNP response packets by AXI read
// interleaving. rspo2rknp_xx_head is asserted at the beginning of every such
// packet, but only the first packet carries the original OK/ERR status. A
// resumed packet carries CONT and must not apply the transaction's low-lane
// mask again.
wire norm_rsp_first_flit;
wire norm_rsp_last_flit;
reg  [NBYTEPERWORD-1:0] norm_be_temp;

assign norm_rsp_first_flit = rspo2rknp_xx_valid &&
                             rspo2rknp_xx_head &&
                             (reqo2rspo_rsp_status != CONT);
assign norm_rsp_last_flit  = rspo2rknp_xx_valid &&
                             rspt2rspo_lw_d;

// The first and last masks are deliberately two independent if statements.
// A narrow read can fit in one flit, in which case HEAD and LW are both one
// and both masks must be applied to the same BE vector.
always @(*) begin
    norm_be_temp = {NBYTEPERWORD{1'b1}};

    if(norm_rsp_first_flit)
        norm_be_temp = norm_be_temp &
                       ({NBYTEPERWORD{1'b1}} <<
                        low_byte_disable_position);

    if(norm_rsp_last_flit)
        norm_be_temp = norm_be_temp &
                       ({NBYTEPERWORD{1'b1}} >>
                        (NBYTEPERWORD - 1 -
                         high_byte_disable_position));
end

generate
    for(i=0; i<NBYTEPERWORD; i=i+1) begin
        always @(*) begin
            norm_rsp_data[i*9+1] = norm_be_temp[i];
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

reg [INDEX_WITH-1:0] buff_index_d;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) 
        buff_index_d <= #DLY 'd0;
    else 
        buff_index_d <= #DLY buff_index;
end

always @(*) begin
    if(spec_req_ready_en == 1'b1)
        buff_index = spec_req_ready_index;
    else
        buff_index = buff_index_d; //其他情况保持
end

//------------------------------------------------------
//  锁存当前特殊响应的类型、tag索引、ErrorCode与Status
//  spec_req_buffer会在rhead同拍释放，因此这些字段必须在释放前保存。
//------------------------------------------------------
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        spec_rsp_errcode <= #DLY 3'd0;
        spec_rsp_status <= #DLY 2'd0;
        spec_rsp_opc <= #DLY 2'd0;
        spec_rsp_axid <= #DLY 'd0;
        spec_rsp_tag_name_index <= #DLY 'd0;
    end else if(spec_dispatch_en == 1'b1) begin
        if(timout_fifo_rden == 1'b1) begin
            spec_rsp_errcode <= #DLY TIM_OUT;
            spec_rsp_status <= #DLY ERR;
            spec_rsp_opc <= #DLY wd2rspo_opc;
            spec_rsp_axid <= #DLY wd2rspo_axid;
            spec_rsp_tag_name_index <= #DLY wd_tag_name_index;
        end else begin
            spec_rsp_errcode <= #DLY
                spec_req_buffer[buff_index][BUFF_ERRC_OFFSET +: 3];
            spec_rsp_status <= #DLY
                spec_req_buffer[buff_index][BUFF_STAT_OFFSET +: 2];
            spec_rsp_opc <= #DLY
                spec_req_buffer[buff_index][BUFF_OPC_OFFSET +: 2];
            spec_rsp_axid <= #DLY
                spec_req_buffer[buff_index][BUFF_AXID_OFFSET +: AXID_WITH];
            spec_rsp_tag_name_index <= #DLY spec_tag_name_index;
        end
    end
end

//------------------------------------------------------
//  生成常规响应的status值
//------------------------------------------------------



// The request-side status describes the RKNP packet position: the first packet
// is OK and a packet resumed after read interleaving is CONT.  The downstream
// AXI response status describes whether the actual slave completion failed.
// For the first packet, use the AXI-derived OK/ERR value captured together with
// the response HEAD.  Preserve CONT for resumed packets so the existing RKNP
// interleaving semantics are unchanged.
wire [1:0] norm_rsp_status;
assign norm_rsp_status = (reqo2rspo_rsp_status == CONT) ?
                         CONT : rsp_status;

//------------------------------------------------------
//  RKNP协议组包输出
//------------------------------------------------------
reg rsp_phase; // 为0表示响应通道空闲
reg rsp_phase_temp; 
reg rspt2rspo_lw_d2; // 用于捕捉rspt2rspo_lw_d的下降沿
wire rspo2rknp_xx_lw_neg; // rspt2rspo_lw_d的下降沿
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rspt2rspo_lw_d2 <= #DLY 1'b0;
    end else begin
        rspt2rspo_lw_d2 <= #DLY rspt2rspo_lw_d;
    end
end

assign rspo2rknp_xx_lw_neg = (~rspt2rspo_lw_d) & rspt2rspo_lw_d2;

always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rsp_phase_temp <= #DLY 1'b0;
    end else if(rspo2rknp_xx_tail == 1'b1 &&
                rknp_xx2rspo_ready == 1'b1) begin
        rsp_phase_temp <= #DLY 1'b0;
    end else if(rspo2rknp_xx_valid == 1'b1 &&
                rknp_xx2rspo_ready == 1'b1) begin
        rsp_phase_temp <= #DLY 1'b1;
    end else if(rspt2rspo_lw_d == 1'b1) begin
        rsp_phase_temp <= #DLY 1'b0;
    end
end

always @(*) begin
    if(rspo2rknp_xx_lw_neg == 1'b1) begin
        rsp_phase = 1'b0;
    end else begin
        rsp_phase = rspo2rknp_xx_valid | rsp_phase_temp;
    end
end

// 特殊响应只能由一个无组合环的dispatch事件启动：
// 1) 普通响应通道空闲；
// 2) 当前响应尾拍握手，可以无气泡衔接下一笔特殊响应。
assign rsp_tail_hs = rspo2rknp_xx_tail &&
                     rspo2rknp_xx_valid &&
                     rknp_xx2rspo_ready;

// rsp_phase会覆盖普通多拍响应的拍间空隙，因此不能只用valid判断空闲。
assign rsp_path_idle = (cur_state == NORM_RSP) &&
                       (rsp_phase == 1'b0);
assign timeout_pending = ~timout_fifo_empty;
assign dispatch_boundary = rsp_path_idle || rsp_tail_hs;

assign spec_err_pending = spec_req_ready_en;
assign spec_dispatch_en = dispatch_boundary &&
                          (spec_err_pending || timout_fifo_rden);


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
            if(spec_dispatch_en == 1'b1)
                next_state = SPEC_RSP;
            else
                next_state = NORM_RSP;
        end
        SPEC_RSP: begin
            if(rsp_tail_hs == 1'b1 &&
               spec_dispatch_en == 1'b0)
                next_state = NORM_RSP;
            else
                next_state = SPEC_RSP;
        end
        default:
            next_state = NORM_RSP;
    endcase
end


reg buff_rsp_flag_d;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        buff_rsp_flag_d <= #DLY 1'b0;
    end else begin
        buff_rsp_flag_d <= #DLY buff_rsp_flag;
    end
end




always @(*) begin
    case(cur_state)
        NORM_RSP: begin
            if(rspo2rknp_xx_valid == 1'b1 && reqo2rspo_timout == 1'b0 && buff_rsp_flag_d == 1'b0) begin  //对常规响应，忽略超时响应与bufferable响应

                rspo2rknp_xx_data = {
                    norm_rsp_data,
                    rsp_errcode,
                    reqo2rspo_rsp_user[AUSER_WITH+8], //RKNUSER
                    rsp_user,                         //AxUSER
                    reqo2rspo_rsp_user[7:0],          //AxLOCL\AxPORT\AxCACHE
                    reqo2rspo_rsp_addr,
                    norm_rsp_status,                  // AXI OK/ERR or RKNP CONT
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
            if(rspo2rknp_xx_valid == 1'b1) begin
                rspo2rknp_xx_data = {
                    spec_rsp_data,
                    spec_rsp_errcode,
                    reqo2rspo_rsp_user,
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
    end else if(rspt2rspo_head == 1'b1 && rspt2rspo_valid == 1'b1 &&
                rspo2rspt_ready == 1'b1) begin
        rspt2rspo_head_d <= #DLY 1'b1;
    end else if(rknp_xx2rspo_ready == 1'b1) begin
        rspt2rspo_head_d <= #DLY 1'b0;
    end
end
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        rspt2rspo_tail_d <= #DLY 1'b0;
    end else if(rspt2rspo_tail == 1'b1 && rspt2rspo_valid == 1'b1 &&
                rspo2rspt_ready == 1'b1) begin
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

reg spec_rsp_phase; // 特殊响应恢复区间
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        spec_rsp_phase <= #DLY 1'b0;
    end else if(spec_dispatch_en == 1'b1) begin
        // dispatch同时完成head读取、属性锁存和自组包启动。
        spec_rsp_phase <= #DLY 1'b1;
    end else if(rsp_tail_hs == 1'b1) begin
        spec_rsp_phase <= #DLY 1'b0;
    end
end


always @(*) begin
    case(cur_state)
        NORM_RSP: begin
            // if(reqo2rspo_timout == 1'b0 && reqo2rspo_rsp_status != CONT && rsp_opc == WR) begin //若该响应为已经超时响应或early response的real response，则不传输
            if(reqo2rspo_timout == 1'b0 && buff_rsp_flag_d == 1'b0) begin //若该响应为已经超时响应或early response的real response，则不传输
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
            if(spec_rsp_phase == 1'b1) begin
                if(rspo2rknp_xx_data[RSP_OPC_OFFSET +: 2] == RD) begin
                    if(flit_cnt == 'd0) begin
                        rspo2rknp_xx_head = 1'b1;
                        rspo2rknp_xx_tail = (total_flit == 'd0);
                        rspo2rknp_xx_valid = 1'b1;
                    end else if(flit_cnt == total_flit)begin
                        rspo2rknp_xx_head = 1'b0;
                        rspo2rknp_xx_tail = 1'b1;
                        rspo2rknp_xx_valid = 1'b1;
                    end else begin
                        rspo2rknp_xx_head = 1'b0;
                        rspo2rknp_xx_tail = 1'b0;
                        rspo2rknp_xx_valid = 1'b1;
                    end
                end else begin
                    rspo2rknp_xx_head = 1'b1;
                    rspo2rknp_xx_tail = 1'b1;
                    rspo2rknp_xx_valid = 1'b1;

                end
            end else begin
                rspo2rknp_xx_head = 1'b0;
                rspo2rknp_xx_tail = 1'b0;
                rspo2rknp_xx_valid = 1'b0;
            end
        end
    endcase
end


//------------------------------------------------------
//   填充LW位
//------------------------------------------------------

//assign norm_rsp_data[0] = (flit_cnt == total_flit) ? 1'b1 : 1'b0;  //交织时这个是错的,flit_cnt只能给特殊响应用

assign norm_rsp_data[0] = (rspt2rspo_lw_d == 1'b1) ? 1'b1 : 1'b0;
assign spec_rsp_data[0] = (spec_rsp_opc == WR || flit_cnt == total_flit) ? 1'b1 : 1'b0;


//------------------------------------------------------
//  生成timout_fifo_rden
//------------------------------------------------------
always @(*) begin
    // 空闲时立即读取timeout；忙时在当前响应tail握手时衔接读取。
    if(timeout_pending == 1'b1 && dispatch_boundary == 1'b1)
        timout_fifo_rden = 1'b1;
    else
        timout_fifo_rden = 1'b0;
end

//------------------------------------------------------
//  生成rspo2reqo_timout
//------------------------------------------------------
assign rspo2reqo_timout = (timout_fifo_rden == 1'd1) ? 1'd1 : 1'd0; 

//------------------------------------------------------
//  1、rsp_order向req_order索引head信息
//  2、rsp_order提示req_order删除head信息
//  3、rsp_order提示req_order更改head addr信息
//  4、分eraly response模式和非early response模式
//------------------------------------------------------

generate
    if(EARLY_RSP_MODE == 0) begin
        always @(*) begin
            rspo2reqo_head_index = 'd0;
            rspo2reqo_rhead_en = 1'b0;
            del_head_en = 1'b0;

            if(spec_dispatch_en == 1'b1) begin
                if(timout_fifo_rden == 1'b1) begin
                    rspo2reqo_head_index = {wd2rspo_axid,wd2rspo_opc,
                                           tag_cnt[wd_tag_name_index]};
                    rspo2reqo_rhead_en = 1'b1;
                    del_head_en = 1'b0;
                end else begin
                    rspo2reqo_head_index =
                        spec_req_buffer[buff_index]
                            [BUFF_TAGCNT_OFFSET +:
                             AXID_WITH+TAG_CNT_WITH+2];
                    rspo2reqo_rhead_en = 1'b1;
                    del_head_en = 1'b1;
                end
            end else if(cur_state == NORM_RSP) begin
                rspo2reqo_head_index = norm_rsp_head_index;
                rspo2reqo_rhead_en =
                    rspt2rspo_head && rspt2rspo_valid &&
                    rspo2rspt_ready;
                del_head_en =
                    rspt2rspo_lw && rspt2rspo_valid &&
                    rspo2rspt_ready;
            end
        end
    end else begin
        always @(*) begin
            rspo2reqo_head_index = 'd0;
            rspo2reqo_rhead_en = 1'b0;
            del_head_en = 1'b0;
            a = 3'd5;

            if(spec_dispatch_en == 1'b1) begin
                if(timout_fifo_rden == 1'b1) begin
                    rspo2reqo_head_index = {wd2rspo_axid,wd2rspo_opc,
                                           tag_cnt[wd_tag_name_index]};
                    rspo2reqo_rhead_en = 1'b1;
                    del_head_en = 1'b0;
                    a = 3'd1;
                end else begin
                    rspo2reqo_head_index =
                        spec_req_buffer[buff_index]
                            [BUFF_TAGCNT_OFFSET +:
                             AXID_WITH+TAG_CNT_WITH+2];
                    rspo2reqo_rhead_en = 1'b1;
                    del_head_en =
                        (spec_req_buffer[buff_index]
                            [BUFF_STAT_OFFSET +: 2] == OK) ?
                        1'b0 : 1'b1;
                    a = 3'd3;
                end
            end else if(cur_state == NORM_RSP) begin
                if(buff_rsp_flag == 1'b0) begin
                    rspo2reqo_head_index = norm_rsp_head_index;
                    rspo2reqo_rhead_en =
                        rspt2rspo_head && rspt2rspo_valid &&
                        rspo2rspt_ready;
                    del_head_en =
                        rspt2rspo_lw && rspt2rspo_valid &&
                        rspo2rspt_ready;
                end else begin
                    rspo2reqo_head_index =
                        {rspt2rspo_axid, rspt2rspo_opc,
                         erd2rspo_tag_cnt};
                    rspo2reqo_rhead_en = 1'b0;
                    // buff_rsp_flag is already qualified by the real B
                    // handshake; its LW has intentionally been masked.
                    del_head_en = buff_rsp_flag;
                end
            end
        end
    end
endgenerate



always @(*) begin
    // This signal is an accepted AXI response-flit event, not merely a
    // level copy of the registered RKNP output valid.  req_order uses it to
    // advance the saved response address once for every physical read beat.
    if(cur_state == NORM_RSP && spec_dispatch_en == 1'b0 &&
       buff_rsp_flag == 1'b0)
        rspo2reqo_rsp_valid = rspt2rspo_valid && rspo2rspt_ready;
    else
        rspo2reqo_rsp_valid = 1'b0;
end

//------------------------------------------------------
//   生成rspo2rspt_ready信号
//------------------------------------------------------
always @(*) begin
    if(cur_state == SPEC_RSP || spec_dispatch_en == 1'b1)
        rspo2rspt_ready = 1'b0;
    else
        rspo2rspt_ready = rknp_xx2rspo_ready;
end


//------------------------------------------------------
//  停止watchdog计时
//------------------------------------------------------

always @(*) begin

    if(((rspt2rspo_head == 1'b1 && rspt2rspo_valid == 1'b1) ||
        buff_rsp_flag == 1'b1) &&
       rspo2rspt_ready == 1'b1) begin
        rspo2wd_timoff_en = 1'b1;
        rspo2wd_axid = rspt2rspo_axid;
        rspo2wd_opc = rspt2rspo_opc;
        // ely_rsp_detect saved the original tag for a filtered bufferable B.
        // The live tag counter has already advanced with the early response.
        rspo2wd_tag_cnt = buff_rsp_flag
                        ? erd2rspo_tag_cnt
                        : tag_cnt[tag_name_index];
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
