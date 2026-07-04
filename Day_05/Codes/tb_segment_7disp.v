`timescale 1ns / 1ps

module tb_segment_7disp;

reg b3, b2, b1, b0;
wire a, b, c, d, e, f, g, h;

segment_7disp uut(
    .b3(b3),
    .b2(b2),
    .b1(b1),
    .b0(b0),
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .e(e),
    .f(f),
    .g(g),
    .h(h)
);

initial begin

    {b3,b2,b1,b0} = 4'b0000; #10;
    {b3,b2,b1,b0} = 4'b0001; #10;
    {b3,b2,b1,b0} = 4'b0010; #10;
    {b3,b2,b1,b0} = 4'b0011; #10;
    {b3,b2,b1,b0} = 4'b0100; #10;
    {b3,b2,b1,b0} = 4'b0101; #10;
    {b3,b2,b1,b0} = 4'b0110; #10;
    {b3,b2,b1,b0} = 4'b0111; #10;
    {b3,b2,b1,b0} = 4'b1000; #10;
    {b3,b2,b1,b0} = 4'b1001; #10;

    #100 $finish;
end

initial begin
  
  $monitor("T=%0t Input=%b%b%b%b Output=%b%b%b%b%b%b%b%b",
             $time, b3, b2, b1, b0, a, b, c, d, e, f, g, h);
  
end

endmodule
