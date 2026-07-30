`timescale 1ns/1ps

module nonce_generator #(
    parameter [63:0] SEED = 64'h1D872B41C5E93A7F
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        request,
    output reg [63:0] nonce,
    output reg        nonce_valid
);
    reg [63:0] lfsr;
    wire feedback = lfsr[63] ^ lfsr[62] ^ lfsr[60] ^ lfsr[59];

    always @(posedge clk) begin
        if (reset) begin
            lfsr <= SEED;
            nonce <= 64'd0;
            nonce_valid <= 1'b0;
        end else begin
            nonce_valid <= 1'b0;
            if (request) begin
                nonce <= lfsr;
                nonce_valid <= 1'b1;
                lfsr <= {lfsr[62:0], feedback};
            end
        end
    end
endmodule
