// ---------------------------------- testcase0.v ----------------------------
`include "timescale.v"
`include "i2cSlave_define.v"
`include "i2cSlaveTB_defines.v"

module testCase1();

reg ack;
reg [7:0] data;
reg [7:0] dataWord;
reg [7:0] dataRead;
reg [7:0] dataWrite;
integer i;
integer j;

initial
begin
  $write("\n\n");
  testHarness.reset;
  #1000;

  // set i2c master clock scale reg PRER = (48MHz / (5 * 400KHz) ) - 1
  $write("# ----- Testing config register read/write -----#\n");
  testHarness.u_wb_master_model.wb_write(1, `PRER_LO_REG , 8'h17);
  testHarness.u_wb_master_model.wb_write(1, `PRER_HI_REG , 8'h00);
  testHarness.u_wb_master_model.wb_cmp(1, `PRER_LO_REG , 8'h17);

  // enable i2c master
  testHarness.u_wb_master_model.wb_write(1, `CTR_REG , 8'h80);

  multiByteReadWrite.write({`I2C_ADDRESS, 1'b0}, 8'h00, 8'h11, `SEND_STOP);
  multiByteReadWrite.write({`I2C_ADDRESS, 1'b0}, 8'h01, 8'h22, `SEND_STOP);
  multiByteReadWrite.write({`I2C_ADDRESS, 1'b0}, 8'h02, 8'h33, `SEND_STOP);
  multiByteReadWrite.write({`I2C_ADDRESS, 1'b0}, 8'h03, 8'h44, `SEND_STOP);
  multiByteReadWrite.read({`I2C_ADDRESS, 1'b0}, 8'h00, 8'h11, dataWord, `NULL);
  multiByteReadWrite.read({`I2C_ADDRESS, 1'b0}, 8'h01, 8'h22, dataWord, `NULL);
  multiByteReadWrite.read({`I2C_ADDRESS, 1'b0}, 8'h02, 8'h33, dataWord, `NULL);
  multiByteReadWrite.read({`I2C_ADDRESS, 1'b0}, 8'h03, 8'h44, dataWord, `NULL);
  //multiByteReadWrite.read({`I2C_ADDRESS, 1'b0}, 8'h04, 32'h12345678, dataWord, `NULL);
  

  // Sensor writes data
  multiByteReadWrite.write({`I2C_ADDRESS, 1'b0}, 8'hF0, 8'h0A, `SEND_STOP);
  $write("# ----- Testing sensor read/write -----#\n");
  $write("# Sensor writing data\n");
  #10000
  testHarness.sensor_write(8'hAB);
  #10000
  testHarness.sensor_write(8'hCD);
  #10000
  testHarness.sensor_write(8'hEF);
  #10000
  testHarness.sensor_write(8'hFA);
  #10000
  testHarness.sensor_write(8'hED);
  #10000
  testHarness.sensor_write(8'hCB);
  #10000
  $write("# Reading latest sensed value .. \n");
  multiByteReadWrite.read({`I2C_ADDRESS, 1'b0}, 8'hF1, 8'hCB, dataWord, `NULL);

  $write("Finished all tests\n");
  $stop;	

end

endmodule

