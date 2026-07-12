`timescale 1ns / 1ps

module async_up_tb;

reg clk;
reg rst;
wire [3:0] count;

async_up dut (
    .clk(clk),
    .rst(rst),
    .count(count)
);

always #5 clk = ~clk;

initial begin
  
    clk = 0;
    rst = 1;

    #10 rst = 0;

    #200 $finish;
  
end

initial begin
  
    $monitor("Time=%0t rst=%b count=%d (%b)",
             $time, rst, count, count);
  
end

endmodule
