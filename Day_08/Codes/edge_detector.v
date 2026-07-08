`timescale 1ns / 1ps

module edge_detector(
    
    input clk,
    input rst,
    input sig,
    output pos_edge,
    output neg_edge,
    output both_edge
);

reg q;

// D Flip-Flop
always @(posedge clk or posedge rst)
    
begin
    if (rst)
        
        q <= 1'b0;
    else
        
        q <= sig;
end

// Edge Detection
assign pos_edge  = sig & (~q);   // Positive Edge
assign neg_edge  = (~sig) & q;   // Negative Edge
assign both_edge = pos_edge | neg_edge;

endmodule
