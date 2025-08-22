// -------------------------- testHarness.v -----------------------
`include "timescale.v"

module testHarness ();

reg rst;
reg clk; 
reg i2cHostClk;
wire sda;
wire sda_from_dfe;
wire scl;
wire sdaOutEn;
wire sdaOut;
wire sdaIn;
wire [2:0] adr;
wire [7:0] masterDout;
wire [7:0] masterDin;
wire we;
wire stb;
wire cyc;
wire ack;
wire scl_pad_i;
wire scl_pad_o;
wire scl_padoen_o;
wire sda_pad_i;
wire sda_pad_o;
wire sda_padoen_o;
  
reg sens_data_i_val;
reg [7:0] sens_data_i;
wire [7:0] cfgReg0;
wire [7:0] cfgReg1;
wire [7:0] cfgReg2;
wire [7:0] cfgReg3;
wire [7:0] cfgReg4;
wire [7:0] cfgReg5;
wire [7:0] cfgReg6;
wire [7:0] cfgReg7;
wire [7:0] cfgReg8;
wire [7:0] cfgReg9;
wire [7:0] cfgReg10;
wire [7:0] cfgReg11;
wire [7:0] cfgReg12;
wire [7:0] cfgReg13;
wire [7:0] cfgReg14;
wire [7:0] cfgReg15;

initial begin
$dumpfile("wave.vcd");
$dumpvars(0, testHarness); 
end

dfe_top u_dfe_top (
  .clk(clk),
  .rst(rst),
  .sda_pad_i(sda),
  .sda_pad_o(sda_from_dfe),
  .scl_pad_i(scl),
  .sens_data_i(sens_data_i),
  .sens_data_i_val(sens_data_i_val),
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
  .cfgReg15(cfgReg15)
);

i2c_master_top #(.ARST_LVL(1'b1)) u_i2c_master_top (
  .wb_clk_i(clk), 
  .wb_rst_i(rst),
  .arst_i(rst),
  .wb_adr_i(adr),
  .wb_dat_i(masterDout),
  .wb_dat_o(masterDin),
  .wb_we_i(we),
  .wb_stb_i(stb),
  .wb_cyc_i(cyc),
  .wb_ack_o(ack),
  .wb_inta_o(),
  .scl_pad_i(scl_pad_i),
  .scl_pad_o(scl_pad_o),
  .scl_padoen_o(scl_padoen_o),
  .sda_pad_i(sda_from_dfe),
  .sda_pad_o(sda_pad_o),
  .sda_padoen_o(sda_padoen_o)
);

wb_master_model #(.dwidth(8), .awidth(3)) u_wb_master_model (
  .clk(clk), 
  .rst(rst), 
  .adr(adr), 
  .din(masterDin), 
  .dout(masterDout), 
  .cyc(cyc), 
  .stb(stb), 
  .we(we), 
  .sel(), 
  .ack(ack), 
  .err(1'b0), 
  .rty(1'b0)
);

assign sda = (sda_padoen_o == 1'b0) ? sda_pad_o : 1'bz;
assign sda_pad_i = sda;
pullup(sda);

assign scl = (scl_padoen_o == 1'b0) ? scl_pad_o : 1'bz;
assign scl_pad_i = scl;
pullup(scl);


// ******************************  Clock section  ******************************
//approx 48MHz clock
`define CLK_HALF_PERIOD 10
always begin
  #`CLK_HALF_PERIOD clk <= 1'b0;
  #`CLK_HALF_PERIOD clk <= 1'b1;
end


// ******************************  reset  ****************************** 
task reset;
begin
  rst <= 1'b1;
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  rst <= 1'b0;
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
end
endtask

// ******************************  sensor write ****************************** 
initial
    begin
sens_data_i = 0;
sens_data_i_val = 0;
end


task sensor_write(input [7:0]d);
begin
    sens_data_i = d;
    sens_data_i_val = 1'b1;

    # 50
    sens_data_i_val = 1'b0;
end
endtask

endmodule
