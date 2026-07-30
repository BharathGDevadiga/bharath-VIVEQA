`timescale 1ns/1ps
module tb_uart_tx;
    reg clk = 0, reset = 1, baud_tick = 0, tx_start = 0;
    reg [7:0] tx_data = 8'hA5;
    wire tx, busy;
    uart_tx dut (.clk(clk), .reset(reset), .baud_tick(baud_tick), .tx_start(tx_start), .tx_data(tx_data), .tx(tx), .busy(busy));
    always #5 clk = ~clk;
    task tick; begin @(negedge clk); baud_tick = 1; @(negedge clk); baud_tick = 0; end endtask
    initial begin
        repeat (2) @(posedge clk); reset = 0;
        @(negedge clk); tx_start = 1; @(negedge clk); tx_start = 0;
        tick; if (tx !== 1'b0) $display("FAIL: missing start bit");
        tick; if (tx !== 1'b1) $display("FAIL: bit 0");
        tick; if (tx !== 1'b0) $display("FAIL: bit 1");
        repeat (6) tick;
        tick; if (tx !== 1'b1) $display("FAIL: stop bit");
        tick; if (busy) $display("FAIL: transmitter remained busy"); else $display("PASS: uart_tx");
        $finish;
    end
endmodule
