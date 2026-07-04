`timescale 1ns / 1ps

module d_ff(
    
    input clk,
    input rst,
    input D,
    output reg Q,
    output Qb
);

always @(posedge clk)
begin
    
    if (rst)
        Q <= 1'b0;
    else
        Q <= D;
    
end

assign Qb = ~Q;

endmodule
