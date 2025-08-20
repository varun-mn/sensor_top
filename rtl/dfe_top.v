module dfe_top (
  clk,
  rst,
  sda_pad_i,
  scl_pad_i,
  sda_pad_o,
  sens_data,
  sens_data_val
);
input clk;
input rst;
inout sda_pad_i;
input scl_pad_i;
output sda_pad_o;
input sens_data_val;
input [7:0] sens_data;

wire sda_sync , scl_sync;

localparam FIFO_DATA_WIDTH = 8;
localparam FIFO_DEPTH = 64;
localparam FIFO_ADDR_WIDTH = 6;  // log2(64)


sync_cells_2stage u_sda_sync(
  .async_in(sda_pad_i),
  .clk(clk),
  .rst_n(rst),
  .sync_out(sda_sync)
)

sync_cells_2stage u_scl_sync(
  .async_in(scl_pad_i),
  .clk(clk),
  .rst_n(rst),
  .sync_out(scl_sync)
)

i2cSlaveTop u_i2cSlaveTop(
  .clk(clk),
  .rst(rst),
  .sda(sda_sync),
  .scl(scl_sync)
);

streaming_fifo #(
    .DATA_WIDTH(FIFO_DATA_WIDTH),
    .DEPTH(FIFO_DEPTH),
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)
) u_fifo (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .rd_en(rd_en),
    .rd_data(rd_data),
    .full(full),
    .empty(empty)
);

endmodule
