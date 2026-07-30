`timescale 1ns/1ps
module tb_uart_rx;
    reg clk = 0, reset = 1, baud16_tick = 1, rx = 1;
    wire [7:0] rx_data; wire rx_valid, framing_error;
    reg [7:0] captured; reg captured_valid = 0;
    uart_rx dut (.clk(clk), .reset(reset), .baud16_tick(baud16_tick), .rx(rx), .rx_data(rx_data), .rx_valid(rx_valid), .framing_error(framing_error));
    always #5 clk = ~clk;
    always @(posedge clk) if (rx_valid) begin captured <= rx_data; captured_valid <= 1; end
    task send_byte; input [7:0] value; integer bit_no; begin
        rx = 0; repeat (16) @(posedge clk);
        for (bit_no = 0; bit_no < 8; bit_no = bit_no + 1) begin rx = value[bit_no]; repeat (16) @(posedge clk); end
        rx = 1; repeat (18) @(posedge clk);
    end endtask
    initial begin
        repeat (2) @(posedge clk); reset = 0;
        send_byte(8'h3C);
        if (!captured_valid || captured !== 8'h3C || framing_error) $display("FAIL: uart_rx data=%h valid=%b err=%b", captured, captured_valid, framing_error);
        else $display("PASS: uart_rx");
        $finish;
    end
endmodule
