`timescale 1ns / 1ps

module tb_d_ff;

reg clk;
reg rst;
reg D;

wire Q;
wire Qb;

d_ff uut (
    .clk(clk),
    .rst(rst),
    .D(D),
    .Q(Q),
    .Qb(Qb)
);

// Clock Generation
always #5 clk = ~clk;

initial
begin
    clk = 0;
    rst = 1;
    D = 0;

    #10;
    rst = 0;

    D = 0;
    #10;

    D = 1;
    #10;

    D = 0;
    #10;

    D = 1;
    #10;

    rst = 1;
    #10;

    rst = 0;
    D = 1;
    #10;

    D = 0;
    #10;

    $finish;
end

endmodule
