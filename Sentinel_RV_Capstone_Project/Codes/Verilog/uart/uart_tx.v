`timescale 1ns/1ps

module uart_tx (
    input  wire       clk,
    input  wire       reset,
    input  wire       baud_tick,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx,
    output reg        busy
);
    reg [3:0] bit_index;
    reg [7:0] data_reg;

    always @(posedge clk) begin
        if (reset) begin
            tx        <= 1'b1;
            busy      <= 1'b0;
            bit_index <= 4'd0;
            data_reg  <= 8'd0;
        end else if (!busy) begin
            tx <= 1'b1;
            if (tx_start) begin
                busy      <= 1'b1;
                bit_index <= 4'd10;
                data_reg  <= tx_data;
            end
        end else if (baud_tick) begin
            if (bit_index == 4'd10) begin
                tx        <= 1'b0;
                bit_index <= 4'd0;
            end else if (bit_index < 4'd8) begin
                tx        <= data_reg[bit_index];
                bit_index <= bit_index + 1'b1;
            end else if (bit_index == 4'd8) begin
                tx        <= 1'b1;
                bit_index <= 4'd9;
            end else begin
                tx   <= 1'b1;
                busy <= 1'b0;
            end
        end
    end
endmodule
