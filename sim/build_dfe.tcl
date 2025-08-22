iverilog  -o testHarness -c dfe_top_test.flist
vvp testHarness
gtkwave wave.vcd
 


