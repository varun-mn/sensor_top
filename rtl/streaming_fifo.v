////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Module Description: streaming_fifo.v 
//  Buffer to hold data from sensor. 
//	* Overflow is allowed to keep the latest entries from sensor. 
//                                                              
//  Author(s):                                                   
//  Varun Nadiger
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module streaming_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 64,
    parameter ADDR_WIDTH = 6              // log2(64)
)(
    input  wire                  clk,
    input  wire                  rst_n,

    // Write side
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,

    // Read side
    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] rd_data,
 
    // Status
    output reg full,
    output reg empty
    
);


// Memory
reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

// Pointers
reg [ADDR_WIDTH-1:0] wr_ptr;
reg [ADDR_WIDTH-1:0] rd_ptr;

reg [ADDR_WIDTH+1:0] gap;

//reg full,empty;
integer i;

//=====================================================
// Write Logic (overwrites old data if FIFO "full")
//=====================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= {ADDR_WIDTH{1'b0}};
            for (i = 0; i < DEPTH; i = i + 1) begin
              mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end else if (wr_en) begin
            mem[wr_ptr] <= wr_data;
            wr_ptr <= wr_ptr + 1'b1;
            if (!rd_en && gap < DEPTH) begin
               gap <= gap + 1'b1;
            end
        end
    end

//=====================================================
// Read Logic (just streams data out)
//=====================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            rd_ptr  <= {ADDR_WIDTH{1'b0}};
            rd_data <= {DATA_WIDTH{1'b0}};
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr];
            rd_ptr  <= rd_ptr + 1'b1;   // wraps automatically
            if (!wr_en) begin
               gap <= gap - 1'b1;
            end
        end
    end

//=====================================================
// Detect write lap read
//=====================================================
    
always @(posedge clk) begin
  if (!rst_n) begin
    gap    <= {(ADDR_WIDTH+1){1'b0}};
  end else if (gap == DEPTH && wr_en && !rd_en) begin
    rd_ptr <= wr_ptr + 1'b1; 
  end 
end

//=====================================================
// Detect empty , full 
//=====================================================
always @(posedge clk) begin
  if (!rst_n) begin
    full <= 1'b0;
    empty <= 1'b1;
  end else if (gap == {(ADDR_WIDTH+1){1'b0}}) begin
    full <= 1'b0;
    empty <= 1'b1;
  end else if ((gap > {(ADDR_WIDTH+1){1'b0}}) && gap < DEPTH) begin
    full <= 1'b0;
    empty <= 1'b0;
  end else if ((gap > {(ADDR_WIDTH+1){1'b0}}) && gap == DEPTH) begin
    full <= 1'b1;
    empty <= 1'b0;
  end
 
end

endmodule
