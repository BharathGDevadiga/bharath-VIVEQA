`timescale 1ns / 1ps

module tb_jk_ff;

reg clk;
reg rst;
reg j;
reg k;

wire Q;
wire Qb;

jk_ff uut(
    .clk(clk),
    .rst(rst),
    .j(j),
    .k(k),
    .Q(Q),
    .Qb(Qb)
);

// Clock Generation
always #5 clk = ~clk;

initial begin
    
    clk = 0;
    rst = 1;
    j = 0;
    k = 0;

    // Apply Reset
    #10;
    rst = 0;

    // Hold
    j = 0;
    k = 0;
    #10;

    // Set
    j = 1;
    k = 0;
    #10;

    // Reset
    j = 0;
    k = 1;
    #10;

    // Toggle
    j = 1;
    k = 1;
    #10;

    // Toggle Again
    j = 1;
    k = 1;
    #10;

    // Hold
    j = 0;
    k = 0;
    #10;

    // Apply Reset Again
    rst = 1;
    #10;

    rst = 0;
    j = 1;
    k = 0;
    #10;

    $finish;
    
end

initial begin
    
    $monitor("Time=%0t clk=%b rst=%b j=%b k=%b Q=%b Qb=%b",
              $time, clk, rst, j, k, Q, Qb);
    
end

endmodule
