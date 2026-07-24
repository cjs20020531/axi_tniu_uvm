//=============================================================================
// Copyright(c) 2011, Rockchips Electronics Co, Ltd
// Filename          : wrap_align.v
// Author            : cjs
// Email             : 
// Created On        : 2025-08-02
// Abstract          : synchronous FIFO
// Parameter         : COUNT_MODE = 1,表示计算的是对齐地址边界; COUNT_MODE = 0,表示计算的是原始地址边界
// Modified History  :
//=============================================================================
module addr_border_cout#(
     parameter ADDR_WITH = 4
    ,parameter LEN_WITH = 8
    ,parameter NBYTEPERWORD = 8
    ,parameter ADDR_BLOCK_SIZE = 64
    ,parameter COUNT_MODE = 0
)(
     input      [1:0]           burst    //burst type
    ,input      [ADDR_WITH-1:0] addr
    ,input      [LEN_WITH-1:0]  len
    ,output reg [ADDR_WITH-$clog2(ADDR_BLOCK_SIZE)-1:0] addr_begin
    ,output reg [ADDR_WITH-$clog2(ADDR_BLOCK_SIZE)-1:0] addr_end
); 
localparam BIN_WITH = $clog2(LEN_WITH+1);
//----------------------------------------------------------------------------------
// Calculate len right-shifted by log2(ADDR_BLOCK_SIZE)
//----------------------------------------------------------------------------------
wire [LEN_WITH-$clog2(ADDR_BLOCK_SIZE):0] len_rshift;
assign len_rshift = (len+1) >> $clog2(ADDR_BLOCK_SIZE);

genvar i,j;
//----------------------------------------------------------------------------------
// Calculate log2(len)
//----------------------------------------------------------------------------------
wire [LEN_WITH:0] len_add_one; // len value plus one
wire [BIN_WITH-1:0] len_add_one_temp1 [LEN_WITH:0];
wire [LEN_WITH:0] len_add_one_temp2 [BIN_WITH-1:0];
wire [BIN_WITH-1:0] log2_len;
assign len_add_one = len + 1'b1;
// Convert one-hot code to binary code
generate
    for(i = 0; i <= LEN_WITH; i = i+1)begin 
        assign len_add_one_temp1[i] = len_add_one[i]? i:'b0;
    end
endgenerate
generate
    for(i = 0; i <= LEN_WITH; i = i+1)begin 
        for(j = 0; j < BIN_WITH; j = j+1) begin  
            assign len_add_one_temp2[j][i] = len_add_one_temp1[i][j];
        end
    end
endgenerate
generate
    for(j = 0; j < BIN_WITH; j = j+1)begin 
        assign log2_len[j] = |len_add_one_temp2[j];
    end
endgenerate

//----------------------------------------------------------------------------------
// Calculate log2(len_rshift)
//----------------------------------------------------------------------------------

wire [BIN_WITH-1:0] len_rshift_temp1 [LEN_WITH-$clog2(ADDR_BLOCK_SIZE):0];
wire [LEN_WITH-$clog2(ADDR_BLOCK_SIZE):0] len_rshift_temp2 [BIN_WITH-1:0];
wire [BIN_WITH-1:0] log2_len_rshift;
// Convert one-hot code to binary code
generate
    for(i = 0; i <= LEN_WITH-$clog2(ADDR_BLOCK_SIZE); i = i+1)begin 
        assign len_rshift_temp1[i] = len_rshift[i]? i:'b0;
    end
endgenerate
generate
    for(i = 0; i <= LEN_WITH-$clog2(ADDR_BLOCK_SIZE); i = i+1)begin 
        for(j = 0; j < BIN_WITH; j = j+1) begin  
            assign len_rshift_temp2[j][i] = len_rshift_temp1[i][j];
        end
    end
endgenerate
generate
    for(j = 0; j < BIN_WITH; j = j+1)begin 
        assign log2_len_rshift[j] = |len_rshift_temp2[j];
    end
endgenerate

//----------------------------------------------------------------------------------
// Address boundary calculation functionality
//----------------------------------------------------------------------------------
generate if(COUNT_MODE == 0) 
    always @(*) begin
        if(burst == 2'b00) begin   // INCR burst
            addr_begin = addr >> $clog2(ADDR_BLOCK_SIZE);
            if(len_rshift == 'd0) addr_end = addr_begin;
            else                  addr_end = addr_begin + len_rshift - 1;
        end else begin    // WRAP burst
            addr_begin = ((addr >> $clog2(ADDR_BLOCK_SIZE)) >> log2_len) << log2_len_rshift;
            if(len_rshift == 'd0) addr_end = addr_begin;
            else                  addr_end = addr_begin + len_rshift - 1;
        end
    end
endgenerate

generate if(COUNT_MODE == 1) 
    always @(*) begin
        if(burst == 2'b00) begin   // INCR burst
            addr_begin = (addr >> $clog2(NBYTEPERWORD) << $clog2(NBYTEPERWORD)) >> $clog2(ADDR_BLOCK_SIZE);
            if(len_rshift == 'd0) addr_end = addr_begin;
            else                  addr_end = addr_begin + len_rshift - 1;
        end else begin    // WRAP burst
            addr_begin = ((addr >> $clog2(ADDR_BLOCK_SIZE)) >> log2_len) << log2_len_rshift;
            if(len_rshift == 'd0) addr_end = addr_begin;
            else                  addr_end = addr_begin + len_rshift - 1;
        end
    end
endgenerate

endmodule