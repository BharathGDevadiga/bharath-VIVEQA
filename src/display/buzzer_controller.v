`timescale 1ns/1ps

module buzzer_controller #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer TONE_HZ = 2_000
) (
    input  wire clk,
    input  wire reset,
    input  wire alarm,
    input  wire enable,
    output reg  buzzer
);
    localparam integer HALF_DIV = (CLK_HZ / (TONE_HZ * 2) > 0) ?
                                  (CLK_HZ / (TONE_HZ * 2)) : 1;
    localparam integer COUNT_W = (HALF_DIV <= 1) ? 1 : $clog2(HALF_DIV);
    reg [COUNT_W-1:0] count;

    always @(posedge clk) begin
        if (reset || !enable || !alarm) begin
            count <= 0;
            buzzer <= 1'b0;
        end else if (count == HALF_DIV - 1) begin
            count <= 0;
            buzzer <= ~buzzer;
        end else
            count <= count + 1'b1;
    end
endmodule
