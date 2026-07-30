`timescale 1ns/1ps

module crc32_mpeg2 (
    input wire clk, input wire reset, input wire start,
    input wire data_valid, input wire [7:0] data_byte, input wire data_last,
    output wire [31:0] crc, output wire busy, output wire crc_valid
);
    crc_stream #(.WIDTH(32), .POLY(32'h04C11DB7), .INIT(32'hFFFFFFFF)) engine (
        .clk(clk), .reset(reset), .start(start), .data_valid(data_valid), .data_byte(data_byte),
        .data_last(data_last), .crc(crc), .busy(busy), .crc_valid(crc_valid)
    );
endmodule
