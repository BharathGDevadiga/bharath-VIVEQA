`timescale 1ns / 1ps

module PISO(
  
    input clk,
    input rst,
    input [3:0] data_in,
    input load,
    input shift,
    output reg data_out
);

reg [3:0] data_reg;
reg [1:0] cnt;
reg shift_d;

wire pos_shift;

always @(posedge clk) begin
  
    if (rst) begin
      
        data_out <= 1'b0;
        cnt <= 2'b00;
        data_reg <= 4'b0000;
      
    end
    else begin
      
        if (load) begin
          
            data_reg <= data_in;
            cnt <= 2'b00;
          
        end
        else if (pos_shift) begin
          
            data_out <= data_reg[cnt];
            cnt <= cnt + 1'b1;
          
        end
    end
end

always @(posedge clk) begin
  
    if (rst)
      
        shift_d <= 1'b0;
    else
      
        shift_d <= shift;
end

assign pos_shift = ~shift_d & shift;

endmodule
