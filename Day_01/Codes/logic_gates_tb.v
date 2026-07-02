`timescale 1ns / 1ps

module logic_gates_tb;

reg A;
reg B;

wire AND_G;
wire OR_G;
wire NOT_A;
wire NAND_G;
wire NOR_G;
wire XOR_G;
wire XNOR_G;

logic_gates dut (
    .A(A),
    .B(B),
    .AND_G(AND_G),
    .OR_G(OR_G),
    .NOT_A(NOT_A),
    .NAND_G(NAND_G),
    .NOR_G(NOR_G),
    .XOR_G(XOR_G),
    .XNOR_G(XNOR_G)
);

initial begin
    A = 0; B = 0; #10;
    A = 0; B = 1; #10;
    A = 1; B = 0; #10;
    A = 1; B = 1; #10;
    $finish;
end

endmodule
