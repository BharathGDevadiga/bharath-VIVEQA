`timescale 1ns / 1ps

module PISO_tb;

reg clk;
reg rst;
reg load;
reg shift;
reg [3:0] data_in;

wire data_out;

PISO dut(
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .load(load),
    .shift(shift),
    .data_out(data_out)
);

// 100 MHz clock
always #5 clk = ~clk;

initial begin
  
    clk = 0;
    rst = 1;
    load = 0;
    shift = 0;
    data_in = 4'b1010;

    // Reset
    #20;
    rst = 0;

    // Load data
    #10;
    load = 1;
    #10;
    load = 0;

    // Shift Bit 0
    #10 shift = 1;
    #10 shift = 0;

    // Shift Bit 1
    #20 shift = 1;
    #10 shift = 0;

    // Shift Bit 2
    #20 shift = 1;
    #10 shift = 0;

    // Shift Bit 3
    #20 shift = 1;
    #10 shift = 0;

    #20;
    $finish;
  
end

initial begin
  
    $monitor("Time=%0t Load=%b Shift=%b Data=%b Serial=%b",
             $time, load, shift, data_in, data_out);
  
end

endmodule
