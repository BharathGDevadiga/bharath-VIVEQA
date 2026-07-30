`timescale 1ns/1ps

module uart_top #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer BAUD = 115_200
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       uart_rx_i,
    output wire       uart_tx_o,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx_busy,
    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       framing_error
);
    wire baud16_tick;
    reg [3:0] tx_divider;
    reg tx_tick;

    baud_gen #(.CLK_HZ(CLK_HZ), .BAUD(BAUD), .OVERSAMPLE(16)) baud_clock (
        .clk(clk), .reset(reset), .tick(baud16_tick)
    );

    always @(posedge clk) begin
        if (reset) begin
            tx_divider <= 4'd0;
            tx_tick    <= 1'b0;
        end else begin
            tx_tick <= 1'b0;
            if (baud16_tick) begin
                if (tx_divider == 4'd15) begin
                    tx_divider <= 4'd0;
                    tx_tick    <= 1'b1;
                end else
                    tx_divider <= tx_divider + 1'b1;
            end
        end
    end

    uart_tx transmitter (
        .clk(clk), .reset(reset), .baud_tick(tx_tick), .tx_start(tx_start),
        .tx_data(tx_data), .tx(uart_tx_o), .busy(tx_busy)
    );

    uart_rx receiver (
        .clk(clk), .reset(reset), .baud16_tick(baud16_tick), .rx(uart_rx_i),
        .rx_data(rx_data), .rx_valid(rx_valid), .framing_error(framing_error)
    );
endmodule
