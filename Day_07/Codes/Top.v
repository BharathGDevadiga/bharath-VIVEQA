`timescale 1ns / 1ps

module Top(
  
    input clk,
    input reset,
    input a,
    input b,
    input [1:0] m,
    output reg q,
    output reg qb
);

wire qd, qbd;
wire qt, qbt;
wire qjk, qjkb;

wire t_in, jk_in;

// D Flip-Flop
dff dff1 (
    .d(a),
    .clk(clk),
    .reset(reset),
    .q(qd),
    .qb(qbd)
);

// T Flip-Flop
assign t_in = a ^ qt;

dff tff1 (
    .d(t_in),
    .clk(clk),
    .reset(reset),
    .q(qt),
    .qb(qbt)
);

// JK Flip-Flop
assign jk_in = (a & qjkb) | (~b & qjk);

dff jkff1 (
    .d(jk_in),
    .clk(clk),
    .reset(reset),
    .q(qjk),
    .qb(qjkb)
);

// 3:1 Multiplexer
always @(*) begin
  
    case (m)
        2'b00: begin
            q  = qd;
            qb = qbd;
        end

        2'b01: begin
            q  = qt;
            qb = qbt;
        end

        2'b10: begin
            q  = qjk;
            qb = qjkb;
        end

        default: begin
            q  = 1'b0;
            qb = 1'b1;
        end
    endcase
end

endmodule


module dff(
  
    input d,
    input clk,
    input reset,
    output reg q,
    output qb
);

always @(posedge clk or posedge reset) begin
  
    if (reset)
      
        q <= 1'b0;
    else
        q <= d;
end

assign qb = ~q;

endmodule
