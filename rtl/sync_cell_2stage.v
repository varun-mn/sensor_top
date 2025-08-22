module sync_cells_2stage (
  input  async_in,
  input  clk,
  input  rst_n,
  output sync_out
);

reg [1:0] internal_sync;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    internal_sync[1:0] <= 2'b00;
  end else begin  
    internal_sync[1:0] <= {internal_sync[0], async_in};
  end
end

assign sync_out = internal_sync[1];

endmodule
