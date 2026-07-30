`timescale 1ns/1ps

module baud_gen #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer BAUD = 115_200,
    parameter integer OVERSAMPLE = 16
) (
    input  wire clk,
    input  wire reset,
    output reg  tick
);
    localparam integer DIVISOR = (CLK_HZ / (BAUD * OVERSAMPLE) > 0) ?
                               (CLK_HZ / (BAUD * OVERSAMPLE)) : 1;
    localparam integer COUNT_W = (DIVISOR <= 1) ? 1 : $clog2(DIVISOR);

    reg [COUNT_W-1:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count <= {COUNT_W{1'b0}};
            tick  <= 1'b0;
        end else if (count == DIVISOR - 1) begin
            count <= {COUNT_W{1'b0}};
            tick  <= 1'b1;
        end else begin
            count <= count + 1'b1;
            tick  <= 1'b0;
        end
    end
endmodule
