`timescale 1ns / 1ps

module seq_det_tb;

reg clk;
reg rst;
reg ip;
wire op;

// Instantiate DUT
Sequence_Detector dut (
    .clk(clk),
    .rst(rst),
    .ip(ip),
    .op(op)
);

// Clock generation (10 ns period)
always #5 clk = ~clk;

initial begin
  
    clk = 1'b0;
    rst = 1'b0;
    ip  = 1'b0;

    // Reset
    #12 rst = 1'b1;
    #12 rst = 1'b0;

    // Apply input sequence
    #12 ip = 1'b1;
    #12 ip = 1'b0;
    #12 ip = 1'b1;
    #12 ip = 1'b0;
    #12 ip = 1'b1;
    #12 ip = 1'b1;
    #12 ip = 1'b1;
    #12 ip = 1'b0;
    #12 ip = 1'b1;
    #12 ip = 1'b0;
    #12 ip = 1'b1;
    #12 ip = 1'b1;
    #12 ip = 1'b1;
    #12 ip = 1'b0;
    #12 ip = 1'b1;
    #12 ip = 1'b1;
    #12 ip = 1'b1;
    #12 ip = 1'b0;
    #12 ip = 1'b1;
    #12 ip = 1'b1;
    #12 ip = 1'b1;
    #12 ip = 1'b0;
    #12 ip = 1'b1;
    #12 ip = 1'b0;
    #12 ip = 1'b1;
    #12 ip = 1'b0;
    #12 ip = 1'b1;
    #12 ip = 1'b1;

    #20;
    $finish;
  
end

// Monitor signals
initial begin
  
    $monitor("Time=%0t | rst=%b | ip=%b | op=%b",
             $time, rst, ip, op);
  
end

endmodule
