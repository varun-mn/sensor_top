`include "i2cSlave_define.v"

// 16 config registers to configure AFE 					(address map 8'h00 to 8'h0F)
// sensMode register to configure sensors mode of operation 			(address map 8'hF0)
// 1 sense register to store sensor output 					(address map 8'hF1)
// TODO , Parametrise hardcoded num num registers and memory map.

module registerInterface (
  clk,
  rst_n,
  addr,
  dataIn,
  writeEn,
  dataOut,
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
  cfgReg15,
  sens_mode, 
  sens_data_i 
);

input clk , rst_n;
input [7:0] addr;
input [7:0] dataIn;
input writeEn;
output reg [7:0] dataOut;
input [7:0] sens_data_i;
output [7:0] sens_mode;
output reg [7:0] cfgReg0 ,cfgReg1 ,cfgReg2 ,cfgReg3 ,cfgReg4 ,cfgReg5 ,cfgReg6 ,cfgReg7 ,cfgReg8 ,cfgReg9 ,cfgReg10 ,cfgReg11 ,cfgReg12 ,cfgReg13 ,cfgReg14 ,cfgReg15;
reg [7:0] sensValue;
reg [7:0] sensMode;

// --- I2C Read
always @(posedge clk) begin
  case (addr)
    8'h00: dataOut <= cfgReg0;  
    8'h01: dataOut <= cfgReg1;  
    8'h02: dataOut <= cfgReg2;  
    8'h03: dataOut <= cfgReg3;  
    8'h04: dataOut <= cfgReg4;  
    8'h05: dataOut <= cfgReg5;  
    8'h06: dataOut <= cfgReg6;  
    8'h07: dataOut <= cfgReg7;  
    8'h08: dataOut <= cfgReg8;  
    8'h09: dataOut <= cfgReg9;  
    8'h0A: dataOut <= cfgReg10;  
    8'h0B: dataOut <= cfgReg11;  
    8'h0C: dataOut <= cfgReg12;  
    8'h0D: dataOut <= cfgReg13;  
    8'h0E: dataOut <= cfgReg14;  
    8'h0F: dataOut <= cfgReg15;  
    8'hF0: dataOut <= sensMode;  
    8'hF1: dataOut <= sensValue;  
    default: dataOut <= 8'h00;
  endcase
end

// --- I2C Write
// TODO : May need to add default states for cfg registers on reset , 
// parameter list have default config values of AFE.

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
      cfgReg0 <= 8'h00;
      cfgReg1 <= 8'h00;
      cfgReg2 <= 8'h00;
      cfgReg3 <= 8'h00;
      cfgReg4 <= 8'h00;
      cfgReg5 <= 8'h00;
      cfgReg6 <= 8'h00;
      cfgReg7 <= 8'h00;
      cfgReg8 <= 8'h00;
      cfgReg9 <= 8'h00;
      cfgReg10 <= 8'h00;
      cfgReg11 <= 8'h00;
      cfgReg12 <= 8'h00;
      cfgReg13 <= 8'h00;
      cfgReg14 <= 8'h00;
      cfgReg15 <= 8'h00;
      sensMode <= 8'h00;
  end else if (writeEn == 1'b1) begin
    case (addr)
      8'h00: cfgReg0 <= dataIn;  
      8'h01: cfgReg1 <= dataIn;
      8'h02: cfgReg2 <= dataIn;
      8'h03: cfgReg3 <= dataIn;
      8'h04: cfgReg4 <= dataIn;
      8'h05: cfgReg5 <= dataIn;
      8'h06: cfgReg6 <= dataIn;
      8'h07: cfgReg7 <= dataIn;
      8'h08: cfgReg8 <= dataIn;
      8'h09: cfgReg9 <= dataIn;
      8'h0A: cfgReg10 <= dataIn;
      8'h0B: cfgReg11 <= dataIn;
      8'h0C: cfgReg12 <= dataIn;
      8'h0D: cfgReg13 <= dataIn;
      8'h0E: cfgReg14 <= dataIn;
      8'h0F: cfgReg15 <= dataIn;
      8'hF0: sensMode <= dataIn;
    endcase
  end
end

// Write sensed value to reg
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sensValue <= 8'h00;
  end else begin
    sensValue <= sens_data_i;
  end
end

assign sens_mode = sensMode;

endmodule
