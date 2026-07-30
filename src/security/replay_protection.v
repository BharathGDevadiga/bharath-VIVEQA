`timescale 1ns/1ps

// A one-entry-per-cycle scan maps cleanly to a small BRAM-backed nonce window.
// DEPTH should be a power of two for a natural circular replacement policy.
module replay_protection #(
    parameter integer NONCE_WIDTH = 64,
    parameter integer DEPTH = 64
) (
    input  wire                   clk,
    input  wire                   reset,
    input  wire                   check_start,
    input  wire [NONCE_WIDTH-1:0] nonce_in,
    output reg                    busy,
    output reg                    check_done,
    output reg                    replay_detected,
    output reg                    nonce_accepted
);
    localparam integer INDEX_W = (DEPTH <= 1) ? 1 : $clog2(DEPTH);
    reg [NONCE_WIDTH-1:0] nonce_table [0:DEPTH-1];
    reg [DEPTH-1:0] valid_table;
    reg [NONCE_WIDTH-1:0] nonce_reg;
    reg [INDEX_W-1:0] scan_index;
    reg [INDEX_W-1:0] write_index;

    always @(posedge clk) begin
        if (reset) begin
            valid_table <= {DEPTH{1'b0}};
            nonce_reg <= {NONCE_WIDTH{1'b0}};
            scan_index <= {INDEX_W{1'b0}};
            write_index <= {INDEX_W{1'b0}};
            busy <= 1'b0;
            check_done <= 1'b0;
            replay_detected <= 1'b0;
            nonce_accepted <= 1'b0;
        end else begin
            check_done <= 1'b0;
            replay_detected <= 1'b0;
            nonce_accepted <= 1'b0;
            if (!busy) begin
                if (check_start) begin
                    nonce_reg <= nonce_in;
                    scan_index <= {INDEX_W{1'b0}};
                    busy <= 1'b1;
                end
            end else if (valid_table[scan_index] && nonce_table[scan_index] == nonce_reg) begin
                busy <= 1'b0;
                check_done <= 1'b1;
                replay_detected <= 1'b1;
            end else if (scan_index == DEPTH - 1) begin
                nonce_table[write_index] <= nonce_reg;
                valid_table[write_index] <= 1'b1;
                write_index <= write_index + 1'b1;
                busy <= 1'b0;
                check_done <= 1'b1;
                nonce_accepted <= 1'b1;
            end else begin
                scan_index <= scan_index + 1'b1;
            end
        end
    end
endmodule
