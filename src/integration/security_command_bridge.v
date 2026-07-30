`timescale 1ns/1ps

// Converts Team 2's transport-decoded command into one security-core request.
// The bridge accepts only one outstanding command, preventing the replay FSM
// from being bypassed by back-to-back UART traffic.
module security_command_bridge (
    input  wire        clk,
    input  wire        reset,
    input  wire        team2_valid,
    output wire        team2_ready,
    input  wire [7:0]  team2_opcode,
    input  wire [7:0]  team2_sequence,
    input  wire [15:0] team2_argument,
    input  wire        team2_source,
    output reg         security_packet_valid,
    output reg [63:0]  security_nonce,
    input  wire        security_accepted,
    input  wire        security_rejected,
    output reg         result_valid,
    output reg         result_accepted,
    output reg [7:0]   result_opcode,
    output reg [15:0]  result_argument
);
    reg pending;
    reg [7:0] opcode_reg;
    reg [15:0] argument_reg;

    assign team2_ready = !pending;

    always @(posedge clk) begin
        if (reset) begin
            pending <= 1'b0;
            security_packet_valid <= 1'b0;
            security_nonce <= 64'd0;
            result_valid <= 1'b0;
            result_accepted <= 1'b0;
            result_opcode <= 8'd0;
            result_argument <= 16'd0;
            opcode_reg <= 8'd0;
            argument_reg <= 16'd0;
        end else begin
            security_packet_valid <= 1'b0;
            result_valid <= 1'b0;
            if (!pending && team2_valid) begin
                pending <= 1'b1;
                opcode_reg <= team2_opcode;
                argument_reg <= team2_argument;
                // The nonce binds transport source, sequence, opcode, and data.
                security_nonce <= {31'd0, team2_source, team2_sequence, team2_opcode, team2_argument};
                security_packet_valid <= 1'b1;
            end else if (pending && (security_accepted || security_rejected)) begin
                pending <= 1'b0;
                result_valid <= 1'b1;
                result_accepted <= security_accepted;
                result_opcode <= opcode_reg;
                result_argument <= argument_reg;
            end
        end
    end
endmodule
