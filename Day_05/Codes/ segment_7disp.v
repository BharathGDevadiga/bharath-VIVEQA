`timescale 1ns / 1ps

module segment_7disp(

    input b3, b2, b1, b0,
    output reg a, b, c, d, e, f, g, h
);

always @(*) begin

    case({b3,b2,b1,b0})

        4'b0000: {a,b,c,d,e,f,g,h} = 8'b11111100; // 0
        4'b0001: {a,b,c,d,e,f,g,h} = 8'b01100000; // 1
        4'b0010: {a,b,c,d,e,f,g,h} = 8'b11011010; // 2
        4'b0011: {a,b,c,d,e,f,g,h} = 8'b11110010; // 3
        4'b0100: {a,b,c,d,e,f,g,h} = 8'b01100110; // 4
        4'b0101: {a,b,c,d,e,f,g,h} = 8'b10110110; // 5
        4'b0110: {a,b,c,d,e,f,g,h} = 8'b10111110; // 6
        4'b0111: {a,b,c,d,e,f,g,h} = 8'b11100000; // 7
        4'b1000: {a,b,c,d,e,f,g,h} = 8'b11111110; // 8
        4'b1001: {a,b,c,d,e,f,g,h} = 8'b11110110; // 9
        default:{a,b,c,d,e,f,g,h} = 8'b00000000;

    endcase

end

endmodule
