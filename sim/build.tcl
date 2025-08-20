iverilog -o tb_streaming_fifo.vcd tb_streaming_fifo.v streaming_fifo.v 
vvp tb_streaming_fifo.vcd
gtkwave tb_streaming_fifo.vcd my_waves.sav
