`timescale 1ns/1ps
module tb_keypad;
    reg clk=0, reset=1; wire [3:0] row_n; reg [3:0] col_n; wire valid; wire [3:0] code;
    keypad_scan #(.CLK_HZ(1000),.SCAN_HZ(100),.DEBOUNCE_SCANS(2)) dut (.clk(clk),.reset(reset),.row_n(row_n),.col_n(col_n),.key_valid(valid),.key_code(code));
    always #5 clk=~clk;
    always @(*) if (row_n==4'b1110) col_n=4'b1110; else col_n=4'b1111;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        wait(valid); #1;
        if (code!==4'h1) $display("FAIL: keypad code %h",code); else $display("PASS: keypad_scan");
        $finish;
    end
endmodule
