# sensor_top

Digital front end for the sensor IC , communicates with AFE / I2C master and manages internal modes :
* i2cSlaveTop            : communicates with master serially over sda/scl                           
* registerInterface      : holds sensed data from sensor & config registers for AFE/DFE
* currently supports 16 AFE config registers (address map 8'h00 to 8'h0F) 
* one 8 bit sensMode register to configure sensors mode of operation  (address map 8'hF0)
* sens_mode [RESERVED , RESERVED , RESERVED , RESERVED , GEN_IRQ , STREAM , LATEST , POWERDOWN]

* one 8 bit sense register to store sensor output (address map 8'hF1)

To Do:                                                       
* Parametrise hardcoded values for registers and memory map.
* Reset sync
* Interrupt requests

Open Tools :
* Icarus iverilog , gtkwave

Simulation:
* testbench : bench/testCase_sens_config_read.v
* sim       : sim/build_dfe.tcl
	* 1. I2C Write to config registers. 
	* 2. I2C Read from config registers.
	* 3. I2C master config sens_mode register & read latest sensed values.
	* 4. I2C master config sens_mode register & stream out buffer.
                                                            
Author(s): 
* Varun Nadiger , email : say.varun.mn@gmail.com 
