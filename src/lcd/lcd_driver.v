`timescale 1ns/1ps

module lcd_driver #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer SETUP_NS = 100,
    parameter integer ENABLE_NS = 500,
    parameter integer NORMAL_US = 50,
    parameter integer CLEAR_US = 2_000
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       write_en,
    input  wire       write_rs,
    input  wire [7:0] write_data,
    output wire       ready,
    output reg        lcd_rs,
    output wire       lcd_rw,
    output reg        lcd_en,
    output reg [7:0]  lcd_d
);
    localparam integer SETUP_CYCLES = (((CLK_HZ / 1_000_000) * SETUP_NS) / 1000 > 0) ?
                                      (((CLK_HZ / 1_000_000) * SETUP_NS) / 1000) : 1;
    localparam integer ENABLE_CYCLES = (((CLK_HZ / 1_000_000) * ENABLE_NS) / 1000 > 0) ?
                                       (((CLK_HZ / 1_000_000) * ENABLE_NS) / 1000) : 1;
    localparam integer NORMAL_CYCLES = (CLK_HZ / 1_000_000) * NORMAL_US;
    localparam integer CLEAR_CYCLES = (CLK_HZ / 1_000_000) * CLEAR_US;
    localparam integer MAX_CYCLES = (CLEAR_CYCLES > NORMAL_CYCLES) ? CLEAR_CYCLES : NORMAL_CYCLES;
    localparam integer COUNT_W = (MAX_CYCLES <= 1) ? 1 : $clog2(MAX_CYCLES + 1);
    localparam [2:0] IDLE = 3'd0, SETUP = 3'd1, PULSE = 3'd2, HOLD = 3'd3;
    reg [2:0] state;
    reg [COUNT_W-1:0] count, wait_cycles;

    assign ready = (state == IDLE);
    assign lcd_rw = 1'b0;

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            count <= 0;
            wait_cycles <= 0;
            lcd_rs <= 1'b0;
            lcd_en <= 1'b0;
            lcd_d <= 8'd0;
        end else begin
            case (state)
                IDLE: if (write_en) begin
                    lcd_rs <= write_rs;
                    lcd_d <= write_data;
                    lcd_en <= 1'b0;
                    count <= 0;
                    wait_cycles <= (!write_rs && (write_data == 8'h01 || write_data == 8'h02)) ? CLEAR_CYCLES : NORMAL_CYCLES;
                    state <= SETUP;
                end
                SETUP: if (count == SETUP_CYCLES - 1) begin
                    count <= 0;
                    lcd_en <= 1'b1;
                    state <= PULSE;
                end else count <= count + 1'b1;
                PULSE: if (count == ENABLE_CYCLES - 1) begin
                    count <= 0;
                    lcd_en <= 1'b0;
                    state <= HOLD;
                end else count <= count + 1'b1;
                default: if (count == wait_cycles - 1) begin
                    count <= 0;
                    state <= IDLE;
                end else count <= count + 1'b1;
            endcase
        end
    end
endmodule
