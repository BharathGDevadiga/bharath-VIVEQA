`timescale 1ns/1ps

module digital_clock_tb;

reg clk_24mhz;

wire seg_cs;
wire seg_clk;
wire seg_din;

digital_clock uut(
    .clk_24mhz(clk_24mhz),
    .seg_cs(seg_cs),
    .seg_clk(seg_clk),
    .seg_din(seg_din)
);

// 24 MHz clock
initial begin
  
    clk_24mhz = 0;
    forever #20.833 clk_24mhz = ~clk_24mhz;
  
end

// Monitor signals
initial begin
    $monitor("Time = %0t | CLK = %b | CS = %b | SCLK = %b | DIN = %b",
              $time,clk_24mhz,seg_cs,seg_clk,seg_din);

    #50000; $stop;
  
end

endmodule
