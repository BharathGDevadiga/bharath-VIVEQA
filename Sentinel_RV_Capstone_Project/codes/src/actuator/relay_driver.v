`timescale 1ns/1ps

module relay_driver (
    input  wire clk,
    input  wire reset,
    input  wire authorized,
    input  wire relay_set,
    input  wire relay_reset,
    output reg  relay_in,
    output reg  denied
);
    always @(posedge clk) begin
        if (reset) begin
            relay_in <= 1'b0;
            denied <= 1'b0;
        end else begin
            denied <= 1'b0;
            if (relay_reset)
                relay_in <= 1'b0;
            else if (relay_set && authorized)
                relay_in <= 1'b1;
            else if (relay_set)
                denied <= 1'b1;
        end
    end
endmodule
