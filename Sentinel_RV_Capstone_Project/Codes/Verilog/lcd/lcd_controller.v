`timescale 1ns/1ps

module lcd_controller (
    input  wire         clk,
    input  wire         reset,
    input  wire         refresh,
    input  wire [127:0] line1,
    input  wire [127:0] line2,
    output reg          driver_write,
    output reg          driver_rs,
    output reg [7:0]    driver_data,
    input  wire         driver_ready
);
    localparam [2:0] INIT = 3'd0, WAIT_REFRESH = 3'd1, LINE1_ADDR = 3'd2,
                     LINE1_DATA = 3'd3, LINE2_ADDR = 3'd4, LINE2_DATA = 3'd5;
    reg [2:0] state;
    reg [2:0] init_index;
    reg [4:0] char_index;
    reg [127:0] line1_reg, line2_reg;

    function [7:0] character_at;
        input [127:0] text;
        input [4:0] position;
        begin
            character_at = text >> (8 * (15 - position));
        end
    endfunction

    function [7:0] init_byte;
        input [2:0] index;
        begin
            case (index)
                3'd0: init_byte = 8'h38;
                3'd1: init_byte = 8'h0C;
                3'd2: init_byte = 8'h06;
                default: init_byte = 8'h01;
            endcase
        end
    endfunction

    reg [23:0] poweron_timer;
    reg poweron_done;

    always @(posedge clk) begin
        if (reset) begin
            state <= INIT;
            init_index <= 3'd0;
            char_index <= 5'd0;
            driver_write <= 1'b0;
            driver_rs <= 1'b0;
            driver_data <= 8'd0;
            line1_reg <= {16{8'h20}};
            line2_reg <= {16{8'h20}};
            poweron_timer <= 24'd0;
            poweron_done <= 1'b0;
        end else begin
            driver_write <= 1'b0;
            if (!poweron_done) begin
                if (poweron_timer == 24'd2_400_000) // 100 ms power-on wake-up delay
                    poweron_done <= 1'b1;
                else
                    poweron_timer <= poweron_timer + 1'b1;
            end else if (driver_ready) begin
                case (state)
                    INIT: begin
                        driver_write <= 1'b1;
                        driver_rs <= 1'b0;
                        driver_data <= init_byte(init_index);
                        if (init_index == 3'd3)
                            state <= WAIT_REFRESH;
                        else
                            init_index <= init_index + 1'b1;
                    end
                    WAIT_REFRESH: if (refresh) begin
                        line1_reg <= line1;
                        line2_reg <= line2;
                        state <= LINE1_ADDR;
                    end
                    LINE1_ADDR: begin
                        driver_write <= 1'b1;
                        driver_rs <= 1'b0;
                        driver_data <= 8'h80;
                        char_index <= 5'd0;
                        state <= LINE1_DATA;
                    end
                    LINE1_DATA: begin
                        driver_write <= 1'b1;
                        driver_rs <= 1'b1;
                        driver_data <= character_at(line1_reg, char_index);
                        if (char_index == 5'd15)
                            state <= LINE2_ADDR;
                        else
                            char_index <= char_index + 1'b1;
                    end
                    LINE2_ADDR: begin
                        driver_write <= 1'b1;
                        driver_rs <= 1'b0;
                        driver_data <= 8'hC0;
                        char_index <= 5'd0;
                        state <= LINE2_DATA;
                    end
                    default: begin
                        driver_write <= 1'b1;
                        driver_rs <= 1'b1;
                        driver_data <= character_at(line2_reg, char_index);
                        if (char_index == 5'd15)
                            state <= WAIT_REFRESH;
                        else
                            char_index <= char_index + 1'b1;
                    end
                endcase
            end
        end
    end
endmodule
