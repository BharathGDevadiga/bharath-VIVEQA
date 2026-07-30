`timescale 1ns/1ps

module crc16_ccitt (
    input wire clk, input wire reset, input wire start,
    input wire data_valid, input wire [7:0] data_byte, input wire data_last,
    output wire [15:0] crc, output wire busy, output wire crc_valid
);
    crc_stream #(.WIDTH(16), .POLY(16'h1021), .INIT(16'hFFFF)) engine (
        .clk(clk), .reset(reset), .start(start), .data_valid(data_valid), .data_byte(data_byte),
        .data_last(data_last), .crc(crc), .busy(busy), .crc_valid(crc_valid)
    );
endmodule
