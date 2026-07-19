`timescale 1ns / 1ps

module frequency_divider_tb;

reg clk;
reg rst;

wire clk_out;

frequency_divider uut(

    .clk(clk),
    .rst(rst),
    .clk_out(clk_out)

);

always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 1;

    #20;
    rst = 0;

    #250000000;

    $finish;

end

initial begin

    $monitor("T=%0t rst=%b clk_out=%b",
             $time,rst,clk_out);

end

endmodule
