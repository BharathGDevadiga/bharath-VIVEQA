`timescale 1ns/1ps

module led_controller #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer BLINK_HZ = 2
) (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] status,
    input  wire        alarm,
    output reg  [15:0] led
);
    localparam integer BLINK_DIV = (CLK_HZ / (BLINK_HZ * 2) > 0) ?
                                   (CLK_HZ / (BLINK_HZ * 2)) : 1;
    localparam integer COUNT_W = (BLINK_DIV <= 1) ? 1 : $clog2(BLINK_DIV);
    reg [COUNT_W-1:0] count;
    reg blink;

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            blink <= 1'b0;
            led <= 16'd0;
        end else begin
            if (count == BLINK_DIV - 1) begin
                count <= 0;
                blink <= ~blink;
            end else
                count <= count + 1'b1;
            led <= status;
            if (alarm)
                led[15] <= blink;
        end
    end
endmodule
