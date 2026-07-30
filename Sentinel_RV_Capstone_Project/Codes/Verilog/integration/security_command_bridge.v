`timescale 1ns/1ps

// Converts transport-decoded command into one security-core request.
// The bridge accepts only one outstanding command, preventing the replay FSM
// from being bypassed by back-to-back UART traffic.
module security_command_bridge (
    input  wire        clk,
    input  wire        reset,
    input  wire        transport_cmd_valid,
    output wire        transport_cmd_ready,
    input  wire [7:0]  transport_cmd_opcode,
    input  wire [7:0]  transport_cmd_sequence,
    input  wire [15:0] transport_cmd_argument,
    input  wire [7:0]  transport_cmd_source_id,
    output reg         security_packet_valid,
    output reg [63:0]  security_nonce,
    input  wire        security_accepted,
    input  wire        security_rejected,
    output reg         result_valid,
    output reg         result_accepted,
    output reg [7:0]   result_opcode,
    output reg [15:0]  result_argument,
    output reg [7:0]   result_sequence,
    output reg [7:0]   result_source_id
);
    reg pending;
    reg [7:0] opcode_reg;
    reg [15:0] argument_reg;
    reg [7:0] sequence_reg;
    reg [7:0] source_id_reg;

    assign transport_cmd_ready = !pending;

    always @(posedge clk) begin
        if (reset) begin
            pending <= 1'b0;
            security_packet_valid <= 1'b0;
            security_nonce <= 64'd0;
            result_valid <= 1'b0;
            result_accepted <= 1'b0;
            result_opcode <= 8'd0;
            result_argument <= 16'd0;
            result_sequence <= 8'd0;
            result_source_id <= 8'd0;
            opcode_reg <= 8'd0;
            argument_reg <= 16'd0;
            sequence_reg <= 8'd0;
            source_id_reg <= 8'd0;
        end else begin
            security_packet_valid <= 1'b0;
            result_valid <= 1'b0;
            if (!pending && transport_cmd_valid) begin
                pending <= 1'b1;
                opcode_reg <= transport_cmd_opcode;
                argument_reg <= transport_cmd_argument;
                sequence_reg <= transport_cmd_sequence;
                source_id_reg <= transport_cmd_source_id;
                security_nonce <= {24'd0, transport_cmd_source_id, transport_cmd_sequence, transport_cmd_opcode, transport_cmd_argument};
                security_packet_valid <= 1'b1;
            end else if (pending && (security_accepted || security_rejected)) begin
                pending <= 1'b0;
                result_valid <= 1'b1;
                result_accepted <= security_accepted;
                result_opcode <= opcode_reg;
                result_argument <= argument_reg;
                result_sequence <= sequence_reg;
                result_source_id <= source_id_reg;
            end
        end
    end
endmodule
