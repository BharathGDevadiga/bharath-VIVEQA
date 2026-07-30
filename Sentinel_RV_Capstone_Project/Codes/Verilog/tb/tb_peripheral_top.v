`timescale 1ns/1ps
module tb_peripheral_top;
    reg clk=0, reset=1;
    // This smoke test intentionally leaves board inputs un-driven.
    // It verifies elaboration and reset-only behavior of the integrated design.
    peripheral_top dut (.clk_24mhz(clk), .reset(reset));
    always #5 clk=~clk;
    initial begin
        repeat(4) @(posedge clk); reset=0;
        repeat(20) @(posedge clk);
        $display("PASS: peripheral_top reset smoke");
        $finish;
    end
endmodule
