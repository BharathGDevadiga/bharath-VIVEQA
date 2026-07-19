`timescale 1ns / 1ps

module universal_shift_register(
    input clk,
    input rst,
    input [1:0] mode,
    input serial_left,
    input serial_right,
    input [3:0] parallel_in,
    output reg [3:0] q
);

always @(posedge clk) begin

    if(rst)
        q <= 4'b0000;

    else begin

        case(mode)

            2'b00: q <= q;                                      // Hold

            2'b01: q <= {serial_right, q[3:1]};                 // Shift Right

            2'b10: q <= {q[2:0], serial_left};                  // Shift Left

            2'b11: q <= parallel_in;                            // Parallel Load

            default: q <= q;

        endcase

    end
end

endmodule
