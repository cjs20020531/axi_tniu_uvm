//=============================================================================
// Copyright(c) 2011, Rockchips Electronics Co, Ltd
// Filename          : wrap_align.v
// Auther            : cjs
// Email             : 
// Created On        : 2025-07-27
// Abstract          : When the local TNIU data bit width is larger than any AXI/AHB INIU data bit width in NoC, 
//                     it may happen that the INIU WRAP request address is not aligned with the WRAP address of TNIU, 
//                     and additional alignment operation is needed for the WRAP request address.
// Parameter         :
// Modified History  :
//=============================================================================

module wrap_align#(

     parameter REQ_HEAD_LEN_OFFSET = 102
    ,parameter ADDR_WITH = 32

    ,parameter REQ_OPC_OFFSET = 43
    ,parameter REQ_STATUS_OFFSET = 47
    ,parameter REQ_LEN_OFFSET = 49
    ,parameter REQ_ADDR_OFFSET = 57
    ,parameter REQ_USER_OFFSET = 89

    ,parameter NBYTEPERWORD = 8   
    ,parameter REQ_FLIT_WITH = 177 

    ,parameter RWRAP_CNT_MAX = 4
    ,parameter DLY = 1

)(
    // The interface signals of rknp_xx
     input                           clk
    ,input                           resetn
    ,input                           rknp_xx2wa_head
    ,input                           rknp_xx2wa_tail
    ,input                           rknp_xx2wa_valid
    ,input       [REQ_FLIT_WITH-1:0] rknp_xx2wa_data
    ,output reg                      wa2rknp_xx_ready

    // The interface signals of req_order
    ,output reg                      wa2reqo_head
    ,output wire                     wa2reqo_tail
    ,output reg                      wa2reqo_valid
    ,input  wire                     reqo2wa_ready
    ,output reg  [REQ_FLIT_WITH-1:0] wa2reqo_data
    ,output wire [7:0]               wa2reqo_offset_addr

    // The interface signals of wrap_adjust
    ,input                           rwrap_rsp_fin

);
parameter RD  = 4'b0000;
parameter RDW = 4'b0001;
parameter WR  = 4'b0100;
parameter WRW = 4'b0101;

localparam AXI_SIZE = $clog2(NBYTEPERWORD);
localparam RWRAP_CNT_WITH = $clog2(RWRAP_CNT_MAX);

wire [3:0]                  opc;
wire [7:0]                  len;
wire [ADDR_WITH-1:0]    src_addr;    //Source address
wire [NBYTEPERWORD*9-1:0]   body;    //The body does not contain LW bits
assign src_addr = rknp_xx2wa_data[REQ_ADDR_OFFSET +: ADDR_WITH];
assign opc = rknp_xx2wa_data[REQ_OPC_OFFSET +: 4];
assign body = rknp_xx2wa_data[REQ_HEAD_LEN_OFFSET+1 +: NBYTEPERWORD*9]; 

assign len = rknp_xx2wa_data[REQ_LEN_OFFSET +: 8];

wire [ADDR_WITH-1:0]    jud_addr;    //The forward alignment address is used to determine whether the address is aligned
reg  [ADDR_WITH-1:0]    align_addr;  //addresses of wrap aligns 
reg  [7:0]              offset_addr; //address offset of the wrap alignment


assign jud_addr = (src_addr >> AXI_SIZE) << AXI_SIZE;
always @(*) begin
    if(jud_addr == src_addr)
        align_addr = src_addr;
    else if(rknp_xx2wa_data[REQ_OPC_OFFSET +: 4] == RDW)
        align_addr = jud_addr;
    else
        align_addr = jud_addr + NBYTEPERWORD;
end
always @(*) begin
    if(jud_addr == src_addr)
        offset_addr = 'd0;
    else if(rknp_xx2wa_data[REQ_OPC_OFFSET +: 4] == RDW)
        offset_addr = src_addr[7:0] - align_addr[7:0];
    else
        offset_addr = align_addr[7:0] - src_addr[7:0];
end
assign wa2reqo_offset_addr = (opc[1:0] == 2'b01 && len[7:2] != 6'd0) ? offset_addr : 8'd0; // wrap请求的长度不足一个flit，也不能生成偏移地址

//------------------------------------------------------
// A counter for the number of unaligned read wrap requests is generated for out-of-gauge backpressure
//------------------------------------------------------
reg [RWRAP_CNT_WITH:0] rwrap_cnt;   // Unaligned read wrap request count counter
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) 
        rwrap_cnt <= #DLY 'd0;
    else if(wa2reqo_head == 1'b1 && reqo2wa_ready == 1'b1 && wa2reqo_data[REQ_OPC_OFFSET +: 4] == RDW && wa2reqo_offset_addr != 8'd0)
        rwrap_cnt <= #DLY rwrap_cnt + 1'b1;
    else if(rwrap_rsp_fin == 1'b1)
        rwrap_cnt <= #DLY rwrap_cnt - 1'b1;
end

//------------------------------------------------------
// Generate the ready signal
//------------------------------------------------------
always @(*) begin
    if(opc == RDW && rwrap_cnt == RWRAP_CNT_MAX)
        wa2rknp_xx_ready = 1'b0;
    else
        wa2rknp_xx_ready = reqo2wa_ready;
end
//------------------------------------------------------
// The first beat data of the write wrap unaligned request is cached
//------------------------------------------------------
reg [REQ_FLIT_WITH-1:0]         wwrap_buffer;
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) 
        wwrap_buffer <= #DLY 0;
    else if (rknp_xx2wa_head == 1'b1)
        wwrap_buffer <= #DLY {rknp_xx2wa_data[REQ_FLIT_WITH-1:REQ_USER_OFFSET] , align_addr , rknp_xx2wa_data[REQ_ADDR_OFFSET-1:0]};
end

//------------------------------------------------------
// The rknp_xx2wa_head signal is tapped to act as the head signal for writing the wrap unaligned request output
//------------------------------------------------------
reg rknp_xx2wa_head_d;
always @(posedge clk or negedge resetn) begin
    if (resetn == 1'b0) 
        rknp_xx2wa_head_d <= #DLY 1'b0;
    else if (rknp_xx2wa_head == 1'b1 && wa2rknp_xx_ready == 1'b1 && opc == WRW && wa2reqo_offset_addr != 8'd0) // 必须是需要对齐的写WRAP才能拉高head_d
        rknp_xx2wa_head_d <= #DLY 1'b1;
    else if(reqo2wa_ready == 1'b1)
        rknp_xx2wa_head_d <= #DLY 1'b0;
end
//------------------------------------------------------
// head signal generation
//------------------------------------------------------
always @(*) begin
    if(opc == WRW && wa2reqo_offset_addr != 8'd0 && rknp_xx2wa_head_d == 1'b1 && wa2rknp_xx_ready == 1'b1)
        wa2reqo_head = rknp_xx2wa_head_d;
    else if(opc == WRW && wa2reqo_offset_addr != 8'd0 && rknp_xx2wa_head == 1'b1 && wa2rknp_xx_ready == 1'b1)
        wa2reqo_head = 1'd0;
    else if(rknp_xx2wa_head == 1'b1 && wa2rknp_xx_ready == 1'b1)
        wa2reqo_head = rknp_xx2wa_head;
    else
        wa2reqo_head = 1'd0;
end

//------------------------------------------------------
// tail signal generation
//------------------------------------------------------
assign wa2reqo_tail = (rknp_xx2wa_tail && wa2rknp_xx_ready) ? 1'b1 : 1'b0;


//------------------------------------------------------
// Generate the body offset length
//------------------------------------------------------
wire [9:0] offset_body;

assign offset_body = (offset_addr << 3) + offset_addr; //Offset length = offset_addr×9
//------------------------------------------------------
// Generate data signals
//------------------------------------------------------
always @(*) begin
    if(opc[1:0] == 2'b01 && len[7:2] == 6'd0) begin// 如果wrap请求不足一个flit，转为incr传输
        wa2reqo_data = {rknp_xx2wa_data[REQ_FLIT_WITH-1:REQ_STATUS_OFFSET] , opc[3:2], 2'b00 , rknp_xx2wa_data[REQ_OPC_OFFSET-1:0]};

    end else begin
        if(opc == WRW && offset_addr != 8'd0 && rknp_xx2wa_tail == 1'b1 && wa2rknp_xx_ready == 1'b1) begin // The last beat of the Write WRAP misalignment request after alignment.
            wa2reqo_data[REQ_HEAD_LEN_OFFSET+1 +: 9*NBYTEPERWORD] = ((wwrap_buffer[REQ_HEAD_LEN_OFFSET+1 +: 9*NBYTEPERWORD] >> (9*NBYTEPERWORD - offset_body)) << (9*NBYTEPERWORD - offset_body))  //The body part (excluding the LW bit)
                                                                    | ((body[0 +: 9*NBYTEPERWORD] << offset_body) >> offset_body);
            wa2reqo_data[REQ_HEAD_LEN_OFFSET-1 : 0] = wwrap_buffer[REQ_HEAD_LEN_OFFSET-1 : 0];  //The head part (excluding the LW bit)
            wa2reqo_data[REQ_HEAD_LEN_OFFSET] = 1'b1; // LW bit at high level

        end else if(opc == WRW && offset_addr != 8'd0 && rknp_xx2wa_head_d == 1'b1 && wa2rknp_xx_ready == 1'b1) begin // the first beat after aligning the Write WRAP misaligned request
            wa2reqo_data = {body, wwrap_buffer[REQ_HEAD_LEN_OFFSET : 0]}; 
        
        end else if(opc == WRW && offset_addr != 8'd0 && rknp_xx2wa_valid == 1'b1 && wa2rknp_xx_ready == 1'b1) begin // the middle beat after aligning the Write WRAP misaligned request
            wa2reqo_data[REQ_HEAD_LEN_OFFSET+1 +: 9*NBYTEPERWORD] = body;
            wa2reqo_data[REQ_HEAD_LEN_OFFSET : 0] = wwrap_buffer[REQ_HEAD_LEN_OFFSET : 0];     // including the LW bit

        end else if(opc == RDW && offset_addr != 8'd0 && rknp_xx2wa_valid && wa2rknp_xx_ready) begin  //Read WRAP misaligned requires need to align the addresses
            wa2reqo_data = {rknp_xx2wa_data[REQ_FLIT_WITH-1:REQ_USER_OFFSET] , align_addr , rknp_xx2wa_data[REQ_ADDR_OFFSET-1:0]};

        end else if(rknp_xx2wa_valid && wa2rknp_xx_ready) begin  //INCR type direct passthtrough
            wa2reqo_data = rknp_xx2wa_data;
        end else 
            wa2reqo_data = 'd0;
    end
    
end


//------------------------------------------------------
// Generate valid signals
//------------------------------------------------------
always @(*) begin
    if(opc == WRW && wa2reqo_offset_addr != 8'd0 && rknp_xx2wa_head == 1'b1 && wa2rknp_xx_ready == 1'b1)
        wa2reqo_valid = 1'b0;
    else
        wa2reqo_valid = rknp_xx2wa_valid && wa2rknp_xx_ready;
end


endmodule
