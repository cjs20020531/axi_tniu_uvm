module watchdog#(
     parameter AXID_WITH = 4
    ,parameter TAG_CNT_WITH = 3
    ,parameter TIMOUT_VALUE = 1024          //可配置最大超时值（限制大于3，默认值为1024）  
    ,parameter TIMOUT_TABLE_DEEP = 8   
    ,parameter DLY = 1
)(
     input                              clk
    ,input                              resetn

    // The interface signals of watchdog
    ,input       [AXID_WITH-1:0]        reqo2wd_axid
    ,input       [1:0]                  reqo2wd_opc
    ,input       [TAG_CNT_WITH-1:0]     reqo2wd_tag_cnt
    ,input                              reqo2wd_timon_en
    ,input                              timer_interrupt
    ,input       [TIMOUT_TABLE_DEEP*(AXID_WITH+2+TAG_CNT_WITH+1)-1:0] reqo2wd_timout_table
    // The interface signals of watchdog
    ,input       [AXID_WITH-1:0]        rspo2wd_axid
    ,input       [1:0]                  rspo2wd_opc
    ,input       [TAG_CNT_WITH-1:0]     rspo2wd_tag_cnt
    ,input                              rspo2wd_timoff_en
    ,input                              timout_fifo_rden
    ,output      [AXID_WITH-1:0]        wd2rspo_axid
    ,output      [1:0]                  wd2rspo_opc
    ,output                             timout_fifo_empty
    
);
localparam TIMER_CNT_MAX = TIMOUT_VALUE*2;      //计数器最大值
localparam TIMER_CNT_WITH = $clog2(TIMER_CNT_MAX)+1; 
localparam INDEX_WITH = $clog2(TIMOUT_TABLE_DEEP);

//----------------------------------------------------------------------------------
//  生成超时条目表
//----------------------------------------------------------------------------------
reg [AXID_WITH+TAG_CNT_WITH+2:0] timout_table [TIMOUT_TABLE_DEEP-1:0]; //超时条目表

genvar i,j;
generate
    for(i=0; i<TIMOUT_TABLE_DEEP; i=i+1) begin
        always @(*) begin
            timout_table[i] = reqo2wd_timout_table[(AXID_WITH+2+TAG_CNT_WITH+1)*(i+1)-1:(AXID_WITH+2+TAG_CNT_WITH+1)*i];
        end
    end
endgenerate

//----------------------------------------------------------------------------------
//  启动/中断计时器
//----------------------------------------------------------------------------------
reg [TIMER_CNT_WITH-1:0] timer_cnt; //计时器计数器
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) 
        timer_cnt <= #DLY 'd1;
    else if(timer_interrupt == 1'b0) begin
        if(timer_cnt == TIMER_CNT_MAX)
            timer_cnt <= #DLY 'd1; 
        else
            timer_cnt <= #DLY timer_cnt + 1'b1;
    end
end

//----------------------------------------------------------------------------------
//  生成超时边界时间节点值
//----------------------------------------------------------------------------------
wire [TIMER_CNT_WITH:0]   rsp_timnot_tamp;  //请求时间节点+最大超时时间
wire [TIMER_CNT_WITH-1:0] rsp_timnot;       //超时时间节点

assign rsp_timnot_tamp = timer_cnt + TIMOUT_VALUE;
assign rsp_timnot = (rsp_timnot_tamp <= TIMER_CNT_MAX) ? rsp_timnot_tamp : (rsp_timnot_tamp - TIMER_CNT_MAX);


//----------------------------------------------------------------------------------
//  生成超时节点表
//----------------------------------------------------------------------------------
reg [TIMER_CNT_WITH-1:0] tim_not_table [TIMOUT_TABLE_DEEP-1:0];
localparam TABLE_OPC_OFFSET = TAG_CNT_WITH;

//----------------------------------------------------------------------------------
//  生成开始计时索引值
//----------------------------------------------------------------------------------
wire [TIMOUT_TABLE_DEEP-1:0] timon_table_index_hot;
wire [INDEX_WITH-1:0] timon_table_index;
//独热码转二进制码
wire [INDEX_WITH-1:0] timon_table_index_hot2bin_temp1 [TIMOUT_TABLE_DEEP-1:0];
wire [TIMOUT_TABLE_DEEP-1:0] timon_table_index_hot2bin_temp2 [INDEX_WITH-1:0];
//生成独热码
generate 
    for (i = 0 ; i < TIMOUT_TABLE_DEEP ; i = i + 1) begin 
        assign timon_table_index_hot[i] = ({reqo2wd_axid,reqo2wd_opc,reqo2wd_tag_cnt,1'b1} == timout_table[i]) ? 1'b1 : 1'b0;
    end
endgenerate
//独热码转二进制码
generate
	for(i = 0; i < TIMOUT_TABLE_DEEP; i = i+1)begin 
		assign timon_table_index_hot2bin_temp1[i] = timon_table_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < TIMOUT_TABLE_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign timon_table_index_hot2bin_temp2[j][i] = timon_table_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign timon_table_index[j] = |timon_table_index_hot2bin_temp2[j];
	end
endgenerate

//----------------------------------------------------------------------------------
//  生成终止计时索引值
//----------------------------------------------------------------------------------
wire [TIMOUT_TABLE_DEEP-1:0] timoff_table_index_hot;
wire [INDEX_WITH-1:0] timoff_table_index;
//独热码转二进制码
wire [INDEX_WITH-1 : 0] timoff_table_index_hot2bin_temp1 [TIMOUT_TABLE_DEEP-1 : 0];
wire [TIMOUT_TABLE_DEEP-1 : 0] timoff_table_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
//生成独热码
generate 
    for (i = 0 ; i < TIMOUT_TABLE_DEEP ; i = i + 1) begin 
        assign timoff_table_index_hot[i] = ({rspo2wd_axid,rspo2wd_opc,rspo2wd_tag_cnt,1'b1} == timout_table[i]) ? 1'b1 : 1'b0;
    end
endgenerate
//独热码转二进制码
generate
	for(i = 0; i < TIMOUT_TABLE_DEEP; i = i+1)begin 
		assign timoff_table_index_hot2bin_temp1[i] = timoff_table_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < TIMOUT_TABLE_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign timoff_table_index_hot2bin_temp2[j][i] = timoff_table_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign timoff_table_index[j] = |timoff_table_index_hot2bin_temp2[j];
	end
endgenerate

//----------------------------------------------------------------------------------
// 判断是否超时
//----------------------------------------------------------------------------------
wire [TIMOUT_TABLE_DEEP-1:0] timout_table_index_hot; //超时索引
wire [INDEX_WITH-1:0] timout_table_index;
//独热码转二进制码
wire [INDEX_WITH-1 : 0] timout_table_index_hot2bin_temp1 [TIMOUT_TABLE_DEEP-1 : 0];
wire [TIMOUT_TABLE_DEEP-1 : 0] timout_table_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
generate
    for(i=0; i<TIMOUT_TABLE_DEEP; i=i+1) begin
        assign timout_table_index_hot[i] = (tim_not_table[i] == timer_cnt) ? 1'b1 : 1'b0;
    end
endgenerate
//独热码转二进制码
generate
	for(i = 0; i < TIMOUT_TABLE_DEEP; i = i+1)begin 
		assign timout_table_index_hot2bin_temp1[i] = timout_table_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < TIMOUT_TABLE_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign timout_table_index_hot2bin_temp2[j][i] = timout_table_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign timout_table_index[j] = |timout_table_index_hot2bin_temp2[j];
	end
endgenerate

wire timout_flag; //超时标志
assign timout_flag = |timout_table_index_hot; //如果有超时标志，则为1
//----------------------------------------------------------------------------------
//  1、存储超时节点
//  2、删除超时节点
//----------------------------------------------------------------------------------
integer a;
always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
        for(a = 0; a < TIMOUT_TABLE_DEEP; a = a + 1)
            tim_not_table[a] <= #DLY 'd0;
    end else begin
        // 清除已经超时的旧条目
        if(timout_flag)
            tim_not_table[timout_table_index] <= #DLY 'd0;

        // 完成响应的请求停止计时
        if(rspo2wd_timoff_en)
            tim_not_table[timoff_table_index] <= #DLY 'd0;

        // 新请求最后写入；如果同一表项刚好被复用，新请求计时必须保留
        if(reqo2wd_timon_en)
            tim_not_table[timon_table_index] <= #DLY rsp_timnot;
    end
end

//----------------------------------------------------------------------------------
//  超时处理
//----------------------------------------------------------------------------------
wire [AXID_WITH+1:0] data_in; //写入fifo数据
wire [AXID_WITH+1:0] data_out; //读出fifo数据
wire timout_fifo_wren; //写使能

assign timout_fifo_wren = timout_flag;
assign data_in = {timout_table[timout_table_index][TABLE_OPC_OFFSET +: AXID_WITH+2]}; //写入数据

assign wd2rspo_axid = data_out[2 +: AXID_WITH];
assign wd2rspo_opc = data_out[1:0];

sync_fifo #(
     .DATA_WIDTH    (AXID_WITH+2)   //fifo数据宽度
    ,.DATA_DEPTH    (TIMOUT_TABLE_DEEP)     //fifo深度
    ,.DLY           (DLY              )
) U_SYNC_FIFO_TIMOUT (
     .clk           (clk)                 
    ,.resetn        (resetn)             
    ,.data_in       (data_in)            //写入数据
    ,.rd_en         (timout_fifo_rden)   //读使能
    ,.wr_en         (timout_fifo_wren)   //写使能
    ,.data_out      (data_out)           //读出数据
    ,.empty         (timout_fifo_empty)  //空标志
    ,.full          ()                   //满标志
);







endmodule