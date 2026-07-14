`timescale 1ns / 1ps

module vending_machine(clk,rst,coin,D,C);
  
input clk,rst;
input [1:0]coin;
output reg D,C;

//state encoding
localparam S0=3'b000,S1=3'b001,S2=3'b010,
           S3=3'b011,S4=3'b100;

//registers to hold current state and next state
reg [2:0]state,next_state;

//current state logic
always@(posedge clk)begin
  
      if(rst)state <=S0;
  
      else 
        state <=next_state;
  
end

//combinational next state logic
always @(*)begin

   case(state)
     
   S0:begin
     
      D=1'b0;C=1'b0;
      if(coin==2'b01)next_state=S1;
     
      else if(coin==2'b10)next_state=S2;
     
      else next_state=S0;
      end

   S1:begin
     
      D=1'b0;C=1'b0;
      if(coin==2'b01)next_state=S2;
     
      else if(coin==2'b10)next_state=S3;
     
      else next_state=S1;
      end

   S2:begin
     
      D=1'b0;C=1'b0;
      if(coin==2'b01)next_state=S3;
     
      else 
        if(coin==2'b10)next_state=S4;
     
      else 
        next_state=S2;
      end

   S3:begin
     
      D=1'b1;C=1'b0;
      next_state=S0;
      end

   S4:begin
     
      D=1'b1;C=1'b1;
      next_state=S0;
      end

   default: next_state=S0;
     
   endcase

end
endmodule
