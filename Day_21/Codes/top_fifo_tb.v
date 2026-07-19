`timescale 1ns / 1ps

module top_fifo_tb;

reg clk;
reg rst;
reg wr_en;
reg rd_en;
reg [7:0] sw;

wire [7:0] led;

// Instantiate Top Module
top_fifo uut (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .sw(sw),
    .led(led)
);

// Clock Generation (10 ns Period)
always #5 clk = ~clk;

initial begin
  
    clk = 0;
    rst = 1;
    wr_en = 0;
    rd_en = 0;
    sw = 8'h00;

    // Reset
    repeat(2) @(posedge clk);
    rst = 0;

    //=========================
    // WRITE OPERATIONS
    //=========================

    @(negedge clk); sw = 8'h11; wr_en = 1;
    @(negedge clk); wr_en = 0;

    @(negedge clk); sw = 8'h22; wr_en = 1;
    @(negedge clk); wr_en = 0;

    @(negedge clk); sw = 8'h33; wr_en = 1;
    @(negedge clk); wr_en = 0;

    @(negedge clk); sw = 8'h44; wr_en = 1;
    @(negedge clk); wr_en = 0;

    @(negedge clk); sw = 8'h55; wr_en = 1;
    @(negedge clk); wr_en = 0;

    @(negedge clk); sw = 8'h66; wr_en = 1;
    @(negedge clk); wr_en = 0;

    @(negedge clk); sw = 8'h77; wr_en = 1;
    @(negedge clk); wr_en = 0;

    @(negedge clk); sw = 8'h88; wr_en = 1;
    @(negedge clk); wr_en = 0;

    //=========================
    // READ OPERATIONS
    //=========================

    @(negedge clk); rd_en = 1;
    @(negedge clk); rd_en = 0;

    @(negedge clk); rd_en = 1;
    @(negedge clk); rd_en = 0;

    @(negedge clk); rd_en = 1;
    @(negedge clk); rd_en = 0;

    @(negedge clk); rd_en = 1;
    @(negedge clk); rd_en = 0;

    @(negedge clk); rd_en = 1;
    @(negedge clk); rd_en = 0;

    @(negedge clk); rd_en = 1;
    @(negedge clk); rd_en = 0;

    @(negedge clk); rd_en = 1;
    @(negedge clk); rd_en = 0;

    @(negedge clk); rd_en = 1;
    @(negedge clk); rd_en = 0;

    repeat(5) @(posedge clk);

    $finish;
  
end

initial begin
  
    $monitor("Time=%0t | SW=%h | LED=%h | WR=%b | RD=%b",
             $time, sw, led, wr_en, rd_en);
  
end

endmodule
