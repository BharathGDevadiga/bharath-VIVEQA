`timescale 1ns/1ps

module stepper_driver #(
    parameter integer CLK_HZ = 24_000_000
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       authorized,
    input  wire       start,
    input  wire       direction,
    input  wire [15:0] step_count,
    input  wire [23:0] step_period,
    output reg [3:0] stepper,
    output reg       busy,
    output reg       done,
    output reg       denied
);
    reg [23:0] period_count;
    reg [15:0] steps_left;
    reg [1:0] phase;

    function [3:0] coil_pattern;
        input [1:0] position;
        begin
            case (position)
                2'd0: coil_pattern = 4'b1001;
                2'd1: coil_pattern = 4'b0011;
                2'd2: coil_pattern = 4'b0110;
                default: coil_pattern = 4'b1100;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            period_count <= 0;
            steps_left <= 0;
            phase <= 0;
            stepper <= 0;
            busy <= 1'b0;
            done <= 1'b0;
            denied <= 1'b0;
        end else begin
            done <= 1'b0;
            denied <= 1'b0;
            if (!busy) begin
                stepper <= 4'b0000;
                if (start && authorized && step_count != 0) begin
                    busy <= 1'b1;
                    steps_left <= step_count;
                    period_count <= 0;
                    stepper <= coil_pattern(phase);
                end else if (start && !authorized)
                    denied <= 1'b1;
            end else if (period_count >= step_period) begin
                period_count <= 0;
                if (steps_left == 16'd1) begin
                    steps_left <= 0;
                    busy <= 1'b0;
                    stepper <= 4'b0000;
                    done <= 1'b1;
                end else begin
                    steps_left <= steps_left - 1'b1;
                    if (direction)
                        phase <= phase + 1'b1;
                    else
                        phase <= phase - 1'b1;
                    stepper <= coil_pattern(direction ? (phase + 1'b1) : (phase - 1'b1));
                end
            end else
                period_count <= period_count + 1'b1;
        end
    end
endmodule
