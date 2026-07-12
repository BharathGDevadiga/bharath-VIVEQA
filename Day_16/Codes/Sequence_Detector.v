`timescale 1ns / 1ps

//====================================================
// D Flip-Flop
//====================================================
module d_ff(
    input clk,
    input rst,
    input D,
    output reg Q,
    output qb
);

always @(posedge clk)
begin
    if (rst)
        Q <= 1'b0;
    else
        Q <= D;
end

assign qb = ~Q;

endmodule


//====================================================
// Sequence Detector (Mealy Machine)
// Detects the sequence: 111
//====================================================
module Sequence_Detector(
    input clk,
    input rst,
    input ip,
    output reg op
);

wire d0, d1;
wire q0, qb0;
wire q1, qb1;

// Next-state logic
assign d0 = ~ip;
assign d1 = q0 & ip;

//----------------------------------------------------
// D Flip-Flops
//----------------------------------------------------
d_ff dff0 (
    .clk(clk),
    .rst(rst),
    .D(d0),
    .Q(q0),
    .qb(qb0)
);

d_ff dff1 (
    .clk(clk),
    .rst(rst),
    .D(d1),
    .Q(q1),
    .qb(qb1)
);

//----------------------------------------------------
// Output Logic (Mealy)
//----------------------------------------------------
always @(posedge clk) begin
    if (rst)
        op <= 1'b0;
    else
        op <= ip & q1;
end

endmodule
