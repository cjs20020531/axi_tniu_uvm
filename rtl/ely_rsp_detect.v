module ely_rsp_detect#(

     parameter URGE_WITH = 7
    ,parameter SUBR_WITH = 8
    ,parameter ADDR_WITH = 32
    ,parameter AXID_WITH = 4
    ,parameter LEN_WITH = 8 
    ,parameter USER_WITH = 10
    ,parameter NBYTEPERWORD = 8
    
    ,parameter ELYRSP_TABLE_DEEP = 8
    ,parameter AUSER_WITH = 1
    ,parameter TAG_CNT_WITH = 3
    ,parameter DLY = 1
)(
     input                              clk
    ,input                              resetn
    // The interface signals of rsp_order
    ,input                              rspo2erd_head
    ,input       [AXID_WITH-1:0]        rspo2erd_axid
    ,input       [3:0]                  rspo2erd_opc
    ,input       [USER_WITH-1:0]        rspo2erd_user
    ,input       [TAG_CNT_WITH-1:0]     rspo2erd_tag_cnt
    
    // The interface signals of rsp_trans
    ,input                              rspt2erd_head
    ,input                              rspt2erd_tail
    ,input                              rspt2erd_valid
    ,output                             erd2rspt_ready
    ,input      [AXID_WITH-1:0]         rspt2erd_axid
    ,input      [AUSER_WITH:0]          rspt2erd_auser
    ,input      [1:0]                   rspt2erd_opc
    ,input      [2:0]                   rspt2erd_errcode
    ,input      [1:0]                   rspt2erd_status
    ,input      [9*NBYTEPERWORD:0]      rspt2erd_data
    ,input                              rspt2erd_lw

    // The interface signals of rsp_order
    ,output                             erd2rspo_head
    ,output                             erd2rspo_tail
    ,output                             erd2rspo_valid
    ,input                              rspo2erd_ready
    ,output      [AXID_WITH-1:0]        erd2rspo_axid
    ,output      [AUSER_WITH:0]         erd2rspo_auser
    ,output      [1:0]                  erd2rspo_opc
    ,output      [2:0]                  erd2rspo_errcode
    ,output      [1:0]                  erd2rspo_status
    ,output      [9*NBYTEPERWORD:0]     erd2rspo_data
    ,output                             erd2rspo_lw
    ,output                             buff_rsp_flag
    ,output      [TAG_CNT_WITH-1:0]     erd2rspo_tag_cnt
);

localparam INDEX_WITH = $clog2(ELYRSP_TABLE_DEEP); //二进制索引值的位宽
localparam R = 2'b00;
localparam W = 2'b01;
//------------------------------------------------------
//  生成early response条目表
//------------------------------------------------------

reg [AXID_WITH+TAG_CNT_WITH+1:0] ely_rsp_table [ELYRSP_TABLE_DEEP-1:0]; //AXID\TAG_CNT\AxCHACHE[0]\used

//------------------------------------------------------
//  生成early response条目表空闲单元索引值
//------------------------------------------------------
wire [ELYRSP_TABLE_DEEP-1:0] table_used; 
wire [ELYRSP_TABLE_DEEP-1:0] idle_table_index_hot;
wire [INDEX_WITH-1:0] idle_table_index_hot2bin_temp1 [ELYRSP_TABLE_DEEP-1 : 0]; 
wire [ELYRSP_TABLE_DEEP-1:0] idle_table_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
wire [INDEX_WITH-1:0] idle_table_index;
//索引buffer为idle的单元
genvar i,j;
generate 
    for (i = 0 ; i < ELYRSP_TABLE_DEEP ; i = i + 1) begin 
        assign table_used[i] = ~ely_rsp_table[i][0];
    end
endgenerate
//保留二进制最低位1操作-生成独热码
assign idle_table_index_hot = table_used & (~table_used+1);
//独热码转二进制码
generate
	for(i = 0; i < ELYRSP_TABLE_DEEP; i = i+1)begin 
		assign idle_table_index_hot2bin_temp1[i] = idle_table_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < ELYRSP_TABLE_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign idle_table_index_hot2bin_temp2[j][i] = idle_table_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign idle_table_index[j] = |idle_table_index_hot2bin_temp2[j];
	end
endgenerate

//------------------------------------------------------
//  根据real response生成early response条目表最低位单元索引值
//------------------------------------------------------
wire [ELYRSP_TABLE_DEEP-1:0] table_index_temp; 
wire [ELYRSP_TABLE_DEEP-1:0] table_index_hot;
wire [INDEX_WITH-1:0] table_index_hot2bin_temp1 [ELYRSP_TABLE_DEEP-1 : 0]; 
wire [ELYRSP_TABLE_DEEP-1:0] table_index_hot2bin_temp2 [INDEX_WITH-1 : 0];
wire [INDEX_WITH-1:0] table_index;

generate 
    for (i = 0 ; i < ELYRSP_TABLE_DEEP ; i = i + 1) begin 
        assign table_index_temp[i] = (rspt2erd_axid == ely_rsp_table[i][2 +: AXID_WITH] && rspt2erd_opc == W && ely_rsp_table[i][0] == 1'b1) ? 1'b1 : 1'b0;
    end
endgenerate
//保留二进制最低位1操作-生成独热码
assign table_index_hot = table_index_temp & (~table_index_temp+1);
//独热码转二进制码
generate
	for(i = 0; i < ELYRSP_TABLE_DEEP; i = i+1)begin 
		assign table_index_hot2bin_temp1[i] = table_index_hot[i]? i:'b0;
	end
endgenerate
generate
	for(i = 0; i < ELYRSP_TABLE_DEEP; i = i+1)begin 
		for(j = 0; j < INDEX_WITH; j = j+1) begin  
			assign table_index_hot2bin_temp2[j][i] = table_index_hot2bin_temp1[i][j];
		end
	end
endgenerate
generate
	for(j = 0; j < INDEX_WITH; j = j+1)begin 
		assign table_index[j] = |table_index_hot2bin_temp2[j];
	end
endgenerate


//------------------------------------------------------
//   1、写入条目表
//   2、条目表移位
//------------------------------------------------------
integer a;
integer b;
integer c;
always @(posedge clk or negedge resetn) begin
    if(resetn == 1'b0) begin
        for(a = 0; a < ELYRSP_TABLE_DEEP; a = a + 1) begin
            ely_rsp_table[a] <= #DLY 'd0;
        end
    end else if(rspo2erd_head == 1'b1 && rspo2erd_opc[3:2] == W && rspt2erd_head == 1'b1 && erd2rspt_ready == 1'b1 && rspt2erd_opc == W) begin //请求与响应同时到达且满足条件
        for (b = 0; b < 8; b = b + 1) begin
            if (b >= table_index && b < (idle_table_index-1)) begin
                // 将高位单元值赋给当前单元
                ely_rsp_table[b] <= #DLY ely_rsp_table[b+1];
            end else if (b == (idle_table_index-1)) begin
                // 将最新值赋给最高位非空闲单元
                ely_rsp_table[idle_table_index-1] <= #DLY {rspo2erd_axid, rspo2erd_tag_cnt, rspo2erd_user[0],1'b1};
            end
        end
    end else if(rspo2erd_head == 1'b1 && rspo2erd_opc[3:2] == W) begin
        ely_rsp_table[idle_table_index] <= #DLY {rspo2erd_axid, rspo2erd_tag_cnt, rspo2erd_user[0],1'b1};
    end else if(rspt2erd_tail == 1'b1 && erd2rspt_ready == 1'b1 && rspt2erd_opc == W) begin
        for (c = 0; c < 8; c = c + 1) begin
            if (c >= table_index && c < ELYRSP_TABLE_DEEP-1) begin
                // 将高位单元值赋给当前单元
                ely_rsp_table[c] <= #DLY ely_rsp_table[c+1];
            end else if (c == ELYRSP_TABLE_DEEP-1) begin
                // 最高位单元赋零
                ely_rsp_table[ELYRSP_TABLE_DEEP-1] <= #DLY 'd0;
            end
        end
    end
end

//------------------------------------------------------
//   判断当前响应是否为early response的real response
//------------------------------------------------------

// assign erd2rspo_head  = (ely_rsp_table[table_index][1] == 1'b1 && rspt2erd_opc == W) ? 1'b0 : rspt2erd_head;
// assign erd2rspo_valid = (ely_rsp_table[table_index][1] == 1'b1 && rspt2erd_opc == W) ? 1'b0 : rspt2erd_valid;
// assign erd2rspo_tail  = (ely_rsp_table[table_index][1] == 1'b1 && rspt2erd_opc == W) ? 1'b0 : rspt2erd_tail;


assign erd2rspo_head  = rspt2erd_head;
assign erd2rspo_valid = rspt2erd_valid;
assign erd2rspo_tail  = rspt2erd_tail;

assign buff_rsp_flag = (ely_rsp_table[table_index][1] == 1'b1 && rspt2erd_opc == W) ? rspt2erd_head : 1'b0;

//------------------------------------------------------
//   生成ready
//------------------------------------------------------

assign erd2rspt_ready  = rspo2erd_ready;

//------------------------------------------------------
//   数据透传
//------------------------------------------------------
assign erd2rspo_axid = rspt2erd_axid;
assign erd2rspo_auser = rspt2erd_auser;
assign erd2rspo_opc = rspt2erd_opc;
assign erd2rspo_errcode = rspt2erd_errcode;
assign erd2rspo_status = rspt2erd_status;
assign erd2rspo_data = rspt2erd_data;
assign erd2rspo_lw = rspt2erd_lw;
assign erd2rspo_tag_cnt = ely_rsp_table[table_index][TAG_CNT_WITH+1:2];

endmodule