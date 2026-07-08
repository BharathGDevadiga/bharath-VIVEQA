`timescale 1ns / 1ps

module tb_edge_detector;

reg clk;
reg rst;
reg sig;

wire pos_edge;
wire neg_edge;
wire both_edge;

// Instantiate the module
edge_detector uut (
    .clk(clk),
    .rst(rst),
    .sig(sig),
    .pos_edge(pos_edge),
    .neg_edge(neg_edge),
    .both_edge(both_edge)
);

// Clock generation
always #5 clk = ~clk;

initial begin
    
    clk = 0;
    rst = 1;
    sig = 0;

    #10 rst = 0;

    // Rising Edge
    #10 sig = 1;

    // Falling Edge
    #20 sig = 0;

    // Rising Edge
    #20 sig = 1;

    // Falling Edge
    #20 sig = 0;

    #20 $finish;
    
end

initial begin
    
    $monitor("Time=%0t | sig=%b | pos_edge=%b | neg_edge=%b | both_edge=%b",
             $time, sig, pos_edge, neg_edge, both_edge);
    
end

endmodule
