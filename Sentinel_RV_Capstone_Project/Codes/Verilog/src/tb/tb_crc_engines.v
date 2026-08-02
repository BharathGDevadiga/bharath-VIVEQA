`timescale 1ns/1ps
module tb_crc_engines;
    reg clk=0, reset=1, start=0, data_valid=0, data_last=0;
    reg [7:0] data_byte=0;
    wire [15:0] crc16; wire crc16_busy, crc16_valid;
    wire [31:0] crc32; wire crc32_busy, crc32_valid;
    integer index;
    reg [8*9-1:0] message="123456789";
    // crc16_ccitt crc16_dut (.clk(clk),.reset(reset),.start(start),.data_valid(data_valid),.data_byte(data_byte),.data_last(data_last),.crc(crc16),.busy(crc16_busy),.crc_valid(crc16_valid));
    crc32_mpeg2 crc32_dut (.clk(clk),.reset(reset),.start(start),.data_valid(data_valid),.data_byte(data_byte),.data_last(data_last),.crc(crc32),.busy(crc32_busy),.crc_valid(crc32_valid));
    always #5 clk=~clk;
    task send_byte; input [7:0] value; input last; begin
        @(negedge clk); data_byte=value; data_last=last; data_valid=1;
        @(negedge clk); data_valid=0; data_last=0;
    end endtask
    initial begin
        repeat(3) @(posedge clk); reset=0;
        @(negedge clk); start=1; @(negedge clk); start=0;
        for(index=0;index<9;index=index+1) send_byte(message[8*(8-index) +: 8], index==8);
        wait(crc32_valid); #1;
        if (crc32!==32'h0376E6E7) $display("FAIL: CRC32=%h",crc32);
        else $display("PASS: CRC known-answer vectors");
        $finish;
    end
endmodule
