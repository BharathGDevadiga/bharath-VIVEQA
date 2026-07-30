`timescale 1ns/1ps

module uart_rx (
    input  wire       clk,
    input  wire       reset,
    input  wire       baud16_tick,
    input  wire       rx,
    output reg [7:0] rx_data,
    output reg        rx_valid,
    output reg        framing_error
);
    localparam [1:0] IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    reg [1:0] state;
    reg [3:0] sample_count;
    reg [2:0] bit_index;
    reg [7:0] shift_reg;
    reg rx_meta, rx_sync;

    always @(posedge clk) begin
        rx_meta <= rx;
        rx_sync <= rx_meta;
        if (reset) begin
            state         <= IDLE;
            sample_count  <= 4'd0;
            bit_index     <= 3'd0;
            shift_reg     <= 8'd0;
            rx_data       <= 8'd0;
            rx_valid      <= 1'b0;
            framing_error <= 1'b0;
        end else begin
            rx_valid <= 1'b0;
            if (baud16_tick) begin
                case (state)
                    IDLE: begin
                        sample_count <= 4'd0;
                        if (!rx_sync)
                            state <= START;
                    end
                    START: begin
                        if (sample_count == 4'd7) begin
                            sample_count <= 4'd0;
                            if (!rx_sync) begin
                                bit_index <= 3'd0;
                                state <= DATA;
                            end else
                                state <= IDLE;
                        end else
                            sample_count <= sample_count + 1'b1;
                    end
                    DATA: begin
                        if (sample_count == 4'd15) begin
                            sample_count <= 4'd0;
                            shift_reg[bit_index] <= rx_sync;
                            if (bit_index == 3'd7)
                                state <= STOP;
                            else
                                bit_index <= bit_index + 1'b1;
                        end else
                            sample_count <= sample_count + 1'b1;
                    end
                    default: begin
                        if (sample_count == 4'd15) begin
                            sample_count  <= 4'd0;
                            framing_error <= !rx_sync;
                            if (rx_sync) begin
                                rx_data  <= shift_reg;
                                rx_valid <= 1'b1;
                            end
                            state <= IDLE;
                        end else
                            sample_count <= sample_count + 1'b1;
                    end
                endcase
            end
        end
    end
endmodule
