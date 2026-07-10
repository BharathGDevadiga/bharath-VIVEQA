`timescale 1ns / 1ps

module tb_up_counter_3bit;

reg clk;
reg rst;
wire [2:0] count;

// Instantiate the DUT
up_counter_3bit uut (
    .clk(clk),
    .rst(rst),
    .count(count)
);

// Clock generation (10 ns period)
always #5 clk = ~clk;

initial begin
  
    clk = 0;
    rst = 1;

    // Apply reset
    #10 rst = 0;

    // Run simulation
    #100;

    $finish;

end

initial begin
  
    $monitor("Time=%0t  Reset=%b  Count=%b (%0d)",
             $time, rst, count, count);
  
end

endmodule
