`timescale 1ns / 1ps

module alu(
  
    input  [7:0] push,      // push[7:4] = A, push[3:0] = B
    input  [15:0] key,      // 16 keypad buttons
    output reg [7:0] led
  
);

wire [3:0] a;
wire [3:0] b;

assign a = ~push[7:4];
assign b = ~push[3:0];

always @(*) begin
  
    led = 8'b00000000;
  
    if(key[0])      
      led = a + b;          //1 Add
  
    else if(key[1]) 
      led = a - b;           //2 Sub
  
    else if(key[2]) 
      led = a & b;          //3 AND
  
    else if(key[3]) 
      led = a | b;          //4 OR
  
    else if(key[4])  
      led = a << b;         //5 A<<B
  
    else if(key[5])  
      led = a >> b;         //6 A>>B
  
    else if(key[6]) 
      led = a ^ b;          //7 XOR
  
    else if(key[7]) 
      led = ~a;             //8 NOT A
  
    else if(key[8])  
      led = a * b;          //9 Multiply
  
    else if(key[9])  
      led = ~(a | b);       //10 NOR
  
    else if(key[10]) 
      led = ~(a & b);       //11 NAND
  
    else if(key[11]) 
      led = a << 2;         //12 A<<2
  
    else if(key[12]) 
      led = a >> 2;         //13 A>>2
  
    else if(key[13])
      led = ~(a ^ b);       //14 XNOR
  
    else if(key[14]) 
      led = a + 1;          //15 A+1
  
    else if(key[15]) 
      led = b + 1;          //16 B+1
  
    else            
      led = 8'b00000000;
  
end

endmodule
