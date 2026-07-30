`timescale 1ns/1ps
module tb_simple_bram_memory;
    reg clk=0, reset=1, valid=0; reg [31:0] addr=0,wdata=0; reg [3:0] wstrb=0;
    wire ready; wire [31:0] rdata;
    simple_bram_memory #(.WORDS(16),.MEM_FILE("")) dut (.clk(clk),.reset(reset),.mem_valid(valid),.mem_addr(addr),.mem_wdata(wdata),.mem_wstrb(wstrb),.mem_ready(ready),.mem_rdata(rdata));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); addr=0; wdata=32'hDEADBEEF; wstrb=4'hF; valid=1;
        @(negedge clk); valid=0; wstrb=0;
        @(negedge clk); valid=1; @(negedge clk); valid=0;
        #1; if (rdata!==32'hDEADBEEF) $display("FAIL: BRAM memory read=%h",rdata); else $display("PASS: simple_bram_memory");
        $finish;
    end
endmodule
