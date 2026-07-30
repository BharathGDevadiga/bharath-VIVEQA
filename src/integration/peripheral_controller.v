`timescale 1ns/1ps

// Arbitration only: this module transports untrusted commands to Team 1 and
// broadcasts Team 1 telemetry to both outbound links.  It performs no access
// control and never asserts actuator authorization.
module peripheral_controller (
    input  wire       clk,
    input  wire       reset,
    input  wire       pmod_cmd_valid,
    input  wire [7:0] pmod_cmd_opcode,
    input  wire [7:0] pmod_cmd_sequence,
    input  wire [15:0] pmod_cmd_argument,
    input  wire       esp_cmd_valid,
    input  wire [7:0] esp_cmd_type,
    input  wire [15:0] esp_cmd_value,
    output reg        core_command_valid,
    input  wire       core_command_ready,
    output reg [7:0]  core_command_opcode,
    output reg [7:0]  core_command_sequence,
    output reg [15:0] core_command_argument,
    output reg        core_command_source,
    input  wire       core_telemetry_valid,
    output wire       core_telemetry_ready,
    input  wire [7:0] core_telemetry_sequence,
    input  wire [7:0] core_telemetry_event,
    input  wire [11:0] core_telemetry_sensor,
    input  wire [7:0] core_telemetry_status,
    output wire       telemetry_valid,
    input  wire       telemetry_ready,
    output wire [7:0] telemetry_sequence,
    output wire [7:0] telemetry_event,
    output wire [11:0] telemetry_sensor,
    output wire [7:0] telemetry_status
);
    assign telemetry_valid = core_telemetry_valid;
    assign core_telemetry_ready = telemetry_ready;
    assign telemetry_sequence = core_telemetry_sequence;
    assign telemetry_event = core_telemetry_event;
    assign telemetry_sensor = core_telemetry_sensor;
    assign telemetry_status = core_telemetry_status;

    always @(posedge clk) begin
        if (reset) begin
            core_command_valid <= 1'b0;
            core_command_opcode <= 8'd0;
            core_command_sequence <= 8'd0;
            core_command_argument <= 16'd0;
            core_command_source <= 1'b0;
        end else if (core_command_valid) begin
            if (core_command_ready)
                core_command_valid <= 1'b0;
        end else if (pmod_cmd_valid) begin
            core_command_valid <= 1'b1;
            core_command_opcode <= pmod_cmd_opcode;
            core_command_sequence <= pmod_cmd_sequence;
            core_command_argument <= pmod_cmd_argument;
            core_command_source <= 1'b0;
        end else if (esp_cmd_valid) begin
            core_command_valid <= 1'b1;
            core_command_opcode <= esp_cmd_type;
            core_command_sequence <= 8'h00;
            core_command_argument <= esp_cmd_value;
            core_command_source <= 1'b1;
        end
    end
endmodule
