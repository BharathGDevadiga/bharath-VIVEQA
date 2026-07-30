`timescale 1ns/1ps
module tb_lcd_driver;
    reg clk=0, reset=1, write_en=0, write_rs=0; reg [7:0] write_data=0;
    wire ready, rs, rw, en; wire [7:0] data;
    lcd_driver #(.CLK_HZ(1_000_000)) dut (.clk(clk),.reset(reset),.write_en(write_en),.write_rs(write_rs),.write_data(write_data),.ready(ready),.lcd_rs(rs),.lcd_rw(rw),.lcd_en(en),.lcd_d(data));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); write_rs=1; write_data="A"; write_en=1; @(negedge clk); write_en=0;
        wait(ready); #1;
        if (data!="A" || rs!=1 || rw!=0) $display("FAIL: lcd driver"); else $display("PASS: lcd_driver");
        $finish;
    end
endmodule
