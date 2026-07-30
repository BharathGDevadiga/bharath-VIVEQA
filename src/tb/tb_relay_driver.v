`timescale 1ns/1ps
module tb_relay_driver;
    reg clk=0, reset=1, authorized=0, relay_set=0, relay_reset=0; wire relay_in, denied;
    relay_driver dut (.clk(clk),.reset(reset),.authorized(authorized),.relay_set(relay_set),.relay_reset(relay_reset),.relay_in(relay_in),.denied(denied));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); relay_set=1; @(negedge clk); relay_set=0; @(posedge clk);
        if (relay_in || !denied) $display("FAIL: relay authorized gate");
        authorized=1; @(negedge clk); relay_set=1; @(negedge clk); relay_set=0; @(posedge clk);
        if (!relay_in) $display("FAIL: relay set");
        relay_reset=1; @(posedge clk); relay_reset=0;
        if (relay_in) $display("FAIL: relay reset"); else $display("PASS: relay_driver");
        $finish;
    end
endmodule
