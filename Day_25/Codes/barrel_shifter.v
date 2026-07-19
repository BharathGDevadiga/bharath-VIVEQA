`timescale 1ns / 1ps

module barrel_shifter(
    input  [7:0] data_in,
    input  [2:0] shift_amt,
    input dir,
    output reg [7:0] data_out
);

always @(*) begin

    case(dir)

        1'b0: data_out = data_in << shift_amt; // Left Shift

        1'b1: data_out = data_in >> shift_amt; // Right Shift

    endcase

end

endmodule
