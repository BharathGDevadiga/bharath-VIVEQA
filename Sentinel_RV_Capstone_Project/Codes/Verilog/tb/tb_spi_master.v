`timescale 1ns/1ps
module tb_spi_master;
    reg clk=0, reset=1, start=0, miso=0; reg [7:0] tx_data=8'hA5;
    wire [7:0] rx_data; wire busy, done, sck, mosi, cs_n;
    spi_master #(.CLK_HZ(100),.SPI_HZ(10),.DATA_WIDTH(8)) dut (.clk(clk),.reset(reset),.start(start),.tx_data(tx_data),.rx_data(rx_data),.busy(busy),.done(done),.sck(sck),.mosi(mosi),.miso(miso),.cs_n(cs_n));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); start=1; @(negedge clk); start=0;
        wait(done); #1;
        if (rx_data!==8'h00 || cs_n!==1'b1 || busy) $display("FAIL: spi_master"); else $display("PASS: spi_master");
        $finish;
    end
endmodule
