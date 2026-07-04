`timescale 1ns / 1ps

module tb_adder_subtractor_4bit;

reg [3:0] a;
reg [3:0] b;
reg m;

wire [3:0] sum;
wire carry;

adder_subtractor_4bit uut(
    .a(a),
    .b(b),
    .m(m),
    .sum(sum),
    .carry(carry)
);

initial begin

    // Addition
    a = 4'b0101; b = 4'b0011; m = 0; #10; // 5+3=8

    a = 4'b1001; b = 4'b0110; m = 0; #10; // 9+6=15

    a = 4'b1111; b = 4'b0001; m = 0; #10; // 15+1=16
    
     a = 4'b1011; b = 4'b1011; m = 0; #10; // 11+11=22

    // Subtraction
    a = 4'b0101; b = 4'b0011; m = 1; #10; // 5-3=2

    a = 4'b1000; b = 4'b0010; m = 1; #10; // 8-2=6

    a = 4'b0110; b = 4'b0110; m = 1; #10; // 6-6=0

    a = 4'b0011; b = 4'b0101; m = 1; #10; // 3-5=-2

    $finish;

end

initial begin
      
    $monitor("Time=%0t m=%b A=%b B=%b Sum=%b Carry=%b",
             $time, m, a, b, sum, carry);
end

endmodule
