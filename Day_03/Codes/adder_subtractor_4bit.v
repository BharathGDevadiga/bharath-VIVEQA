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

module full_adder(
    
    input a,
    input b,
    input cin,
    output sum,
    output carry
);

wire sum1, carry1, carry2;

half_adder ha1(
    .a(a),
    .b(b),
    .sum(sum1),
    .carry(carry1)
);

half_adder ha2(
    .a(sum1),
    .b(cin),
    .sum(sum),
    .carry(carry2)
);

or(carry, carry1, carry2);

endmodule

module adder_subtractor_4bit(
    
    input [3:0] a,
    input [3:0] b,
    input m,               // 0 = Add, 1 = Subtract
    output [3:0] sum,
    output carry
);

wire [3:0] bw;
wire c1, c2, c3;

// XOR B with m
assign bw = b ^ {4{m}};

// Four Full Adders
full_adder fa0(
    .a(a[0]),
    .b(bw[0]),
    .cin(m),
    .sum(sum[0]),
    .carry(c1)
);

full_adder fa1(
    .a(a[1]),
    .b(bw[1]),
    .cin(c1),
    .sum(sum[1]),
    .carry(c2)
);

full_adder fa2(
    .a(a[2]),
    .b(bw[2]),
    .cin(c2),
    .sum(sum[2]),
    .carry(c3)
);

full_adder fa3(
    .a(a[3]),
    .b(bw[3]),
    .cin(c3),
    .sum(sum[3]),
    .carry(carry)
);

endmodule
