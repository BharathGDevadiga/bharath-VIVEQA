`timescale 1ns/1ps

module esp32_packet_parser (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] rx_data,
    input  wire       rx_valid,
    output reg        message_valid,
    output reg [7:0]  message_type,
    output reg [15:0] message_value,
    output reg        message_error
);
    localparam [7:0] SOF = 8'hE3;
    reg [2:0] byte_count;
    reg [7:0] checksum;

    always @(posedge clk) begin
        if (reset) begin
            byte_count <= 3'd0;
            checksum <= 8'd0;
            message_valid <= 1'b0;
            message_error <= 1'b0;
            message_type <= 8'd0;
            message_value <= 16'd0;
        end else begin
            message_valid <= 1'b0;
            message_error <= 1'b0;
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
                        3'd1: begin message_type <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd2; end
                        3'd2: begin message_value[15:8] <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd3; end
                        3'd3: begin message_value[7:0] <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd4; end
                        default: begin
                            if (rx_data == checksum)
                                message_valid <= 1'b1;
                            else
                                message_error <= 1'b1;
                            byte_count <= 3'd0;
                        end
                    endcase
                end
            end
        end
    end
endmodule
