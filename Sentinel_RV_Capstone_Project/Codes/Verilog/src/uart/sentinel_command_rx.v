`timescale 1ns/1ps

module sentinel_command_rx (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] rx_data,
    input  wire       rx_valid,
    output reg        cmd_valid,
    output reg [7:0]  cmd_opcode,
    output reg [7:0]  cmd_sequence,
    output reg [15:0] cmd_argument,
    output reg        cmd_error
);
    localparam [7:0] SOF = 8'hA5;
    reg [2:0] byte_count;
    reg [7:0] checksum;

    always @(posedge clk) begin
        if (reset) begin
            byte_count   <= 3'd0;
            checksum     <= 8'd0;
            cmd_valid    <= 1'b0;
            cmd_error    <= 1'b0;
            cmd_opcode   <= 8'd0;
            cmd_sequence <= 8'd0;
            cmd_argument <= 16'd0;
        end else begin
            cmd_valid <= 1'b0;
            cmd_error <= 1'b0;
            if (rx_valid) begin
                if (byte_count == 3'd0) begin
                    if (rx_data == SOF) begin
                        byte_count <= 3'd1;
                        checksum <= SOF;
                    end
                end else if (rx_data == SOF) begin
                    byte_count <= 3'd1;
                    checksum <= SOF;
                end else begin
                    case (byte_count)
                        3'd1: begin cmd_opcode <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd2; end
                        3'd2: begin cmd_sequence <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd3; end
                        3'd3: begin cmd_argument[15:8] <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd4; end
                        3'd4: begin cmd_argument[7:0] <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd5; end
                        default: begin
                            if (rx_data == checksum)
                                cmd_valid <= 1'b1;
                            else
                                cmd_error <= 1'b1;
                            byte_count <= 3'd0;
                        end
                    endcase
                end
            end
        end
    end
endmodule
