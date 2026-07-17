`timescale 1ns / 1ps

module tb_uart();

reg clk, rst;
reg tx_start;
reg [7:0] tx_data;

wire tx, tx_busy, tx_done;

uart_tx dut(clk, rst, tx_start, tx_data, tx, tx_busy, tx_done);

always #20.8 clk = ~clk;

initial begin

    clk = 1'b0;
    rst = 1'b0;
    tx_start = 1'b0;
    tx_data = 8'b0;

    #40 rst = 1'b1;
    #40 rst = 1'b0;
    #40 tx_start = 1'b1; tx_data = 8'hAB;
    #40 tx_start = 1'b0;

    #1000000;
    $stop;

end

// Monitor signals
initial begin
  
    $monitor("Time=%0t | rst=%b | tx_start=%b | tx_data=0x%h | tx=%b | tx_busy=%b | tx_done=%b",
             $time, rst, tx_start, tx_data, tx, tx_busy, tx_done);
  
end

endmodule
