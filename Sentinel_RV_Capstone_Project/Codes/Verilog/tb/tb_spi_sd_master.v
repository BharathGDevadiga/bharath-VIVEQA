`timescale 1ns/1ps

module tb_spi_sd_master;
    reg clk = 1'b0;
    reg reset = 1'b1;
    reg xfer_start = 1'b0;
    reg [7:0] xfer_data = 8'hFF;
    reg hold_cs = 1'b0;
    reg force_cs_high = 1'b0;
    reg sd_d0 = 1'b1;
    wire [7:0] xfer_rx;
    wire xfer_busy;
    wire xfer_done;
    wire sd_clk;
    wire sd_cmd;
    wire sd_cs_n;
    reg [7:0] card_reply = 8'h01;
    reg [2:0] reply_bit = 3'd7;

    spi_sd_master #(.CLK_HZ(100), .SPI_HZ(25)) dut (
        .clk(clk), .reset(reset), .xfer_start(xfer_start), .xfer_data(xfer_data),
        .hold_cs(hold_cs), .force_cs_high(force_cs_high), .xfer_rx(xfer_rx),
        .xfer_busy(xfer_busy), .xfer_done(xfer_done), .sd_clk(sd_clk),
        .sd_cmd(sd_cmd), .sd_d0(sd_d0), .sd_cs_n(sd_cs_n)
    );

    always #5 clk = ~clk;

    always @(negedge sd_clk) begin
        if (xfer_busy && reply_bit != 0) begin
            reply_bit <= reply_bit - 1'b1;
            sd_d0 <= card_reply[reply_bit - 1'b1];
        end
    end

    initial begin
        repeat (3) @(posedge clk);
        reset = 1'b0;
        @(posedge clk);
        xfer_data = 8'hFF;
        hold_cs = 1'b0;
        sd_d0 = card_reply[7];
        xfer_start = 1'b1;
        @(posedge clk);
        xfer_start = 1'b0;
        wait (xfer_done);
        #1;
        if (xfer_rx !== 8'h01) begin
            $display("FAIL: expected 01, received %02h", xfer_rx);
            $finish;
        end
        $display("PASS: SPI received %02h", xfer_rx);
        $finish;
    end
endmodule
