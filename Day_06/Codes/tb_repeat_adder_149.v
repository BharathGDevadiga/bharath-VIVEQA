`timescale 1ns/1ps

module tb_repeat_adder_149;

reg clk;
reg rst;
reg [7:0] in_data;

wire [7:0] out_data;
wire done;

repeat_adder_149 uut(
    .clk(clk),
    .rst(rst),
    .in_data(in_data),
    .out_data(out_data),
    .done(done)
);

always #5 clk = ~clk;

initial begin
  
    clk = 0;
    rst = 1;
    in_data = 8'd8;

    #10 rst = 0;

    wait(done);
    #10 $finish;
  
end

initial begin
  
    $monitor("time=%0t count result=%d", 
             $time, out_data);
  
end

endmodule
