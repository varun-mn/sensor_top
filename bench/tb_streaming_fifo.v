`timescale 1ns/1ps

module tb_streaming_fifo;

  // Parameters
  localparam DATA_WIDTH = 8;
  localparam DEPTH = 4;
  localparam ADDR_WIDTH = 2;              // log2(64)

  // DUT signals
  reg clk;
  reg rst_n;
  reg wr_en;
  reg [DATA_WIDTH-1:0] wr_data;
  reg rd_en;
  wire [DATA_WIDTH-1:0] rd_data;
  wire full,empty;

  // Instantiate DUT
  streaming_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .rd_en(rd_en),
    .rd_data(rd_data),
    .full(full),
    .empty(empty)
  );

  // Dump waves for GTKWave
  initial begin
    $dumpfile("tb_streaming_fifo.vcd");   // name of VCD
    $dumpvars(0, tb_streaming_fifo);      // dump everything in testbench + DUT
  end


  // Clock gen
  always #5 clk = ~clk; // 100 MHz

  // Reference model (queue)
  reg [DATA_WIDTH-1:0] model_q [0:DEPTH*2];
  integer wr_ptr_model = 0;
  integer rd_ptr_model = 0;

  // Tasks
  task do_write(input [DATA_WIDTH-1:0] data);
  begin
    @(posedge clk);
    wr_en   <= 1;
    wr_data <= data;
    rd_en   <= 0;
    model_q[wr_ptr_model] = data;
    wr_ptr_model = wr_ptr_model + 1;
    @(posedge clk);
    wr_en   <= 0;
  end
  endtask

  task do_read;
  begin
    @(posedge clk);
    wr_en <= 0;
    rd_en <= 1;
    @(posedge clk);
      if (rd_data !== model_q[rd_ptr_model]) begin
        $error("Mismatch: expected %0h, got %0h at time %t",
               model_q[rd_ptr_model], rd_data, $time);
      end else begin
        $display("Read OK: %0h at time %t", rd_data, $time);
      end
      rd_ptr_model = rd_ptr_model + 1;
    rd_en <= 0;
  end
  endtask
  
  task do_write_read(input [DATA_WIDTH-1:0] data);
   begin
   @(posedge clk);
    wr_en <= 1;
    rd_en <= 1;
    wr_data <= data;
    model_q[wr_ptr_model] = data;
    wr_ptr_model = wr_ptr_model + 1;
    rd_ptr_model = rd_ptr_model + 1;
   @(posedge clk);
    wr_en <= 0;
    rd_en <= 0;
   end
  endtask


  // Stimulus
  initial begin
    clk   = 0;
    rst_n = 0;
    wr_en = 0;
    rd_en = 0;
    wr_data = 0;

    // Reset
    repeat (2) @(posedge clk);
    rst_n = 1;

    // Test 1: simple write-read
    do_write(8'hA1);
    do_write(8'hB2);
    do_write(8'hC3);
    do_write(8'hD4);
    do_write(8'hE5);
    do_write(8'hF6);

    do_read();
    do_read();
    do_read();
 
    do_write_read(8'hA7);
    do_write_read(8'hB8);
    do_write_read(8'hC9);
    do_read();
    do_read();
    do_read();

    // // Test 2: overflow scenario
    // repeat (DEPTH+2) do_write($random);

    // repeat (DEPTH+2) do_read();

    // End sim
    #50;
    $finish;
  end

  // Debug monitor for pointers
  initial begin
    $monitor("T=%0t wr_ptr=%0d rd_ptr=%0d",
              $time, dut.wr_ptr, dut.rd_ptr);
  end

endmodule
