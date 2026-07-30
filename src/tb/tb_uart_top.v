`timescale 1ns/1ps
module tb_uart_top;
    reg clk = 0, reset = 1, tx_start = 0;
    reg [7:0] tx_data = 8'hA5;
    wire tx, busy, rx_valid, framing_error; wire [7:0] rx_data;
    uart_top #(.CLK_HZ(160_000), .BAUD(10_000)) dut (
        .clk(clk), .reset(reset), .uart_rx_i(tx), .uart_tx_o(tx), .tx_start(tx_start), .tx_data(tx_data),
        .tx_busy(busy), .rx_data(rx_data), .rx_valid(rx_valid), .framing_error(framing_error));
    always #5 clk = ~clk;
    initial begin
        repeat (3) @(posedge clk); reset = 0;
        @(negedge clk); tx_start = 1; @(negedge clk); tx_start = 0;
        wait (rx_valid); #1;
        if (rx_data !== 8'hA5 || framing_error) $display("FAIL: uart_top loopback %h", rx_data);
        else $display("PASS: uart_top");
        $finish;
    end
endmodule
