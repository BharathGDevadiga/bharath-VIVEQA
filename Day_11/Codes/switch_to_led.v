`timescale 1ns / 1ps

module led_boardproj(
  
    input  [7:0] switch,
    output [7:0] led
);

assign led = switch;

endmodule
