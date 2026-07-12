`timescale 1ns / 1ps

//------------------------------------
// T Flip-Flop
//------------------------------------
module T_FF(
    input clk,
    input rst,
    input T,
    output reg Q,
    output Qb
);

always @(posedge clk) begin

    if (rst)

        Q <= 1'b0;

    else if (T)

        Q <= ~Q;

end

assign Qb = ~Q;

endmodule


//------------------------------------
// 4-Bit Asynchronous Up Counter
//------------------------------------
module async_up(
    input clk,
    input rst,
    output [3:0] count
);

wire q0_bar, q1_bar, q2_bar;

T_FF FF0 (
    .clk(clk),
    .rst(rst),
    .T(1'b1),
    .Q(count[0]),
    .Qb(q0_bar)
);

T_FF FF1 (
    .clk(q0_bar),
    .rst(rst),
    .T(1'b1),
    .Q(count[1]),
    .Qb(q1_bar)
);

T_FF FF2 (
    .clk(q1_bar),
    .rst(rst),
    .T(1'b1),
    .Q(count[2]),
    .Qb(q2_bar)
);

T_FF FF3 (
    .clk(q2_bar),
    .rst(rst),
    .T(1'b1),
    .Q(count[3]),
    .Qb()
);

endmodule
