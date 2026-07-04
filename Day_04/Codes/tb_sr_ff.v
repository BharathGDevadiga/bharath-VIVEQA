`timescale 1ns / 1ps

module tb_sr_ff;

reg clk;
reg rst;
reg s;
reg r;

wire Q;
wire Qb;

sr_ff uut(
    .clk(clk),
    .rst(rst),
    .s(s),
    .r(r),
    .Q(Q),
    .Qb(Qb)
);

// Clock Generation
always #5 clk = ~clk;

initial begin
  
    clk = 0;
    rst = 1;
    s = 0;
    r = 0;

    // Apply Reset
    #10;
    rst = 0;

    // Hold
    s = 0;
    r = 0;
    #10;

    // Set
    s = 1;
    r = 0;
    #10;

    // Reset
    s = 0;
    r = 1;
    #10;

    // Hold
    s = 0;
    r = 0;
    #10;

    // Invalid State
    s = 1;
    r = 1;
    #10;

    // Apply Reset Again
    rst = 1;
    #10;

    rst = 0;
    s = 1;
    r = 0;
    #10;

    $finish;
  
end

initial begin
  
    $monitor("Time=%0t clk=%b rst=%b s=%b r=%b Q=%b Qb=%b",
             $time, clk, rst, s, r, Q, Qb);
  
end

endmodule
