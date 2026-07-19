`timescale 1ns / 1ps

module binary_gray_converter_tb;

reg [3:0] binary;
reg [3:0] gray;

wire [3:0] binary_to_gray;
wire [3:0] gray_to_binary;

binary_gray_converter uut(
    .binary(binary),
    .gray(gray),
    .binary_to_gray(binary_to_gray),
    .gray_to_binary(gray_to_binary)

);

initial begin

    binary = 4'b0000;
    gray   = 4'b0000;

    #10 binary = 4'b0001;
    #10 binary = 4'b0010;
    #10 binary = 4'b0011;
    #10 binary = 4'b0100;
    #10 binary = 4'b0101;
    #10 binary = 4'b0110;
    #10 binary = 4'b0111;
    #10 binary = 4'b1000;
    #10 binary = 4'b1001;
    #10 binary = 4'b1010;
    #10 binary = 4'b1011;
    #10 binary = 4'b1100;
    #10 binary = 4'b1101;
    #10 binary = 4'b1110;
    #10 binary = 4'b1111;

    gray = 4'b0000;
    #10 gray = 4'b0001;
    #10 gray = 4'b0011;
    #10 gray = 4'b0010;
    #10 gray = 4'b0110;
    #10 gray = 4'b0111;
    #10 gray = 4'b0101;
    #10 gray = 4'b0100;
    #10 gray = 4'b1100;
    #10 gray = 4'b1101;
    #10 gray = 4'b1111;
    #10 gray = 4'b1110;
    #10 gray = 4'b1010;
    #10 gray = 4'b1011;
    #10 gray = 4'b1001;
    #10 gray = 4'b1000;

    #20;

    $finish;

end

initial begin

    $monitor("T=%0t Binary=%b Gray=%b B2G=%b G2B=%b",
             $time,binary,gray,binary_to_gray,gray_to_binary);

end

endmodule
