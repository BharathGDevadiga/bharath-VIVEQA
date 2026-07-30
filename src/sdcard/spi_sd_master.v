`timescale 1ns/1ps

// Byte-oriented SPI mode-0 engine.  A client keeps chip select asserted by
// setting hold_cs on each transfer except the final byte of a transaction.
module spi_sd_master #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer SPI_HZ = 400_000
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       xfer_start,
    input  wire [7:0] xfer_data,
    input  wire       hold_cs,
    input  wire       force_cs_high,
    output reg [7:0]  xfer_rx,
    output reg        xfer_busy,
    output reg        xfer_done,
    output reg        sd_clk,
    output reg        sd_cmd,
    input  wire       sd_d0,
    output reg        sd_cs_n
);
    localparam integer HALF_DIV = (CLK_HZ / (SPI_HZ * 2) > 0) ? (CLK_HZ / (SPI_HZ * 2)) : 1;
    localparam integer DIV_W = (HALF_DIV <= 1) ? 1 : $clog2(HALF_DIV);
    reg [DIV_W-1:0] div_count;
    reg [2:0] bit_index;
    reg [7:0] shift_in;
    reg release_cs;

    always @(posedge clk) begin
        if (reset) begin
            xfer_rx <= 8'hFF;
            xfer_busy <= 1'b0;
            xfer_done <= 1'b0;
            sd_clk <= 1'b0;
            sd_cmd <= 1'b1;
            sd_cs_n <= 1'b1;
            div_count <= 0;
            bit_index <= 0;
            shift_in <= 0;
            release_cs <= 1'b1;
        end else begin
            xfer_done <= 1'b0;
            if (!xfer_busy) begin
                sd_clk <= 1'b0;
                if (xfer_start) begin
                    xfer_busy <= 1'b1;
                    sd_cs_n <= force_cs_high;
                    sd_cmd <= xfer_data[7];
                    bit_index <= 3'd7;
                    shift_in <= 8'd0;
                    div_count <= 0;
                    release_cs <= !hold_cs | force_cs_high;
                end
            end else if (div_count == HALF_DIV - 1) begin
                div_count <= 0;
                if (!sd_clk) begin
                    sd_clk <= 1'b1;
                    shift_in <= {shift_in[6:0], sd_d0};
                end else begin
                    sd_clk <= 1'b0;
                    if (bit_index == 0) begin
                        xfer_busy <= 1'b0;
                        xfer_done <= 1'b1;
                        xfer_rx <= shift_in;
                        sd_cs_n <= release_cs;
                        sd_cmd <= 1'b1;
                    end else begin
                        bit_index <= bit_index - 1'b1;
                        sd_cmd <= xfer_data[bit_index-1'b1];
                    end
                end
            end else
                div_count <= div_count + 1'b1;
        end
    end
endmodule
