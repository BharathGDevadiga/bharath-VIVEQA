`timescale 1ns / 1ps

module hex_to_binary(
  
    input  [15:0] hex,
    output reg [3:0] bin
  
);

always @(*) begin
  
    case (hex)
      
        16'd1     : bin = 4'd0;
        16'd2     : bin = 4'd1;
        16'd4     : bin = 4'd2;
        16'd8     : bin = 4'd3;
        16'd16    : bin = 4'd4;
        16'd32    : bin = 4'd5;
        16'd64    : bin = 4'd6;
        16'd128   : bin = 4'd7;
        16'd256   : bin = 4'd8;
        16'd512   : bin = 4'd9;
        16'd1024  : bin = 4'd10;
        16'd2048  : bin = 4'd11;
        16'd4096  : bin = 4'd12;
        16'd8192  : bin = 4'd13;
        16'd16384 : bin = 4'd14;
        16'd32768 : bin = 4'd15;
      
        default   : bin = 4'd0;
      
    endcase
    
end
endmodule
