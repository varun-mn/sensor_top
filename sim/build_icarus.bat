iverilog  -o testHarness -c filelist.icarus
vvp testHarness
gtkwave wave.vcd myWave.sav

pause

