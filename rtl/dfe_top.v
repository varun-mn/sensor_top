////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Module Description: dfe_top.v 
//  Digital front end for the sensor IC , communicates with AFE / I2C master and manages internal modes
//    ** i2cSlaveTop 		: communicates with master serially over sda/scl  			   
//    ** registerInterface 	: holds sensed data from sensor & config registers for AFE/DFE
//				  *currently supports 16 AFE config registers (address map 8'h00 to 8'h0F) 
// 				  *one 8 bit sensMode register to configure sensors mode of operation  (address map 8'hF0)
// 					   RESERVED , RESERVED , RESERVED , RESERVED , GEN_IRQ , STREAM , LATEST , POWERDOWN
//
// 				  *one 8 bit sense register to store sensor output (address map 8'hF1)
//  
//  To Do:                                                       
//	* Parametrise hardcoded values for registers and memory map.
// 	* Reset sync	
// 
//                                                              
//  Author(s):                                                   
//  Varun Nadiger
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                              
module dfe_top (
  clk,
  rst,
  sda_pad_i,
  scl_pad_i,
  sda_pad_o,
  sens_data_i,
  sens_data_i_val,
  cfgReg0,
  cfgReg1,
  cfgReg2,
  cfgReg3,
  cfgReg4,
  cfgReg5,
  cfgReg6,
  cfgReg7,
  cfgReg8,
  cfgReg9,
  cfgReg10,
  cfgReg11,
  cfgReg12,
  cfgReg13,
  cfgReg14,
  cfgReg15
);


//=====================================================
// Internal clk and rst_n  , TODO : rst_n needs to be sync-ed  
//=====================================================
input clk;
input rst;

//=====================================================
// Signals from/to I2C PAD 
//=====================================================
inout sda_pad_i;
input scl_pad_i;
output sda_pad_o;

//=====================================================
// Inputs from AFE 
//=====================================================
input sens_data_i_val;
input [7:0] sens_data_i;

//=====================================================
// Inputs to AFE 
//=====================================================
output [7:0] cfgReg0 ,cfgReg1 ,cfgReg2 ,cfgReg3 ,cfgReg4 ,cfgReg5 ,cfgReg6 ,cfgReg7 ,cfgReg8 ,cfgReg9 ,cfgReg10 ,cfgReg11 ,cfgReg12 ,cfgReg13 ,cfgReg14 ,cfgReg15;

//=====================================================
// Inputs to RegIF from I2C
//=====================================================
wire [7:0] reg_addr; 
wire [7:0] data_out; 
wire write_en , fifo_rd_en; 

//=====================================================
// Inputs to I2C from RegIF
//=====================================================
wire [7:0] data_in; 

// TODO : If AFE is async may need to bus synchronize sens_data on sens_data_val change. 
reg [7:0] sens_data;
reg [7:0] sens_data_shadow;
reg sens_data_val;

reg [7:0] wr_data_reg;
reg wr_en_reg ;

wire sda_sync , scl_sync;
reg [7:0] rd_data_reg;
wire [7:0] rd_data;
wire empty,full;
reg rd_en_reg;
wire [7:0] sens_mode;


localparam FIFO_DATA_WIDTH = 8;
localparam FIFO_DEPTH = 64;
localparam FIFO_ADDR_WIDTH = 6;  // log2(64)

//=====================================================
// Generate rst_n , i2c_slave expects logic high reset 
// TODO : chech sys requirement, to get logic low or logic high reset from external IP ?
// TODO : sync de-assert rst_n with clk.
//=====================================================
wire rst_n;
assign rst_n = ~rst;


//=====================================================
// Sync sda & scl to internal clock 
//=====================================================
sync_cells_2stage u_sda_sync(
  .async_in(sda_pad_i),
  .clk(clk),
  .rst_n(rst_n),
  .sync_out(sda_sync)
);

sync_cells_2stage u_scl_sync(
  .async_in(scl_pad_i),
  .clk(clk),
  .rst_n(rst_n),
  .sync_out(scl_sync)
);

//=====================================================
// I2C slave inst 
//=====================================================
i2cSlaveTop u_i2cSlaveTop(
  .clk(clk),
  .rst(rst),
  .sda_i(sda_sync),
  .sda_o(sda_pad_o),
  .scl(scl_sync),
  .reg_addr(reg_addr),
  .data_out(data_out),
  .write_en(write_en),
  .data_in(data_in),
  .fifo_rd_en(fifo_rd_en)
);

//=====================================================
// I2C RegIF 
//=====================================================
registerInterface u_registerInterface(
  .clk(clk),
  .rst_n(rst_n),
  .addr(reg_addr),
  .dataIn(data_out),
  .writeEn(write_en),
  .dataOut(data_in),
  .cfgReg0(cfgReg0),
  .cfgReg1(cfgReg1),
  .cfgReg2(cfgReg2),
  .cfgReg3(cfgReg3),
  .cfgReg4(cfgReg4),
  .cfgReg5(cfgReg5),
  .cfgReg6(cfgReg6),
  .cfgReg7(cfgReg7),
  .cfgReg8(cfgReg8),
  .cfgReg9(cfgReg9),
  .cfgReg10(cfgReg10),
  .cfgReg11(cfgReg11),
  .cfgReg12(cfgReg12),
  .cfgReg13(cfgReg13),
  .cfgReg14(cfgReg14),
  .cfgReg15(cfgReg15),
  .sens_mode(sens_mode), 
  .sens_data_i(sens_data_decoded) 
);

//=====================================================
// Sensing mode 
// sens_mode : RESERVED , RESERVED , RESERVED , RESERVED , GEN_IRQ , STREAM , LATEST , POWERDOWN
//=====================================================

// Read latest sensor value
wire [7:0] sens_data_decoded;
assign sens_data_decoded = (!sens_mode[0] && sens_mode[1]) ? sens_data_shadow : rd_data_reg;


// Streamout buffer 
//if (!sens_mode[0] and !sens_mode[1] and sens_mode[2]) begin
//  assign sens_data_decoded = rd_data_reg; 
//end

always @(posedge clk) begin
  if (!rst_n) begin
    rd_data_reg <= {8{1'b0}};
    rd_en_reg <= 1'b0;
  end else if (!sens_mode[0] && !sens_mode[1] && sens_mode[2] ) begin
    rd_en_reg <= fifo_rd_en;
    rd_data_reg <= rd_data;
  end
end
//assign rd_data_reg = rd_data;


//=====================================================
// Capture latest sens data and push it to fifo 
//=====================================================
always @(posedge clk) begin
  if (!rst_n) begin
    sens_data <= {8{1'b0}};
  end else if (sens_data_val) begin
    sens_data <= sens_data_i;
  end
end

always @(posedge clk) begin
  if (!rst_n) begin
    sens_data_val <= {1'b0};
  end else begin
    sens_data_val <= sens_data_i_val;
  end
end


always @(posedge clk) begin
  if (!rst_n) begin
    sens_data_shadow <= {8{1'b0}};
    wr_data_reg <= {8{1'b0}};
    wr_en_reg <= 1'b0;
  end else if (sens_data != sens_data_shadow) begin
    sens_data_shadow <= sens_data;
    wr_data_reg <= sens_data;
    wr_en_reg <= 1'b1;
  end else if (sens_data == sens_data_shadow) begin
    wr_en_reg <= 1'b0;
  end
end


//=====================================================
// Buffer to hold data from sensor 
//=====================================================
streaming_fifo #(
    .DATA_WIDTH(FIFO_DATA_WIDTH),
    .DEPTH(FIFO_DEPTH),
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)
) u_fifo (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_en_reg),
    .wr_data(wr_data_reg),
    .rd_en(rd_en_reg),
    .rd_data(rd_data),
    .full(full),
    .empty(empty)
);


endmodule
