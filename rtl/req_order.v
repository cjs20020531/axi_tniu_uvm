//=============================================================================
// Copyright(c) 2011, Rockchips Electronics Co, Ltd
// Filename          : req_order.v
// Auther            : cjs
// Email             : 
// Created On        : 2025-07-28
// Abstract          : 需要缓存req packet中的head信息，并在组织rsp packet时提供对应的head缓存信息。
// Parameter         :
// Modified History  :
//=============================================================================

module req_order#(

     parameter REQ_FLIT_WITH = 177
    ,parameter URGE_WITH = 7
    ,parameter IID_WITH = 10
    ,parameter TID_WITH = 10
    ,parameter SUBR_WITH = 8
    ,parameter ADDR_WITH = 32
    ,parameter AXID_WITH = 4
    ,parameter ORDKEY_WITH = 8 
    ,parameter LEN_WITH = 8 
    ,parameter USER_WITH = 10
    ,parameter NBYTEPERWORD = 8
    ,parameter TAG_CNT_WITH = 3

    ,parameter REQ_IID_OFFSET = 7
    ,parameter REQ_TID_OFFSET = 10
    ,parameter REQ_SUBR_OFFSET = 27
    ,parameter REQ_ORDKEY_OFFSET = 35 
    ,parameter REQ_OPC_OFFSET = 43
    ,parameter REQ_STATUS_OFFSET = 47
    ,parameter REQ_LEN_OFFSET = 49 
    ,parameter REQ_ADDR_OFFSET = 57
    ,parameter REQ_USER_OFFSET = 89
    ,parameter REQ_ERRC_OFFSET = 99
    ,parameter REQ_HEAD_LEN_OFFSET = 104

    ,parameter HEAD_BUFF_DEEP = 8

    ,parameter ADDR_BLOCK_SIZE = 64
    ,parameter ADDR_BP_TYPE = 1  // 0:无同地址反压  1:写后读/写后写同地址反压   2:写后读/写后写/读后写同地址反压
    ,parameter EARLY_RSP_MODE = 0 // 0：关闭early response模式    1：开启early response模式
    ,parameter DLY = 1

)(
     input                              clk
    ,input                              resetn

    // The interface signals of rknp_xx/wrap_align
    ,input                              rknp_xx2reqo_head
    ,input                              rknp_xx2reqo_tail
    ,input                              rknp_xx2reqo_valid
    ,input       [REQ_FLIT_WITH-1:0]    rknp_xx2reqo_data
    ,output reg                         reqo2rknp_xx_ready

    // The interface signals of req channel of rsp_order 
    ,output reg                         reqo2rspo_head
    ,output reg                         reqo2rspo_tail
    ,output reg                         reqo2rspo_valid
    ,input                              rspo2reqo_ready
    ,output reg  [URGE_WITH-1:0]        reqo2rspo_urg   
    ,output reg  [SUBR_WITH-1:0]        reqo2rspo_subr 
    ,output reg  [ADDR_WITH-1:0]        reqo2rspo_addr
    ,output reg  [AXID_WITH-1:0]        reqo2rspo_axid
    ,output reg  [3:0]                  reqo2rspo_opc
    ,output reg  [2:0]                  reqo2rspo_errcode
    ,output reg  [1:0]                  reqo2rspo_status
    ,output reg  [LEN_WITH-1:0]         reqo2rspo_len   
    ,output reg  [USER_WITH-1:0]        reqo2rspo_user
    ,output reg  [NBYTEPERWORD*9:0]     reqo2rspo_data
    ,output reg  [TAG_CNT_WITH-1:0]     reqo2rspo_tag_cnt
    ,output reg                         fir_req_flag

    ,output wire [HEAD_BUFF_DEEP*(AXID_WITH+3)-1:0] reqo2rspo_tag_name  //将一维数组输出

    // The interface signals of wrap_align
    ,input       [7:0]                  wa2reqo_offset_addr

    // The interface signals of rsp channel of rsp_order 
    ,output reg  [URGE_WITH-1:0]        reqo2rspo_rsp_urg   
    ,output reg  [ADDR_WITH-1:0]        reqo2rspo_rsp_addr
    ,output reg  [ORDKEY_WITH-1:0]      reqo2rspo_rsp_ordkey
    ,output reg  [LEN_WITH-1:0]         reqo2rspo_rsp_len   
    ,output reg  [USER_WITH-1:0]        reqo2rspo_rsp_user
    ,output reg  [IID_WITH-1:0]         reqo2rspo_rsp_iid
    ,output reg  [TID_WITH-1:0]         reqo2rspo_rsp_tid
    ,output reg  [1:0]                  reqo2rspo_rsp_status
    ,output reg  [7:0]                  reqo2rspo_rsp_offset_addr    // useless
    ,input       [AXID_WITH+TAG_CNT_WITH+1: 0] rspo2reqo_head_index
    ,input                              rspo2reqo_rhead_en
    ,input                              rspo2reqo_rsp_valid
    ,input                              del_head_en
    ,input                              rspo2reqo_timout
    ,output reg                         reqo2rspo_timout

    // The interface signals of watchdog
    ,output reg  [AXID_WITH-1:0]        reqo2wd_axid
    ,output reg  [1:0]                  reqo2wd_opc
    ,output reg  [TAG_CNT_WITH-1:0]     reqo2wd_tag_cnt
    ,output reg                         reqo2wd_timon_en
    ,output wire                        timer_interrupt
    ,output wire [HEAD_BUFF_DEEP*(AXID_WITH+2+TAG_CNT_WITH)-1:0] reqo2wd_timout_table


);

parameter RD  = 4'b0000;
parameter RDW = 4'b0001;
parameter WR  = 4'b0100;
parameter WRW = 4'b0101;

parameter OK   = 2'b00;
parameter ERR  = 2'b01;
parameter CONT = 2'b10;

localparam AXID_FOLED_NUM = ORDKEY_WITH / AXID_WITH; // orderkey映射AXI ID时的折叠数


//------------------------------------------------------
// 分离req head的各个域段
//------------------------------------------------------
wire [URGE_WITH-1:0]        urg     ;
wire [SUBR_WITH-1:0]        subr    ;
wire [IID_WITH-1:0]         iid     ;
wire [TID_WITH-1:0]         tid     ;
wire [ADDR_WITH-1:0]        addr    ;
wire [ORDKEY_WITH-1:0]      ordkey  ;
wire [3:0]                  opc     ;
wire [1:0]                  status  ;
wire [LEN_WITH-1:0]         len     ;   
wire [2:0]                  errcode ;  
wire [USER_WITH-1:0]        user    ;

assign urg      = rknp_xx2reqo_data[URGE_WITH-1:0];
assign subr     = rknp_xx2reqo_data[REQ_SUBR_OFFSET +: SUBR_WITH];
assign iid      = rknp_xx2reqo_data[REQ_IID_OFFSET +: IID_WITH];
assign tid      = rknp_xx2reqo_data[REQ_TID_OFFSET +: TID_WITH];
assign addr     = rknp_xx2reqo_data[REQ_ADDR_OFFSET +: ADDR_WITH];
assign ordkey   = rknp_xx2reqo_data[REQ_ORDKEY_OFFSET +: ORDKEY_WITH];
assign opc      = rknp_xx2reqo_data[REQ_OPC_OFFSET +: 4];
assign status   = rknp_xx2reqo_data[REQ_STATUS_OFFSET +: 2];
assign len      = rknp_xx2reqo_data[REQ_LEN_OFFSET +: LEN_WITH];
assign errcode  = rknp_xx2reqo_data[REQ_ERRC_OFFSET +: 3];
assign user     = rknp_xx2reqo_data[REQ_USER_OFFSET +: USER_WITH];

//----------------------------------------------------------------------------------
// orderkey映射AXI ID
//----------------------------------------------------------------------------------
wire [AXID_WITH-1:0]        axid    ; //AXI ID,由orderkey映射获得

generate
    if(ORDKEY_WITH <= AXID_WITH) begin
        assign axid = ordkey;
    end else if(ORDKEY_WITH > AXID_WITH && ORDKEY_WITH <= 2*AXID_WITH) begin
        localparam ORDKEY2AXID_WITH_DIF = ORDKEY_WITH - AXID_WITH;
        // 取高位部分并补零扩展至AXID_WITH位宽
        assign axid = ordkey[AXID_WITH-1:0] ^ {{(AXID_WITH - ORDKEY2AXID_WITH_DIF){1'b0}}, ordkey[AXID_WITH +: ORDKEY2AXID_WITH_DIF]};
    end else if(ORDKEY_WITH > 2*AXID_WITH && ORDKEY_WITH <= 3*AXID_WITH) begin
        localparam ORDKEY2AXID_WITH_DIF = ORDKEY_WITH - 2*AXID_WITH;
        wire [AXID_WITH-1:0] axid_d;
        assign axid_d = ordkey[AXID_WITH-1:0] ^ ordkey[AXID_WITH +: AXID_WITH];
        assign axid = axid_d ^ {{(AXID_WITH - ORDKEY2AXID_WITH_DIF){1'b0}}, ordkey[2*AXID_WITH +: ORDKEY2AXID_WITH_DIF]};
    end else begin
        assign axid = ordkey[AXID_WITH-1:0];
    end
endgenerate







//----------------------------------------------------------------------------------
// req channel - head output
//----------------------------------------------------------------------------------
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) begin
        reqo2rspo_urg <= #DLY 'd0;
        reqo2rspo_subr <= #DLY 'd0;
        reqo2rspo_addr <= #DLY 'd0;
        reqo2rspo_axid <= #DLY 'd0;
        reqo2rspo_opc <= #DLY 'd0;
        reqo2rspo_len <= #DLY 'd0;
        reqo2rspo_errcode <= #DLY 'd0;
        reqo2rspo_status <= #DLY 'd0;
        reqo2rspo_user <= #DLY 'd0;
    end else if (rknp_xx2reqo_head == 1'b1 && reqo2rknp_xx_ready == 1'b1) begin
        reqo2rspo_urg <= #DLY urg;
        reqo2rspo_subr <= #DLY subr;
        reqo2rspo_addr <= #DLY addr;
        reqo2rspo_axid <= #DLY axid;
        reqo2rspo_opc <= #DLY opc;
        reqo2rspo_len <= #DLY len;
        reqo2rspo_errcode <= #DLY errcode;
        reqo2rspo_status <= #DLY status;
        reqo2rspo_user <= #DLY user;
    end
end
//----------------------------------------------------------------------------------
// 生成head有效信号
//----------------------------------------------------------------------------------
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) 
        reqo2rspo_head <= #DLY 1'b0;
    else if (rknp_xx2reqo_head == 1'b1 && reqo2rknp_xx_ready == 1'b1) 
        reqo2rspo_head <= #DLY 1'b1;
    else if(rspo2reqo_ready == 1'b1)
        reqo2rspo_head <= #DLY 1'b0;
end
//----------------------------------------------------------------------------------
// 生成tail有效信号
//----------------------------------------------------------------------------------
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0)
        reqo2rspo_tail <= #DLY 1'b0;
    else if (rknp_xx2reqo_tail == 1'b1 && reqo2rknp_xx_ready == 1'b1)
        reqo2rspo_tail <= #DLY 1'b1;
    else if(rspo2reqo_ready == 1'b1)
        reqo2rspo_tail <= #DLY 1'b0;
end

//----------------------------------------------------------------------------------
// req channel - body output
//----------------------------------------------------------------------------------
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) begin
        reqo2rspo_valid <= #DLY 1'b0;
    end else if (rknp_xx2reqo_valid == 1'b1 && reqo2rknp_xx_ready == 1'b1) begin
        reqo2rspo_valid <= #DLY rknp_xx2reqo_valid; 
    end else if (rspo2reqo_ready == 1'b1) begin
        reqo2rspo_valid <= #DLY 1'b0;
    end
end

always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) begin
        reqo2rspo_data <= #DLY 'd0;
    end else if (rknp_xx2reqo_valid == 1'b1 && reqo2rknp_xx_ready == 1'b1) begin
        reqo2rspo_data <= #DLY rknp_xx2reqo_data[REQ_HEAD_LEN_OFFSET +: 9*NBYTEPERWORD+1];
    end
end

genvar  i;
genvar  j;
//2:opc[3:2], 1:used
localparam TAG_NAME_WITH = AXID_WITH + 2 + 1;

reg [TAG_CNT_WITH-1:0] tag_cnt [HEAD_BUFF_DEEP-1:0]; // tag计数器,最大计数值为buffer深度值，单元个数为buffer深度值
reg [TAG_NAME_WITH-1:0] tag_name[HEAD_BUFF_DEEP-1:0]; // tag名称,单元个数为buffer深度值



//----------------------------------------------------------------------------------
//  生成tag_name_index值
//----------------------------------------------------------------------------------
localparam INDEX_WITH = $clog2(HEAD_BUFF_DEEP); //二进制索引值的位宽
wire [HEAD_BUFF_DEEP-1:0] tag_name_index_hot;
wire [INDEX_WITH-1:0] tag_name_index;
//独热码转二进制码
wire [INDEX_WITH-1 : 0] tag_name_index_hot2bin_temp1 [HEAD_BUFF_DEEP-1 : 0];
wire [HEAD_BUFF_DEEP-1 : 0] tag_name_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
//生成独热码
generate 
    for (i = 0 ; i < HEAD_BUFF_DEEP ; i = i + 1) begin 
        assign tag_name_index_hot[i] = {axid , opc[3:2] , 1'b1} == tag_name[i] ? 1'b1 : 1'b0;
    end
endgenerate
//独热码转二进制码
generate
	for(i = 0; i < HEAD_BUFF_DEEP; i = i+1)begin 
		assign tag_name_index_hot2bin_temp1[i] = tag_name_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < HEAD_BUFF_DEEP; i = i+1)begin 
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

//----------------------------------------------------------------------------------
//  生成idle_tag_name_index值
//----------------------------------------------------------------------------------
wire [HEAD_BUFF_DEEP-1:0] tag_name_used; //生成idle_tag_name_index_hot的中间变量
wire [HEAD_BUFF_DEEP-1:0] idle_tag_name_index_hot;
wire [INDEX_WITH-1:0] idle_tag_name_index;
//索引tag_name为idle的单元
generate 
    for (i = 0 ; i < HEAD_BUFF_DEEP ; i = i + 1) begin 
        assign tag_name_used[i] = ~tag_name[i][0];
    end
endgenerate
//保留二进制最低位1操作-生成独热码
assign idle_tag_name_index_hot = tag_name_used & (~tag_name_used+1);
//独热码转二进制码
wire [INDEX_WITH-1 : 0] idle_tag_name_index_hot2bin_temp1 [HEAD_BUFF_DEEP-1 : 0]; 
wire [HEAD_BUFF_DEEP-1 : 0] idle_tag_name_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
generate
	for(i = 0; i < HEAD_BUFF_DEEP; i = i+1)begin 
		assign idle_tag_name_index_hot2bin_temp1[i] = idle_tag_name_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < HEAD_BUFF_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign idle_tag_name_index_hot2bin_temp2[j][i] = idle_tag_name_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign idle_tag_name_index[j] = |idle_tag_name_index_hot2bin_temp2[j];
	end
endgenerate


//----------------------------------------------------------------------------------
//  生成del_tag_name_index值
//----------------------------------------------------------------------------------
wire [HEAD_BUFF_DEEP-1:0] del_tag_name_index_hot;
wire [INDEX_WITH-1:0] del_tag_name_index;
//独热码转二进制码
wire [INDEX_WITH-1 : 0] del_tag_name_index_hot2bin_temp1 [HEAD_BUFF_DEEP-1 : 0];
wire [HEAD_BUFF_DEEP-1 : 0] del_tag_name_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
//生成独热码
generate 
    for (i = 0 ; i < HEAD_BUFF_DEEP ; i = i + 1) begin 
        assign del_tag_name_index_hot[i] = 
            ({rspo2reqo_head_index[TAG_CNT_WITH +: AXID_WITH+2] , 1'b1} == tag_name[i][0 +: AXID_WITH+3] )
            ? 1'b1 : 1'b0;
    end
endgenerate
//独热码转二进制码
generate
	for(i = 0; i < HEAD_BUFF_DEEP; i = i+1)begin 
		assign del_tag_name_index_hot2bin_temp1[i] = del_tag_name_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < HEAD_BUFF_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign del_tag_name_index_hot2bin_temp2[j][i] = del_tag_name_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign del_tag_name_index[j] = |del_tag_name_index_hot2bin_temp2[j];
	end
endgenerate



//----------------------------------------------------------------------------------
//  tag_cnt自增操作
//----------------------------------------------------------------------------------
integer a;
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) begin
        for (a = 0; a < HEAD_BUFF_DEEP; a = a + 1)
            tag_cnt[a] <= #DLY 'd0;
    end else if(rknp_xx2reqo_head == 1'b1 && reqo2rknp_xx_ready == 1'b1) begin
        if (tag_name_index_hot == 'd0)              //没有找到对应的tag_name
            if(tag_cnt[idle_tag_name_index] < HEAD_BUFF_DEEP)
                tag_cnt[idle_tag_name_index] <= #DLY tag_cnt[idle_tag_name_index] + 1;
            else
                tag_cnt[idle_tag_name_index] <= #DLY 'd0; 
        else                                        //找到对应的tag_name
            if(tag_cnt[tag_name_index] < HEAD_BUFF_DEEP)
                tag_cnt[tag_name_index] <= #DLY tag_cnt[tag_name_index] + 1;
            else
                tag_cnt[tag_name_index] <= #DLY 'd0; 
    end
        
end



reg [INDEX_WITH-1:0] idle_tag_name_index_d; //idle_tag_name_index打一拍，由于新的请求分配tag_name后idle_tag_name_index会立即变化，所以需要保持一拍才能用于索引
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0)
        idle_tag_name_index_d <= #DLY 'd0;
    else
        idle_tag_name_index_d <= #DLY idle_tag_name_index;
end

wire [TAG_CNT_WITH-1:0] tag_cnt2buffer;  //tag_cnt存入buffer的中间变量
//如果没有找到对应的tag_name，则使用idle_tag_name_index的tag_cnt值，否则使用tag_name_index的tag_cnt值
assign tag_cnt2buffer = (tag_name_index_hot == 'd0) ? tag_cnt[idle_tag_name_index] : tag_cnt[tag_name_index]; 

wire [INDEX_WITH-1:0] tag_cnt2rspo; //输出给下游的tag_cnt
assign tag_cnt2rspo = (tag_name_index_hot == 'd0) ? tag_cnt[idle_tag_name_index] : tag_cnt[tag_name_index]; 
//----------------------------------------------------------------------------------
//  1、tag_name赋值操作
//  2、tag_name删除操作
//----------------------------------------------------------------------------------

//-----------------
wire req_head_hs;
wire keep_tag_for_same_type;

assign req_head_hs = rknp_xx2reqo_head && reqo2rknp_xx_ready;

assign keep_tag_for_same_type = req_head_hs && (tag_name_index_hot != '0) && (tag_name_index_hot == del_tag_name_index_hot);
//================

wire uniq_type_flag; //rsp_order检索head条目类型是否唯一标志位，唯一则拉高
integer b;
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        for (b = 0; b < HEAD_BUFF_DEEP; b++)
            tag_name[b] <= #DLY '0;
    end
    else begin
        if (req_head_hs) begin
            if (tag_name_index_hot == '0)
                tag_name[idle_tag_name_index] <= #DLY {axid, opc[3:2], 1'b1};
        end

        if (del_head_en && uniq_type_flag && !keep_tag_for_same_type)
            tag_name[del_tag_name_index][0] <= #DLY 1'b0;
    end
end

//----------------------------------------------------------------------------------
//  tag_name输出
//----------------------------------------------------------------------------------
generate
    for(i=0; i<HEAD_BUFF_DEEP; i=i+1) begin
        assign reqo2rspo_tag_name[(i+1)*(AXID_WITH+3)-1:i*(AXID_WITH+3)] = tag_name[i];
    end
endgenerate

// 2:status, 8:offset_addr, 4:opc, 1:used, 1:timout
localparam HEAD_BUFF_WITH = URGE_WITH + IID_WITH + TID_WITH + ADDR_WITH + AXID_WITH + LEN_WITH + USER_WITH + TAG_CNT_WITH + ORDKEY_WITH + 2 + 8 + 4 + 1 + 1;
reg [HEAD_BUFF_WITH-1:0] head_buffer [HEAD_BUFF_DEEP-1:0];
//----------------------------------------------------------------------------------
//  buffer空闲单元索引操作
//----------------------------------------------------------------------------------
wire [HEAD_BUFF_DEEP-1:0] head_buffer_used; //生成idle_head_buffer_index_hot的中间变量,被使用了则为0，没使用则为1,与buffer中的used位相反
wire [HEAD_BUFF_DEEP-1:0] idle_head_buff_index_hot;
wire [INDEX_WITH-1:0] idle_head_buff_index_hot2bin_temp1 [HEAD_BUFF_DEEP-1 : 0]; 
wire [HEAD_BUFF_DEEP-1:0] idle_head_buff_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
wire [INDEX_WITH-1:0] idle_head_buff_index;
//索引buffer为idle的单元
generate 
    for (i = 0 ; i < HEAD_BUFF_DEEP ; i = i + 1) begin 
        assign head_buffer_used[i] = ~head_buffer[i][0];
    end
endgenerate
//保留二进制最低位1操作-生成独热码
assign idle_head_buff_index_hot = head_buffer_used & (~head_buffer_used+1);
//独热码转二进制码
generate
	for(i = 0; i < HEAD_BUFF_DEEP; i = i+1)begin 
		assign idle_head_buff_index_hot2bin_temp1[i] = idle_head_buff_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < HEAD_BUFF_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign idle_head_buff_index_hot2bin_temp2[j][i] = idle_head_buff_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign idle_head_buff_index[j] = |idle_head_buff_index_hot2bin_temp2[j];
	end
endgenerate


//----------------------------------------------------------------------------------
//  buffer条目索引操作
//----------------------------------------------------------------------------------
wire [HEAD_BUFF_DEEP-1:0] rsp_head_buff_index_hot;
wire [INDEX_WITH-1:0] rsp_head_buff_index;
//独热码转二进制码
wire [INDEX_WITH-1 : 0] rsp_head_buff_index_hot2bin_temp1 [HEAD_BUFF_DEEP-1 : 0];
wire [HEAD_BUFF_DEEP-1 : 0] rsp_head_buff_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
//生成独热码
generate 
    for (i = 0 ; i < HEAD_BUFF_DEEP ; i = i + 1) begin 
        assign rsp_head_buff_index_hot[i] = ({rspo2reqo_head_index , 1'b1} == head_buffer[i][0 +: AXID_WITH+TAG_CNT_WITH+3]) ? 1'b1 : 1'b0;
    end
endgenerate
//独热码转二进制码
generate
	for(i = 0; i < HEAD_BUFF_DEEP; i = i+1)begin 
		assign rsp_head_buff_index_hot2bin_temp1[i] = rsp_head_buff_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < HEAD_BUFF_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign rsp_head_buff_index_hot2bin_temp2[j][i] = rsp_head_buff_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign rsp_head_buff_index[j] = |rsp_head_buff_index_hot2bin_temp2[j];
	end
endgenerate







//----------------------------------------------------------------------------------
//  1、buffer写入操作
//  2、buffer更新status操作 
//  3、buffer更新addr操作
//  4、buffer删除操作
//----------------------------------------------------------------------------------

//head line buffer的各个域段的偏移量参数
localparam BUFF_TAGCNT_OFFSET = 1;
localparam BUFF_OPC_OFFSET = BUFF_TAGCNT_OFFSET + TAG_CNT_WITH;
localparam BUFF_AXID_OFFSET = BUFF_OPC_OFFSET + 2;  //opc[3:2]
localparam BUFF_BURST_OFFSET = BUFF_AXID_OFFSET + AXID_WITH;  
localparam BUFF_TIMOUT_OFFSET = BUFF_BURST_OFFSET + 2; //opc[1:0]
localparam BUFF_LEN_OFFSET = BUFF_TIMOUT_OFFSET + 1;
localparam BUFF_OFFADDR_OFFSET = BUFF_LEN_OFFSET + LEN_WITH;
localparam BUFF_STAT_OFFSET = BUFF_OFFADDR_OFFSET + 8;
localparam BUFF_USER_OFFSET = BUFF_STAT_OFFSET + 2;
localparam BUFF_ADDR_OFFSET = BUFF_USER_OFFSET + USER_WITH;
localparam BUFF_ORDKEY_OFFSET = BUFF_ADDR_OFFSET + ADDR_WITH;
localparam BUFF_TID_OFFSET = BUFF_ORDKEY_OFFSET + ORDKEY_WITH;
localparam BUFF_IID_OFFSET = BUFF_TID_OFFSET + TID_WITH;
localparam BUFF_URGE_OFFSET = BUFF_IID_OFFSET + IID_WITH;



//----------------------------------------------------------------------------------
//  计算响应地址边界
//----------------------------------------------------------------------------------
wire [ADDR_WITH-1:0] rsp_addr_begin;
wire [ADDR_WITH-1:0] rsp_addr_end;

addr_border_cout#(
     .ADDR_WITH      (ADDR_WITH     )
    ,.LEN_WITH       (LEN_WITH      )
    ,.NBYTEPERWORD   (NBYTEPERWORD  )
    ,.ADDR_BLOCK_SIZE(1             ) //1byte为一个地址块
    ,.COUNT_MODE     (1             ) //表示计算的是对齐地址边界
)U_ADDR_BORDER_COUNT_RSP(
     .burst          (head_buffer[rsp_head_buff_index][BUFF_BURST_OFFSET +: 2]          )   
    ,.addr           (head_buffer[rsp_head_buff_index][BUFF_ADDR_OFFSET +: ADDR_WITH]   )   
    ,.len            (head_buffer[rsp_head_buff_index][BUFF_LEN_OFFSET +: LEN_WITH]     )  
    ,.addr_begin     (rsp_addr_begin                                                    )  
    ,.addr_end       (rsp_addr_end                                                      ) 
);



reg [INDEX_WITH-1:0] idle_head_buff_index_d; //idle_head_buff_index_d打一拍
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) 
        idle_head_buff_index_d <= #DLY 1'b0;
    else
        idle_head_buff_index_d <= #DLY idle_head_buff_index;
end

wire [$clog2(NBYTEPERWORD)-1:0] addr_s2addr_begin_diff;
wire [$clog2(NBYTEPERWORD)-1:0] addr_s2addr_end_diff;

assign addr_s2addr_begin_diff = head_buffer[rsp_head_buff_index][BUFF_ADDR_OFFSET +: $clog2(NBYTEPERWORD)] - rsp_addr_begin[$clog2(NBYTEPERWORD)-1:0];
assign addr_s2addr_end_diff = rsp_addr_end[$clog2(NBYTEPERWORD)-1:0] - head_buffer[rsp_head_buff_index][BUFF_ADDR_OFFSET +: $clog2(NBYTEPERWORD)];

integer c;
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) 
        for (c=0 ; c<HEAD_BUFF_DEEP ; c=c+1)
            head_buffer[c] <= #DLY 'd0;
    else begin
        if(del_head_en == 1'b1)          //删除操作
            head_buffer[rsp_head_buff_index][0] <= #DLY 1'b0; //将rsp_head_buff_index的used位清0

        if(rspo2reqo_rhead_en == 1'b1) begin   //更新status/addr/len
            head_buffer[rsp_head_buff_index][BUFF_STAT_OFFSET +: 2] <= #DLY CONT; 
            if(rspo2reqo_timout == 1'b1) begin
                head_buffer[rsp_head_buff_index][BUFF_TIMOUT_OFFSET] <= #DLY 1'b1; 
            end
            if(head_buffer[rsp_head_buff_index][BUFF_BURST_OFFSET +: 2] == 2'b00) begin  //INCR类型
                if(addr_s2addr_begin_diff != 'd0) begin// 如果地址非对齐
                    head_buffer[rsp_head_buff_index][BUFF_ADDR_OFFSET +: ADDR_WITH] 
                                                <= #DLY head_buffer[rsp_head_buff_index][BUFF_ADDR_OFFSET +: ADDR_WITH] + addr_s2addr_end_diff;
                    head_buffer[rsp_head_buff_index][BUFF_LEN_OFFSET +: 8] <= #DLY head_buffer[rsp_head_buff_index][BUFF_LEN_OFFSET +: 8] - addr_s2addr_end_diff;
                end else begin
                    head_buffer[rsp_head_buff_index][BUFF_ADDR_OFFSET +: ADDR_WITH] <= #DLY head_buffer[rsp_head_buff_index][BUFF_ADDR_OFFSET +: ADDR_WITH] + NBYTEPERWORD;
                    head_buffer[rsp_head_buff_index][BUFF_LEN_OFFSET +: 8] <= #DLY head_buffer[rsp_head_buff_index][BUFF_LEN_OFFSET +: 8] - NBYTEPERWORD;
                end
            end
            else begin   //WRAP类型
                if(head_buffer[rsp_head_buff_index][BUFF_ADDR_OFFSET +: ADDR_WITH] == rsp_addr_end)
                    head_buffer[rsp_head_buff_index][BUFF_ADDR_OFFSET +: ADDR_WITH] <= #DLY rsp_addr_begin;
                else
                    head_buffer[rsp_head_buff_index][BUFF_ADDR_OFFSET +: ADDR_WITH] <= #DLY head_buffer[rsp_head_buff_index][BUFF_ADDR_OFFSET +: ADDR_WITH] + NBYTEPERWORD;
            end
        end
        if(rknp_xx2reqo_head == 1'b1 && reqo2rknp_xx_ready == 1'b1)
            head_buffer[idle_head_buff_index] <= #DLY {
                urg, 
                iid, 
                tid, 
                ordkey,
                addr, 
                user, 
                status,
                wa2reqo_offset_addr,
                len,
                1'b0,
                opc[1:0],
                axid, 
                opc[3:2],
                tag_cnt2buffer,  
                1'b1 //used
            };
    end
end


//----------------------------------------------------------------------------------
//  检索buffer条目是否唯一操作
//----------------------------------------------------------------------------------
wire [HEAD_BUFF_DEEP-1:0] uniq_head_buff_index_hot;

//生成检索码
generate 
    for (i = 0 ; i < HEAD_BUFF_DEEP ; i = i + 1) begin 
        assign uniq_head_buff_index_hot[i] = 
            ((rspo2reqo_head_index[TAG_CNT_WITH +: AXID_WITH+2] == head_buffer[i][BUFF_OPC_OFFSET +: AXID_WITH+2]) 
            && head_buffer[i][0] == 1'b1) 
            ? 1'b1 : 1'b0;
    end
endgenerate

assign uniq_type_flag = (uniq_head_buff_index_hot == rsp_head_buff_index_hot) ? 1'b1 : 1'b0;

//----------------------------------------------------------------------------------
//  buffer读取操作
//----------------------------------------------------------------------------------

always @(posedge clk or negedge resetn) begin    
    if(resetn == 1'b0) begin
        reqo2rspo_rsp_urg <= #DLY 'd0;
        reqo2rspo_rsp_addr <= #DLY 'd0;
        reqo2rspo_rsp_ordkey <= #DLY 'd0;
        reqo2rspo_rsp_len <= #DLY 'd0;
        reqo2rspo_rsp_user <= #DLY 'd0;
        reqo2rspo_rsp_iid <= #DLY 'd0;
        reqo2rspo_rsp_tid <= #DLY 'd0;
        reqo2rspo_rsp_status <= #DLY 'd0;
        reqo2rspo_rsp_offset_addr <= #DLY 8'd0;
        reqo2rspo_timout <= #DLY 1'b0;
    end else if(rspo2reqo_rhead_en == 1'b1) begin
        reqo2rspo_rsp_urg         <= #DLY head_buffer[rsp_head_buff_index][BUFF_URGE_OFFSET +: URGE_WITH];
        reqo2rspo_rsp_addr        <= #DLY head_buffer[rsp_head_buff_index][BUFF_ADDR_OFFSET +: ADDR_WITH];
        reqo2rspo_rsp_ordkey      <= #DLY head_buffer[rsp_head_buff_index][BUFF_ORDKEY_OFFSET +: ORDKEY_WITH];
        reqo2rspo_rsp_len         <= #DLY head_buffer[rsp_head_buff_index][BUFF_LEN_OFFSET +: LEN_WITH];
        reqo2rspo_rsp_user        <= #DLY head_buffer[rsp_head_buff_index][BUFF_USER_OFFSET +: USER_WITH];
        reqo2rspo_rsp_iid         <= #DLY head_buffer[rsp_head_buff_index][BUFF_IID_OFFSET +: IID_WITH];
        reqo2rspo_rsp_tid         <= #DLY head_buffer[rsp_head_buff_index][BUFF_TID_OFFSET +: TID_WITH];
        reqo2rspo_rsp_status      <= #DLY head_buffer[rsp_head_buff_index][BUFF_STAT_OFFSET +: 2];
        reqo2rspo_rsp_offset_addr <= #DLY head_buffer[rsp_head_buff_index][BUFF_OFFADDR_OFFSET +: 8];
        reqo2rspo_timout          <= #DLY head_buffer[rsp_head_buff_index][BUFF_TIMOUT_OFFSET];
    end
end

//----------------------------------------------------------------------------------
//  生成fir_req_flag信号-检测当前请求是否为该类型的第一笔请求，用于后续ERR REQ保序
//----------------------------------------------------------------------------------
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) 
        fir_req_flag <= #DLY 1'b0;
    else if(rknp_xx2reqo_head == 1'b1 && reqo2rknp_xx_ready == 1'b1) begin
        if(tag_name_index_hot == 'd0) //没有找到对应的tag_name,说明当前buffer中无该类型的请求
            fir_req_flag <= #DLY 1'b1;
        else if(del_head_en == 1'b1 && uniq_type_flag == 1'b1 && tag_name_index == del_tag_name_index) 
            fir_req_flag <= #DLY 1'b1;  //删除bvuffer中唯一一笔该类型请求的同时接收一笔该类型请求，也视为第一笔请求
        else
            fir_req_flag <= #DLY 1'b0;
    end else if(rspo2reqo_ready == 1'b1) begin
        fir_req_flag <= #DLY 1'b0; 
    end
end

//----------------------------------------------------------------------------------
//  生成reqo2rsp_tag_cnt信号-将tag_cnt传递给下游，用于后续ERR REQ保序
//----------------------------------------------------------------------------------
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) 
        reqo2rspo_tag_cnt <= #DLY 1'b0;
    else if(rknp_xx2reqo_head == 1'b1 && reqo2rknp_xx_ready == 1'b1)
        reqo2rspo_tag_cnt <= #DLY tag_cnt2buffer;
end


//----------------------------------------------------------------------------------
//  计算请求地址边界
//----------------------------------------------------------------------------------
wire [ADDR_WITH-$clog2(ADDR_BLOCK_SIZE)-1:0] req_addr_begin;
wire [ADDR_WITH-$clog2(ADDR_BLOCK_SIZE)-1:0] req_addr_end;
generate 
    if(ADDR_BP_TYPE == 0) begin
       
    end else begin
        addr_border_cout#(
             .ADDR_WITH      (ADDR_WITH     )
            ,.LEN_WITH       (LEN_WITH      )
            ,.NBYTEPERWORD   (NBYTEPERWORD  )
            ,.ADDR_BLOCK_SIZE(ADDR_BLOCK_SIZE   )
            ,.COUNT_MODE     (0                 ) //表示计算的是原始地址边界
        )U_ADDR_BORDER_COUNT_REQ(
             .burst          (opc[1:0]          )   
            ,.addr           (addr              )   
            ,.len            (len               )  
            ,.addr_begin     (req_addr_begin    )  
            ,.addr_end       (req_addr_end      ) 
        );
    end

endgenerate
//----------------------------------------------------------------------------------
//  请求地址边界存储功能
//----------------------------------------------------------------------------------
reg [ADDR_WITH-$clog2(ADDR_BLOCK_SIZE)-1:0] addr_begin_buffer [HEAD_BUFF_DEEP-1:0];
reg [ADDR_WITH-$clog2(ADDR_BLOCK_SIZE)-1:0] addr_end_buffer [HEAD_BUFF_DEEP-1:0];
reg [SUBR_WITH-1:0] subr_buffer [HEAD_BUFF_DEEP-1:0];
generate 
    if(ADDR_BP_TYPE == 0)begin  //无同地址反压

    end else begin              //开启同地址反压
        integer d;
        always @(posedge clk or negedge resetn) begin
            if(resetn == 1'b0) begin
                for(d=0 ; d<HEAD_BUFF_DEEP ; d=d+1) begin
                    addr_begin_buffer[d] <= #DLY 'd0;
                    addr_end_buffer[d] <= #DLY 'd0;
                end
            end else begin
                if(rknp_xx2reqo_head == 1'b1 && reqo2rknp_xx_ready == 1'b1) begin  //写入操作
                    addr_begin_buffer[idle_head_buff_index] <= #DLY req_addr_begin;
                    addr_end_buffer[idle_head_buff_index] <= #DLY req_addr_end;
                    subr_buffer[idle_head_buff_index] <= #DLY subr;
                end
            end
        end
    end
endgenerate


//----------------------------------------------------------------------------------
//  同地址反压功能
//----------------------------------------------------------------------------------

wire overlop_flag;  //存在地址重合标志位
reg [HEAD_BUFF_DEEP-1:0] overlop_temp;//对比单个单元地址重合
generate 
    if(ADDR_BP_TYPE == 1)begin  //写后写，写后读同地址反压
        for(i=0 ; i < HEAD_BUFF_DEEP; i=i+1) begin
            always @(*) begin
                if(head_buffer[i][BUFF_OPC_OFFSET +: 2] == 2'b01 && head_buffer[i][0] == 1'b1)                              //写后读，写后写保序
                    overlop_temp[i] = (req_addr_end < addr_begin_buffer[i] || req_addr_begin > addr_end_buffer[i] || subr_buffer[i] != subr) ? 1'b0 : 1'b1;
                    
                else 
                    overlop_temp[i] = 1'b0;
                
            end
        end
        
        assign overlop_flag = (rknp_xx2reqo_head == 1'b0) ? 1'b0 : |overlop_temp;  //若存在重叠则为1

    end else if(ADDR_BP_TYPE == 2) begin //写后写，写后读，读后写同地址反压
        for(i=0 ; i < HEAD_BUFF_DEEP; i=i+1) begin
            always @(*) begin
                if(head_buffer[i][BUFF_OPC_OFFSET +: 2] == 2'b01 && head_buffer[i][0] == 1'b1)                               //写后写，写后读保序
                    overlop_temp[i] = ((req_addr_end < addr_begin_buffer[i] || req_addr_begin > addr_end_buffer[i]) || subr_buffer[i] != subr) ? 1'b0 : 1'b1;
                    
                else if(opc[3:2] == 2'b01 && head_buffer[i][BUFF_OPC_OFFSET +: 2] == 2'b00 && head_buffer[i][0] == 1'b1)     //读后写保序
                    overlop_temp[i] = ((req_addr_end < addr_begin_buffer[i] || req_addr_begin > addr_end_buffer[i]) || subr_buffer[i] != subr) ? 1'b0 : 1'b1;
                    
                else
                    overlop_temp[i] = 1'b0;
            end
        end
        assign overlop_flag = (rknp_xx2reqo_head == 1'b0) ? 1'b0 : |overlop_temp;  //若存在重叠则为1，该代码仅防止head段，若head段已通过，则不会反压body段
    end else begin

    end
endgenerate

//----------------------------------------------------------------------------------
//  生成ready信号
//----------------------------------------------------------------------------------
generate 
    if(ADDR_BP_TYPE == 0)begin  //无同地址反压
        always @(*) begin
            if(rspo2reqo_ready == 1'b0 || head_buffer_used == 'd0)  //若下游反压或buffer已满时本模块发起反压
                reqo2rknp_xx_ready = 1'b0;
            else
                reqo2rknp_xx_ready = 1'b1;
        end
    end else begin
        always @(*) begin //开启同地址反压
            if(rspo2reqo_ready == 1'b0 || head_buffer_used == 'd0 || overlop_flag == 1'b1) //增加同地址反压
                reqo2rknp_xx_ready = 1'b0;
            else
                reqo2rknp_xx_ready = 1'b1;
        end
    end
endgenerate

//----------------------------------------------------------------------------------
//  提示watchdog模块开始计时
//----------------------------------------------------------------------------------
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        reqo2wd_axid <= #DLY 'd0;
        reqo2wd_opc <= #DLY 'd0;
    end else if(rknp_xx2reqo_head == 1'b1 && reqo2rknp_xx_ready == 1'b1) begin
        reqo2wd_axid <= #DLY axid;
        reqo2wd_opc <= #DLY opc;
    end
end

always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) 
        reqo2wd_tag_cnt <= #DLY 1'b0;
    else if(rknp_xx2reqo_head == 1'b1 && reqo2rknp_xx_ready == 1'b1)
        reqo2wd_tag_cnt <= #DLY tag_cnt2buffer;
end



generate 
    if(EARLY_RSP_MODE == 0) begin
        always @(posedge clk or negedge resetn) begin
            if(resetn == 1'b0) 
                reqo2wd_timon_en <= #DLY 1'b0;
            else if(rknp_xx2reqo_tail == 1'b1 && reqo2rknp_xx_ready == 1'b1 && status == OK)  
                reqo2wd_timon_en <= #DLY 1'b1;
            else
                reqo2wd_timon_en <= #DLY 1'b0;
        end
    end else begin
        always @(posedge clk or negedge resetn) begin
            if(resetn == 1'b0) 
                reqo2wd_timon_en <= #DLY 1'b0;
            else if(rknp_xx2reqo_tail == 1'b1 && reqo2rknp_xx_ready == 1'b1 && (status == OK && user[0] == 1'b0))  //对于early response的请求与err的请求不进行计时
                reqo2wd_timon_en <= #DLY 1'b1;
            else
                reqo2wd_timon_en <= #DLY 1'b0;
        end
    end

endgenerate



//----------------------------------------------------------------------------------
//  提示watchdog模块TNIU处于无请求状态，需中断计时器计时
//----------------------------------------------------------------------------------

assign timer_interrupt = &head_buffer_used;  //head_buffer_used全1表示buffer空了，当buffer空时中断计时


//----------------------------------------------------------------------------------
//  为watchdog模块提供超时条目表
//----------------------------------------------------------------------------------
generate
    for(i=0; i<HEAD_BUFF_DEEP; i=i+1) begin
        assign reqo2wd_timout_table[(TAG_CNT_WITH+2+AXID_WITH)*(i+1)-1:(TAG_CNT_WITH+2+AXID_WITH)*i] = head_buffer[i][BUFF_TAGCNT_OFFSET +: TAG_CNT_WITH+2+AXID_WITH];
    end
endgenerate


endmodule
