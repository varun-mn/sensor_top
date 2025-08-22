`include "i2cSlave_define.v"


module i2cSlaveTop (
  clk,
  rst,
  sda_i,
  sda_o,
  scl,
  reg_addr,
  data_out,
  write_en,
  data_in,
  fifo_rd_en
);
input clk;
input rst;
input sda_i;
output sda_o;
input scl;
output [7:0] reg_addr; 
output [7:0] data_out; 
input  [7:0] data_in; 
output write_en,fifo_rd_en; 


i2cSlave u_i2cSlave(
  .clk(clk),
  .rst(rst),
  .sda_i(sda_i),
  .sda_o(sda_o),
  .scl(scl),
  .reg_addr(reg_addr),
  .data_out(data_out),
  .write_en(write_en),
  .data_in(data_in),
  .fifo_rd_en(fifo_rd_en)
);


endmodule


 
