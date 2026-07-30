`timescale 1ns/1ps

module buzzer_controller #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer TONE_HZ = 2_000 // Not used for active buzzer
) (
    input  wire clk,
    input  wire reset,
    input  wire alarm,
    input  wire enable,
    output reg  buzzer
);

    reg [22:0] pulse_counter;
    wire pwm_pulse = pulse_counter[12]; // ~2.9 kHz tone

    always @(posedge clk) begin
        if (reset) begin
            pulse_counter <= 23'd0;
            buzzer <= 1'b0;
        end else begin
            pulse_counter <= pulse_counter + 1'b1;
            // Medium-Power Mode: 25% duty cycle chirp at ~2.8 Hz cadence
            buzzer <= (alarm && enable && pulse_counter[22] && pulse_counter[21] && pwm_pulse);
        end
    end
endmodule
