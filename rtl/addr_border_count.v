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
localparam BLOCK_SHIFT = $clog2(ADDR_BLOCK_SIZE);
localparam WORD_SHIFT  = $clog2(NBYTEPERWORD);

// len is encoded as "number of bytes - 1". Calculate byte addresses first,
// then convert both ends to ADDR_BLOCK_SIZE units. The old implementation
// shifted len independently of addr, which missed a block crossing when an
// unaligned INCR request started near the end of a block.
reg [ADDR_WITH-1:0] incr_first_addr;
reg [ADDR_WITH-1:0] wrap_first_addr;
reg [ADDR_WITH-1:0] wrap_mask;
reg [ADDR_WITH:0]   first_byte_addr;
reg [ADDR_WITH:0]   last_byte_addr;
reg [ADDR_WITH:0]   len_ext;

always @(*) begin
    // Assignment performs the required zero extension without assuming that
    // ADDR_WITH is larger than LEN_WITH.
    len_ext = len;

    // COUNT_MODE=1 is used by the response path and aligns an INCR request to
    // the local data-word boundary before calculating its byte range.
    if (COUNT_MODE == 1)
        incr_first_addr = (addr >> WORD_SHIFT) << WORD_SHIFT;
    else
        incr_first_addr = addr;

    // Legal RKNP/AXI WRAP sizes are powers of two. Since len=size-1, len is
    // also the low-bit mask used to obtain the wrap boundary.
    wrap_mask       = len_ext[ADDR_WITH-1:0];
    wrap_first_addr = addr & ~wrap_mask;

    if (burst == 2'b00) begin
        // INCR: the last transferred byte is first byte + len.
        first_byte_addr = {1'b0, incr_first_addr};
        last_byte_addr  = {1'b0, incr_first_addr} + len_ext;
    end
    else begin
        // WRAP: cover the complete wrap window [base, base+len].
        first_byte_addr = {1'b0, wrap_first_addr};
        last_byte_addr  = {1'b0, wrap_first_addr} + len_ext;
    end

    addr_begin = first_byte_addr >> BLOCK_SHIFT;
    addr_end   = last_byte_addr  >> BLOCK_SHIFT;
end

endmodule
