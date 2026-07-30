`timescale 1ns/1ps

module sevenseg_driver #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer SPI_HZ = 500_000,
    parameter integer REFRESH_HZ = 100
) (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] value,
    input  wire        display_enable,
    output reg         seg_din,
    output reg         seg_clk,
    output reg         seg_load
);
    localparam integer HALF_DIV = (CLK_HZ / (SPI_HZ * 2) > 0) ? (CLK_HZ / (SPI_HZ * 2)) : 1;
    localparam integer REFRESH_DIV = (CLK_HZ / REFRESH_HZ > 0) ? (CLK_HZ / REFRESH_HZ) : 1;
    localparam integer DIV_W = (HALF_DIV <= 1) ? 1 : $clog2(HALF_DIV);
    localparam integer REFRESH_W = (REFRESH_DIV <= 1) ? 1 : $clog2(REFRESH_DIV);
    localparam [2:0] IDLE = 3'd0, LOAD = 3'd1, HIGH = 3'd2, LOW = 3'd3, LATCH = 3'd4;
    reg [2:0] state;
    reg [DIV_W-1:0] div_count;
    reg [REFRESH_W-1:0] refresh_count;
    reg [3:0] bit_index;
    reg [2:0] word_index;
    reg [15:0] word_reg;
    reg [15:0] value_reg;

    function [15:0] transfer_word;
        input [2:0] index;
        input [15:0] number;
        begin
            case (index)
                3'd0: transfer_word = 16'h0F00; // display test off
                3'd1: transfer_word = {8'h0C, display_enable ? 8'h01 : 8'h00};
                3'd2: transfer_word = 16'h0B03; // scan four digits
                3'd3: transfer_word = 16'h09FF; // BCD decode
                3'd4: transfer_word = {8'h01, 4'h0, number[3:0]};
                3'd5: transfer_word = {8'h02, 4'h0, number[7:4]};
                3'd6: transfer_word = {8'h03, 4'h0, number[11:8]};
                default: transfer_word = {8'h04, 4'h0, number[15:12]};
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            div_count <= 0;
            refresh_count <= 0;
            bit_index <= 0;
            word_index <= 0;
            word_reg <= 0;
            value_reg <= 0;
            seg_din <= 1'b0;
            seg_clk <= 1'b0;
            seg_load <= 1'b1;
        end else begin
            if (refresh_count == REFRESH_DIV - 1)
                refresh_count <= 0;
            else
                refresh_count <= refresh_count + 1'b1;
            if (div_count == HALF_DIV - 1) begin
                div_count <= 0;
                case (state)
                    IDLE: if (refresh_count == REFRESH_DIV - 1) begin
                        value_reg <= value;
                        word_index <= 0;
                        state <= LOAD;
                    end
                    LOAD: begin
                        word_reg <= transfer_word(word_index, value_reg);
                        bit_index <= 4'd15;
                        seg_din <= transfer_word(word_index, value_reg) >> 15;
                        seg_load <= 1'b0;
                        seg_clk <= 1'b0;
                        state <= HIGH;
                    end
                    HIGH: begin seg_clk <= 1'b1; state <= LOW; end
                    LOW: begin
                        seg_clk <= 1'b0;
                        if (bit_index == 0)
                            state <= LATCH;
                        else begin
                            bit_index <= bit_index - 1'b1;
                            seg_din <= word_reg[bit_index-1'b1];
                            state <= HIGH;
                        end
                    end
                    default: begin
                        seg_load <= 1'b1;
                        if (word_index == 3'd7)
                            state <= IDLE;
                        else begin
                            word_index <= word_index + 1'b1;
                            state <= LOAD;
                        end
                    end
                endcase
            end else
                div_count <= div_count + 1'b1;
        end
    end
endmodule
