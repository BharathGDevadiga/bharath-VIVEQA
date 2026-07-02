module logic_gates(
    input A,
    input B,
    output AND_G,
    output OR_G,
    output NOT_A,
    output NAND_G,
    output NOR_G,
    output XOR_G,
    output XNOR_G
);

assign AND_G  = A & B;
assign OR_G   = A | B;
assign NOT_A  = ~A;
assign NAND_G = ~(A & B);
assign NOR_G  = ~(A | B);
assign XOR_G  = A ^ B;
assign XNOR_G = ~(A ^ B);

endmodule