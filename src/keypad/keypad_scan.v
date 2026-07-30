`timescale 1ns/1ps

module keypad_scan #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer SCAN_HZ = 1_000,
    parameter integer DEBOUNCE_SCANS = 4
) (
    input  wire       clk,
    input  wire       reset,
    output reg [3:0]  row_n,
    input  wire [3:0] col_n,
    output reg        key_valid,
    output reg [3:0]  key_code
);
    localparam integer SCAN_DIV = (CLK_HZ / SCAN_HZ > 0) ? (CLK_HZ / SCAN_HZ) : 1;
    localparam integer COUNT_W = (SCAN_DIV <= 1) ? 1 : $clog2(SCAN_DIV);
    localparam integer DEBOUNCE_W = (DEBOUNCE_SCANS <= 1) ? 1 : $clog2(DEBOUNCE_SCANS + 1);
    reg [COUNT_W-1:0] scan_count;
    reg [1:0] row_index;
    reg [3:0] candidate;
    reg [1:0] candidate_row;
    reg [DEBOUNCE_W-1:0] stable_count;
    reg key_latched;

    function [3:0] make_code;
        input [1:0] row;
        input [1:0] col;
        begin
            // Physical order: 1 2 3 A / 4 5 6 B / 7 8 9 C / E 0 F D.
            case ({row, col})
                4'h0: make_code = 4'h1; 4'h1: make_code = 4'h2;
                4'h2: make_code = 4'h3; 4'h3: make_code = 4'hA;
                4'h4: make_code = 4'h4; 4'h5: make_code = 4'h5;
                4'h6: make_code = 4'h6; 4'h7: make_code = 4'hB;
                4'h8: make_code = 4'h7; 4'h9: make_code = 4'h8;
                4'hA: make_code = 4'h9; 4'hB: make_code = 4'hC;
                4'hC: make_code = 4'hE; 4'hD: make_code = 4'h0;
                4'hE: make_code = 4'hF; default: make_code = 4'hD;
            endcase
        end
    endfunction

    function [1:0] active_column;
        input [3:0] columns;
        begin
            casex (columns)
                4'bxxx0: active_column = 2'd0;
                4'bxx01: active_column = 2'd1;
                4'bx011: active_column = 2'd2;
                default: active_column = 2'd3;
            endcase
        end
    endfunction

    always @(*) begin
        case (row_index)
            2'd0: row_n = 4'b1110;
            2'd1: row_n = 4'b1101;
            2'd2: row_n = 4'b1011;
            default: row_n = 4'b0111;
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            scan_count <= 0;
            row_index <= 0;
            candidate <= 0;
            candidate_row <= 0;
            stable_count <= 0;
            key_latched <= 1'b0;
            key_valid <= 1'b0;
            key_code <= 0;
        end else begin
            key_valid <= 1'b0;
            if (scan_count == SCAN_DIV - 1) begin
                scan_count <= 0;
                row_index <= row_index + 1'b1;
                if (col_n == 4'b1111) begin
                    if (row_index == candidate_row) begin
                        stable_count <= 0;
                        key_latched <= 1'b0;
                    end
                end else if (candidate_row == row_index &&
                             candidate == make_code(row_index, active_column(col_n))) begin
                    if (stable_count < DEBOUNCE_SCANS)
                        stable_count <= stable_count + 1'b1;
                    if (stable_count == DEBOUNCE_SCANS - 1 && !key_latched) begin
                        key_code <= candidate;
                        key_valid <= 1'b1;
                        key_latched <= 1'b1;
                    end
                end else begin
                    candidate <= make_code(row_index, active_column(col_n));
                    candidate_row <= row_index;
                    stable_count <= 1;
                end
            end else
                scan_count <= scan_count + 1'b1;
        end
    end
endmodule
