// ------------------ multiByteReadWrite.v ----------------------
`include "timescale.v"
`include "i2cSlaveTB_defines.v"


module multiByteReadWrite();
reg ack;
reg [7:0] readData;
reg [7:0] dataByteRead;
//reg [7:0] dataMSB;

// ------------------ write ----------------------
task write;
input [7:0] i2cAddr;
input [7:0] regAddr;
input [7:0] data;
input stop;

begin
  $write("I2C Write: At [0x%0x] = 0x%0x\n", regAddr, data);

  //i2c address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, i2cAddr);
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h90); //STA, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("I2C device address sent, SR = 0x%x\n", dataByteRead );

  //slave reg address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, regAddr);
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h10); //WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Slave reg address sent, SR = 0x%x\n", dataByteRead );

  //data[7:0]
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, data[7:0]);
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , {1'b0, stop, 6'b010000}); //STO?, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Data[7:0] sent, SR = 0x%x\n", dataByteRead );

end
endtask

// ------------------ read ----------------------
task read;
input [7:0] i2cAddr;
input [7:0] regAddr;
input [7:0] expectedData;
output [7:0] data;
input stop;

begin

  //i2c address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, i2cAddr);  //write
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h90); //STA, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("I2C device address sent, SR = 0x%x\n", dataByteRead );
  #5000;

  //slave reg address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, regAddr);
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , {1'b0, stop, 6'b010000}); //STO?, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Slave reg address sent, SR = 0x%x\n", dataByteRead );
  #5000;

  //i2c address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, {i2cAddr[7:1], 1'b1}); //read
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h90); //STA, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("I2C device address sent, SR = 0x%x\n", dataByteRead );

  //data[7:0]
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , {1'b0, 1'b0, 6'b101000}); //STO, RD, NAK
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Data[7:0] rxed, SR = 0x%x\n", dataByteRead );
  testHarness.u_wb_master_model.wb_read(1, `RXR_REG, readData[7:0]);

  data = readData; 
  if (data != expectedData) begin
    $write("***** I2C Read ERROR: At 0x%0x. Expected 0x%0x, got 0x%0x\n", regAddr, expectedData, data);
    //$stop;
  end
  else
    $write("I2C Read                : At [0x%0x] = 0x%0x\n", regAddr, data);
    $write("Success , Expected Data : At [0x%0x] = 0x%0x\n", regAddr, expectedData);
end
endtask

task read_stream;
input [7:0] i2cAddr;
input [7:0] regAddr;
//input [7:0] expectedData;
output [7:0] data;
input stop;
input integer num_reads;
integer i;
reg [7:0] sensor_values [0:9];
begin
  
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

  //i2c address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, i2cAddr);  //write
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h90); //STA, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("I2C device address sent, SR = 0x%x\n", dataByteRead );
  #5000;

  //slave reg address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, regAddr);
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , {1'b0, stop, 6'b010000}); //STO?, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Slave reg address sent, SR = 0x%x\n", dataByteRead );
  #5000;

  //i2c address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, {i2cAddr[7:1], 1'b1}); //read
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h90); //STA, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("I2C device address sent, SR = 0x%x\n", dataByteRead );

 for (i = 0; i < num_reads; i = i + 1) begin
  //data[31:24]
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h20); //RD, ACK
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Data[31:24] rxed, SR = 0x%x\n", dataByteRead );
  testHarness.u_wb_master_model.wb_read(1, `RXR_REG, readData[7:0]);

  data = readData; 
  if (data != sensor_values[i]) begin
    $write("***** I2C Read ERROR: At 0x%0x. Expected 0x%0x, got 0x%0x\n", regAddr, sensor_values[i], data);
    //$stop;
  end
  else
    $write("I2C Read                : At [0x%0x] = 0x%0x\n", regAddr, data);
    $write("Success , Expected Data : At [0x%0x] = 0x%0x\n", regAddr, sensor_values[i]);
  end
 end
endtask

endmodule
