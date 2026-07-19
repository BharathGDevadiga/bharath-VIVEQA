`timescale 1ns / 1ps

module binary_gray_converter(

    input  [3:0] binary,
    input  [3:0] gray,
    output [3:0] binary_to_gray,
    output [3:0] gray_to_binary

);

    // Binary to Gray
    assign binary_to_gray = binary ^ (binary >> 1);

    // Gray to Binary
    assign gray_to_binary[3] = gray[3];
    assign gray_to_binary[2] = gray_to_binary[3] ^ gray[2];
    assign gray_to_binary[1] = gray_to_binary[2] ^ gray[1];
    assign gray_to_binary[0] = gray_to_binary[1] ^ gray[0];

endmodule
