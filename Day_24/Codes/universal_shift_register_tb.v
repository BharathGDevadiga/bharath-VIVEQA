`timescale 1ns / 1ps

module universal_shift_register_tb;

reg clk;
reg rst;

reg [1:0] mode;

reg serial_left;
reg serial_right;

reg [3:0] parallel_in;

wire [3:0] q;

universal_shift_register uut(
    .clk(clk),
    .rst(rst),
    .mode(mode),
    .serial_left(serial_left),
    .serial_right(serial_right),
    .parallel_in(parallel_in),
    .q(q)

);

always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 1;

    mode = 2'b00;

    serial_left = 0;
    serial_right = 0;

    parallel_in = 4'b0000;

    #20;

    rst = 0;

    //=========================
    // Parallel Load
    //=========================

    mode = 2'b11;
    parallel_in = 4'b1010;

    #10;

    //=========================
    // Hold
    //=========================

    mode = 2'b00;

    #20;

    //=========================
    // Shift Right
    //=========================

    mode = 2'b01;

    serial_right = 1;

    #40;

    //=========================
    // Shift Left
    //=========================

    mode = 2'b10;

    serial_left = 0;

    #40;

    //=========================
    // Parallel Load
    //=========================

    mode = 2'b11;

    parallel_in = 4'b1100;

    #20;

    //=========================
    // Shift Left
    //=========================

    mode = 2'b10;

    serial_left = 1;

    #40;

    //=========================
    // Shift Right
    //=========================

    mode = 2'b01;

    serial_right = 0;

    #40;

    //=========================
    // Reset
    //=========================

    rst = 1;

    #20;

    rst = 0;

    #20;

    $finish;

end

initial begin

    $monitor("Time=%0t Reset=%b Mode=%b Parallel=%b SL=%b SR=%b Output=%b",
              $time,rst,mode,parallel_in,serial_left,serial_right,q);

end

endmodule
