`timescale 1ns / 1ps

module tb_t_ff;

reg clk;
reg rst;
reg T;

wire Q;
wire Qb;

t_ff uut (
    .clk(clk),
    .rst(rst),
    .T(T),
    .Q(Q),
    .Qb(Qb)
);

// Clock Generation
always #5 clk = ~clk;

initial
begin
    clk = 0;
    rst = 1;
    T = 0;

    // Apply Reset
    #10;
    rst = 0;

    // Hold State
    T = 0;
    #20;

    // Toggle
    T = 1;
    #20;

    // Hold State
    T = 0;
    #20;

    // Toggle Again
    T = 1;
    #20;

    // Reset
    rst = 1;
    #10;

    rst = 0;
    T = 1;
    #20;

    $finish;
end

endmodule
