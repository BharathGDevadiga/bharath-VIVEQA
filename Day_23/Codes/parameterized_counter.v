`timescale 1ns / 1ps

module parameterized_counter #(
    parameter WIDTH = 8
)(
    input clk,
    input rst,
    input en,
    output reg [WIDTH-1:0] count
);

always @(posedge clk) begin
    if (rst)
      
        count <= 0;
    else if (en)
      
        count <= count + 1;
end

endmodule
