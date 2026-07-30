`timescale 1ns/1ps
module tb_baud_gen;
    reg clk = 0, reset = 1;
    wire tick;
    integer cycles = 0, ticks = 0;
    baud_gen #(.CLK_HZ(160), .BAUD(10), .OVERSAMPLE(1)) dut (.clk(clk), .reset(reset), .tick(tick));
    always #5 clk = ~clk;
    always @(posedge clk) begin
        cycles = cycles + 1;
        if (tick) ticks = ticks + 1;
    end
    initial begin
        #17 reset = 0;
        repeat (65) @(posedge clk);
        if (ticks < 3 || ticks > 5) $display("FAIL: unexpected tick count %0d", ticks);
        else $display("PASS: baud_gen");
        $finish;
    end
endmodule
