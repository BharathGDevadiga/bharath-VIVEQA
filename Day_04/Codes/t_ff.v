`timescale 1ns / 1ps

module t_ff(
    
    input clk,
    input rst,
    input T,
    output reg Q,
    output Qb
);

always @(posedge clk or posedge rst)
begin
    
    if (rst)
        Q <= 1'b0;
    else if (T)
        Q <= ~Q;
    else
        Q <= Q;
    
end

assign Qb = ~Q;

endmodule
