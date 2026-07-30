`timescale 1ns/1ps

module motor_driver #(
    parameter integer PWM_BITS = 8
) (
    input  wire                clk,
    input  wire                reset,
    input  wire                authorized,
    input  wire                motor_enable,
    input  wire [1:0]          motor_command,
    input  wire [PWM_BITS-1:0] speed,
    output reg                 in1,
    output reg                 in2,
    output reg                 denied
);
    reg [PWM_BITS-1:0] pwm_count;
    wire pwm_on = (pwm_count < speed);

    always @(posedge clk) begin
        if (reset) begin
            pwm_count <= 0;
            in1 <= 1'b0;
            in2 <= 1'b0;
            denied <= 1'b0;
        end else begin
            pwm_count <= pwm_count + 1'b1;
            denied <= motor_enable && !authorized;
            if (!motor_enable || !authorized) begin
                in1 <= 1'b0;
                in2 <= 1'b0;
            end else begin
                case (motor_command)
                    2'b01: begin in1 <= pwm_on; in2 <= 1'b0; end
                    2'b10: begin in1 <= 1'b0; in2 <= pwm_on; end
                    2'b11: begin in1 <= 1'b1; in2 <= 1'b1; end
                    default: begin in1 <= 1'b0; in2 <= 1'b0; end
                endcase
            end
        end
    end
endmodule
