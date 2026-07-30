`timescale 1ns/1ps
module tb_mcp3202_sampler;
    reg clk=0, reset=1, force_sample=0, channel=0, miso=0;
    wire [11:0] value; wire valid, busy, sck, mosi, cs_n;
    mcp3202_sampler #(.CLK_HZ(100),.SPI_HZ(10),.SAMPLE_HZ(1)) dut (.clk(clk),.reset(reset),.force_sample(force_sample),.channel(channel),.sample_value(value),.sample_valid(valid),.busy(busy),.spi_sck(sck),.spi_mosi(mosi),.spi_miso(miso),.adc_cs_n(cs_n));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); force_sample=1; @(negedge clk); force_sample=0;
        wait(valid); #1;
        if (value!==12'h000) $display("FAIL: mcp3202 sampler"); else $display("PASS: mcp3202_sampler");
        $finish;
    end
endmodule
