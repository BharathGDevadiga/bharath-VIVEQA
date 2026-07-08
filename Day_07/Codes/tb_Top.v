`timescale 1ns / 1ps

module tb_Top;

reg clk;
reg reset;
reg a;
reg b;
reg [1:0] m;

wire q;
wire qb;

Top uut (
    .clk(clk),
    .reset(reset),
    .a(a),
    .b(b),
    .m(m),
    .q(q),
    .qb(qb)
);

// Clock Generation
always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;
    a = 0;
    b = 0;
    m = 2'b00;

    #10 reset = 0;

    // -------------------------
    // D Flip-Flop (m = 00)
    // -------------------------
    m = 2'b00;

    #10 a = 1;
    #10 a = 0;
    #10 a = 1;

    // -------------------------
    // T Flip-Flop (m = 01)
    // -------------------------
    #10 m = 2'b01;

    #10 a = 1;
    #10 a = 1;
    #10 a = 0;
    #10 a = 1;

    // -------------------------
    // JK Flip-Flop (m = 10)
    // -------------------------
    #10 m = 2'b10;

    // J=0 K=0 (Hold)
    #10 a = 0; b = 0;

    // J=1 K=0 (Set)
    #10 a = 1; b = 0;

    // J=0 K=1 (Reset)
    #10 a = 0; b = 1;

    // J=1 K=1 (Toggle)
    #10 a = 1; b = 1;
    #10 a = 1; b = 1;

    #20 $finish;
end

initial begin
    $monitor("Time=%0t | m=%b | a=%b | b=%b | q=%b | qb=%b",
             $time, m, a, b, q, qb);
end

endmodule
