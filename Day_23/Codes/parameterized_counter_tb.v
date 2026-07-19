`timescale 1ns / 1ps

module parameterized_counter_tb;

parameter WIDTH = 8;

reg clk;
reg rst;
reg en;

wire [WIDTH-1:0] count;

parameterized_counter #(
    .WIDTH(WIDTH)
) uut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .count(count)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 1;
    en  = 0;

    #20;
    rst = 0;

    en = 1;

    #200;

    en = 0;

    #30;

    en = 1;

    #100;

    rst = 1;

    #20;

    rst = 0;

    #50;

    $finish;

end

initial begin
  
    $monitor("Time=%0t  Reset=%b  Enable=%b  Count=%d",
              $time, rst, en, count);
  
end

endmodule
