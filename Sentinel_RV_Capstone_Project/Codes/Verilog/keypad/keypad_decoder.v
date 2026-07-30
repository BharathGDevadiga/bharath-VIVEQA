`timescale 1ns/1ps

module keypad_decoder (
    input  wire       clk,
    input  wire       reset,
    input  wire       key_valid,
    input  wire [3:0] key_code,
    output reg        ascii_valid,
    output reg [7:0]  ascii
);
    function [7:0] code_to_ascii;
        input [3:0] code;
        begin
            if (code < 10)
                code_to_ascii = 8'h30 + code;
            else
                code_to_ascii = 8'h41 + (code - 10);
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            ascii_valid <= 1'b0;
            ascii <= 8'h00;
        end else begin
            ascii_valid <= key_valid;
            if (key_valid)
                ascii <= code_to_ascii(key_code);
        end
    end
endmodule
