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
reg [7:0] sensor_values [0:9];

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
  $write("# ----- Testing sensor read/write -----#\n");
  $write("# ----- Configure sens_mode register to read latest sensed value-----#\n");
  multiByteReadWrite.write({`I2C_ADDRESS, 1'b0}, 8'hF0, 8'h0A, `SEND_STOP);
  $write("# Sensor writing data\n");
  sensor_values[0] = 8'hAB;
  sensor_values[1] = 8'hCD;
  sensor_values[2] = 8'hEF;
  sensor_values[3] = 8'hFA;
  sensor_values[4] = 8'hED;
  sensor_values[5] = 8'hCB;
  sensor_values[6] = 8'hAA;
  sensor_values[7] = 8'hBB;
  sensor_values[8] = 8'hCC;
  sensor_values[9] = 8'hDD;

 for (i = 0; i < 10; i = i + 1) begin
    #1000;
    testHarness.sensor_write(sensor_values[i]);
  end

  #1000
  $write("# Reading latest sensed value .. \n");
  multiByteReadWrite.read({`I2C_ADDRESS, 1'b0}, 8'hF1, 8'hDD, dataWord, `NULL);

  #1000
  $write("# ----- Configure sens_mode register to stream the buffer -----#\n");
  multiByteReadWrite.write({`I2C_ADDRESS, 1'b0}, 8'hF0, 8'h0C, `SEND_STOP);
  #1000
  $write("# stream out buffer .. \n");
  multiByteReadWrite.read_stream({`I2C_ADDRESS, 1'b0}, 8'hF1, dataWord,`NULL,10);
  
  $write("Finished all tests\n");
  $stop;	

end

endmodule

