`timescale 1ns/1ps

// Feed this monitor from an XADC Wizard or an XADC primitive adapter. The
// thresholds are raw 12-bit XADC codes and must be calibrated for the board.
module xadc_monitor #(
    parameter [11:0] VCCINT_MIN = 12'h500,
    parameter [11:0] VCCINT_MAX = 12'h600,
    parameter [11:0] TEMP_MAX = 12'hA00,
    parameter integer FAULT_SAMPLES = 2
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        sample_valid,
    input  wire [11:0] vccint_code,
    input  wire [11:0] temperature_code,
    input  wire        clear_alarm,
    output reg         glitch_event,
    output reg         alarm_latched,
    output reg [11:0]  last_vccint,
    output reg [11:0]  last_temperature
);
    localparam integer COUNT_W = (FAULT_SAMPLES <= 1) ? 1 : $clog2(FAULT_SAMPLES + 1);
    reg [COUNT_W-1:0] fault_count;
    wire out_of_range = (vccint_code < VCCINT_MIN) || (vccint_code > VCCINT_MAX) ||
                        (temperature_code > TEMP_MAX);

    always @(posedge clk) begin
        if (reset) begin
            glitch_event <= 1'b0;
            alarm_latched <= 1'b0;
            last_vccint <= 12'd0;
            last_temperature <= 12'd0;
            fault_count <= {COUNT_W{1'b0}};
        end else begin
            glitch_event <= 1'b0;
            if (clear_alarm && !out_of_range) begin
                alarm_latched <= 1'b0;
                fault_count <= {COUNT_W{1'b0}};
            end
            if (sample_valid) begin
                last_vccint <= vccint_code;
                last_temperature <= temperature_code;
                if (out_of_range) begin
                    if (fault_count < FAULT_SAMPLES)
                        fault_count <= fault_count + 1'b1;
                    if (fault_count == FAULT_SAMPLES - 1) begin
                        glitch_event <= 1'b1;
                        alarm_latched <= 1'b1;
                    end
                end else
                    fault_count <= {COUNT_W{1'b0}};
            end
        end
    end
endmodule
