`timescale 1ns / 1ps

module dff_tb;

reg clk;
reg rst;
reg D;
wire Q;
wire Qb;

dff_glitch dut (
    .clk(clk),
    .rst(rst),
    .D(D),
    .Q(Q),
    .Qb(Qb)
);

always #5 clk = ~clk;

initial begin

    clk = 1'b0;
    rst = 1'b0;
    D   = 1'b0;

    #12 rst = 1'b1;
    #12 rst = 1'b0;

    #12 D = 1'b1;
    #12 D = 1'b0;
    #12 D = 1'b1;
    #50 D = 1'b0;

    #10 $finish;

end

initial begin

    $monitor("Time=%0t rst=%b D=%b Q=%b Qb=%b",
             $time, rst, D, Q, Qb);

end

endmodule
