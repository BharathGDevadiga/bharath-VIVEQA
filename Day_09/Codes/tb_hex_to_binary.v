`timescale 1ns / 1ps

module tb_hex_to_binary;

reg  [15:0] hex;
wire [3:0]  bin;

// Instantiate the DUT
hex_to_binary uut (
  
    .hex(hex),
    .bin(bin)
);

initial begin

    $monitor("Time=%0t | hex=%h | bin=%d", $time, hex, bin);

    // Test all valid one-hot inputs
    hex = 16'h0001; #10;   // 0
    hex = 16'h0002; #10;   // 1
    hex = 16'h0004; #10;   // 2
    hex = 16'h0008; #10;   // 3
    hex = 16'h0010; #10;   // 4
    hex = 16'h0020; #10;   // 5
    hex = 16'h0040; #10;   // 6
    hex = 16'h0080; #10;   // 7
    hex = 16'h0100; #10;   // 8
    hex = 16'h0200; #10;   // 9
    hex = 16'h0400; #10;   // 10
    hex = 16'h0800; #10;   // 11
    hex = 16'h1000; #10;   // 12
    hex = 16'h2000; #10;   // 13
    hex = 16'h4000; #10;   // 14
    hex = 16'h8000; #10;   // 15

    // Invalid input
    hex = 16'h0003; #10;

    // No input active
    hex = 16'h0000; #10;

    $finish;

end

endmodule
