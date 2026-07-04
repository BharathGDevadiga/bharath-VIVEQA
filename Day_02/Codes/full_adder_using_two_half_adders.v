`timescale 1ns / 1ps

module half_adder(
    
    input a,
    input b,
    output sum,
    output carry
);

xor(sum, a, b);
and(carry, a, b);

endmodule

module full_adder_using_two_half_adders(
    
    input a,
    input b,
    input cin,
    output sum,
    output carry
);

wire sum1, carry1, carry2;

half_adder ha1(a, b, sum1, carry1);
half_adder ha2(sum1, cin, sum, carry2);

or(carry, carry1, carry2);
// assign carry = carry1 | carry2;

endmodule
