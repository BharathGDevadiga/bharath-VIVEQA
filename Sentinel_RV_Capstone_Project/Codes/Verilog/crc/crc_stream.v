`timescale 1ns/1ps

module crc_stream #(
    parameter integer WIDTH = 32,
    parameter [WIDTH-1:0] POLY = 32'h04C11DB7,
    parameter [WIDTH-1:0] INIT = {WIDTH{1'b1}}
) (
    input  wire             clk,
    input  wire             reset,
    input  wire             start,
    input  wire             data_valid,
    input  wire [7:0]       data_byte,
    input  wire             data_last,
    output reg  [WIDTH-1:0] crc,
    output reg              busy,
    output reg              crc_valid
);
    reg [WIDTH-1:0] current_crc;
    wire [WIDTH-1:0] updated_crc;
    assign updated_crc = update_crc(current_crc, data_byte);

    function automatic [WIDTH-1:0] update_crc;
        input [WIDTH-1:0] initial_crc;
        input [7:0] byte_value;
        reg [WIDTH-1:0] temporary_crc;
        integer bit_index;
        begin
            temporary_crc = initial_crc;
            for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
                if (temporary_crc[WIDTH-1] ^ byte_value[7-bit_index])
                    temporary_crc = {temporary_crc[WIDTH-2:0], 1'b0} ^ POLY;
                else
                    temporary_crc = {temporary_crc[WIDTH-2:0], 1'b0};
            end
            update_crc = temporary_crc;
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            crc <= INIT;
            current_crc <= INIT;
            busy <= 1'b0;
            crc_valid <= 1'b0;
        end else begin
            crc_valid <= 1'b0;
            if (!busy && start) begin
                current_crc <= INIT;
                busy <= 1'b1;
            end else if (busy && data_valid) begin
                current_crc <= updated_crc;
                if (data_last) begin
                    crc <= updated_crc;
                    busy <= 1'b0;
                    crc_valid <= 1'b1;
                end
            end
        end
    end
endmodule
