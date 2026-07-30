`timescale 1ns/1ps

module esp32_uart #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer BAUD = 115_200
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       esp_rx,
    output wire       esp_tx,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx_busy,
    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       framing_error
);
    uart_top #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) uart (
        .clk(clk), .reset(reset), .uart_rx_i(esp_rx), .uart_tx_o(esp_tx),
        .tx_start(tx_start), .tx_data(tx_data), .tx_busy(tx_busy),
        .rx_data(rx_data), .rx_valid(rx_valid), .framing_error(framing_error)
    );
endmodule
