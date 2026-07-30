`timescale 1ns/1ps

module spi_master #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer SPI_HZ = 1_000_000,
    parameter integer DATA_WIDTH = 24
) (
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  start,
    input  wire [DATA_WIDTH-1:0] tx_data,
    output reg  [DATA_WIDTH-1:0] rx_data,
    output reg                   busy,
    output reg                   done,
    output reg                   sck,
    output reg                   mosi,
    input  wire                  miso,
    output reg                   cs_n
);
    localparam integer HALF_DIV = (CLK_HZ / (SPI_HZ * 2) > 0) ?
                                  (CLK_HZ / (SPI_HZ * 2)) : 1;
    localparam integer DIV_W = (HALF_DIV <= 1) ? 1 : $clog2(HALF_DIV);
    localparam integer BIT_W = (DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH);
    reg [DIV_W-1:0] divider;
    reg [BIT_W-1:0] bit_index;
    reg [DATA_WIDTH-1:0] shift_in;

    always @(posedge clk) begin
        if (reset) begin
            rx_data <= {DATA_WIDTH{1'b0}};
            busy <= 1'b0;
            done <= 1'b0;
            sck <= 1'b0;
            mosi <= 1'b0;
            cs_n <= 1'b1;
            divider <= {DIV_W{1'b0}};
            bit_index <= {BIT_W{1'b0}};
            shift_in <= {DATA_WIDTH{1'b0}};
        end else begin
            done <= 1'b0;
            if (!busy) begin
                sck <= 1'b0;
                cs_n <= 1'b1;
                if (start) begin
                    busy <= 1'b1;
                    cs_n <= 1'b0;
                    divider <= {DIV_W{1'b0}};
                    bit_index <= DATA_WIDTH - 1;
                    mosi <= tx_data[DATA_WIDTH-1];
                    shift_in <= {DATA_WIDTH{1'b0}};
                end
            end else if (divider == HALF_DIV - 1) begin
                divider <= {DIV_W{1'b0}};
                if (!sck) begin
                    sck <= 1'b1;
                    shift_in <= {shift_in[DATA_WIDTH-2:0], miso};
                end else begin
                    sck <= 1'b0;
                    if (bit_index == 0) begin
                        busy <= 1'b0;
                        cs_n <= 1'b1;
                        rx_data <= shift_in;
                        done <= 1'b1;
                    end else begin
                        bit_index <= bit_index - 1'b1;
                        mosi <= tx_data[bit_index-1'b1];
                    end
                end
            end else
                divider <= divider + 1'b1;
        end
    end
endmodule
