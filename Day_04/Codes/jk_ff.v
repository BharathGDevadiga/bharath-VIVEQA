`timescale 1ns / 1ps

module jk_ff(
    
    input clk,
    input rst,
    input j,
    input k,
    output reg Q,
    output Qb
);

always @(posedge clk)
begin
    
    if (rst)
        Q <= 1'b0;
    else
    begin
        
        case ({j, k})
            2'b00: Q <= Q;      // Hold
            2'b01: Q <= 1'b0;   // Reset
            2'b10: Q <= 1'b1;   // Set
            2'b11: Q <= ~Q;     // Toggle
            
        endcase
        
    end
end

assign Qb = ~Q;

endmodule
