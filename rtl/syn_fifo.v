//=============================================================================
// Copyright(c) 2011, Rockchips Electronics Co, Ltd
// Filename          : wrap_align.v
// Author            : cjs
// Email             : 
// Created On        : 2025-07-22
// Abstract          : synchronous FIFO
// Parameter         :
// Modified History  :
//=============================================================================
module	sync_fifo
#(
     parameter   DATA_WIDTH = 6  								// FIFO data width
    ,parameter   DATA_DEPTH = 8 					      	    // FIFO depth
    ,parameter   DLY = 1 
)
(
     input										clk		 		// System clock
    ,input										resetn	        // Active-low reset signal
    ,input	    [DATA_WIDTH-1:0]				data_in	        // Input data
    ,input										rd_en	        // Read enable signal, active high
    ,input										wr_en	        // Write enable signal, active high

    ,output		[DATA_WIDTH-1:0]				data_out 	    // Output data
    ,output										empty	 	    // Empty flag, high indicates FIFO is empty
    ,output										full		    // Full flag, high indicates FIFO is full
);                                                              
 
// Register definitions
// Use a 2D array to implement RAM
reg [DATA_WIDTH - 1 : 0]			fifo_buffer[DATA_DEPTH - 1 : 0];	
reg [$clog2(DATA_DEPTH) : 0]		wr_ptr;						// Write pointer, width is one bit larger
reg [$clog2(DATA_DEPTH) : 0]		rd_ptr;						// Read pointer, width is one bit larger
 
// Wire definitions
wire [$clog2(DATA_DEPTH) - 1 : 0]	wr_ptr_true;				// Actual write pointer
wire [$clog2(DATA_DEPTH) - 1 : 0]	rd_ptr_true;				// Actual read pointer
wire								wr_ptr_msb;					// Most significant bit of write pointer
wire								rd_ptr_msb;					// Most significant bit of read pointer
 
assign {wr_ptr_msb,wr_ptr_true} = wr_ptr;						// Concatenate MSB with other bits
assign {rd_ptr_msb,rd_ptr_true} = rd_ptr;						// Concatenate MSB with other bits
 
// Read operation, update read pointer
always @ (posedge clk or negedge resetn) begin
    if (resetn == 1'b0)
        rd_ptr <= #DLY 'd0;
    else if (rd_en && !empty)begin								// Read enable is active and FIFO is not empty
        rd_ptr <= #DLY rd_ptr + 1'd1;
    end
end
// Write operation, update write pointer
integer i;
always @ (posedge clk or negedge resetn) begin
    if (!resetn) begin
        wr_ptr <= #DLY 0;
        for (i = 0; i < DATA_DEPTH; i = i + 1) begin
            fifo_buffer[i] <= #DLY 'd0; // Initialize FIFO buffer
        end
    end else if (!full && wr_en)begin								// Write enable is active and FIFO is not full
        wr_ptr <= #DLY wr_ptr + 1'd1;
        fifo_buffer[wr_ptr_true] <= #DLY data_in;
    end	
end
 
// Update status signals
// When all bits are equal, the read pointer catches up with the write pointer, indicating FIFO is empty
assign	empty = ( wr_ptr == rd_ptr ) ? 1'b1 : 1'b0;
// When the MSBs are different but the other bits are equal, the write pointer has wrapped around, indicating FIFO is full
assign	full  = ( (wr_ptr_msb != rd_ptr_msb ) && ( wr_ptr_true == rd_ptr_true ) )? 1'b1 : 1'b0;

 // Output data
assign data_out = fifo_buffer[rd_ptr_true];
endmodule