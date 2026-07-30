`timescale 1ns/1ps

// SDHC initialization over the byte-oriented SPI engine.  The card must be
// powered and inserted before reset is released.  Supports CMD0, CMD8,
// CMD55/ACMD41 with HCS, and CMD58.  SDSC byte-addressed cards are rejected.
module sd_card_init #(
    parameter integer ACMD41_RETRIES = 1024
) (
    input  wire       clk,
    input  wire       reset,
    output reg        init_busy,
    output reg        init_done,
    output reg        init_failed,
    output reg        xfer_start,
    output reg [7:0]  xfer_data,
    output reg        xfer_hold_cs,
    output reg        xfer_force_cs_high,
    input  wire [7:0] xfer_rx,
    input  wire       xfer_busy,
    input  wire       xfer_done
);
    localparam [2:0] PRECLOCK = 3'd0, COMMAND = 3'd1, RESPONSE = 3'd2,
                     EXT_RESPONSE = 3'd3, RELEASE = 3'd4, COMPLETE = 3'd5;
    localparam [2:0] CMD0 = 3'd0, CMD8 = 3'd1, CMD55 = 3'd2,
                     ACMD41 = 3'd3, CMD58 = 3'd4;
    reg [2:0] state, command_phase, next_phase;
    reg issued;
    reg [3:0] byte_index;
    reg [3:0] preclock_count;
    reg [7:0] response_tries;
    reg [1:0] extended_index;
    reg [15:0] acmd41_tries;
    reg ocr_ccs;

    function [7:0] command_byte;
        input [2:0] phase;
        input [3:0] index;
        begin
            case (phase)
                CMD0: case (index)
                    0: command_byte = 8'h40; 1,2,3,4: command_byte = 8'h00; default: command_byte = 8'h95;
                endcase
                CMD8: case (index)
                    0: command_byte = 8'h48; 1,2: command_byte = 8'h00;
                    3: command_byte = 8'h01; 4: command_byte = 8'hAA; default: command_byte = 8'h87;
                endcase
                CMD55: case (index)
                    0: command_byte = 8'h77; 1,2,3,4: command_byte = 8'h00; default: command_byte = 8'h65;
                endcase
                ACMD41: case (index)
                    0: command_byte = 8'h69; 1: command_byte = 8'h40; 2,3,4: command_byte = 8'h00; default: command_byte = 8'h77;
                endcase
                default: case (index)
                    0: command_byte = 8'h7A; 1,2,3,4: command_byte = 8'h00; default: command_byte = 8'hFD;
                endcase
            endcase
        end
    endfunction

    task fail_init;
        begin
            init_busy <= 1'b0;
            init_failed <= 1'b1;
            state <= COMPLETE;
        end
    endtask

    always @(posedge clk) begin
        if (reset) begin
            state <= PRECLOCK;
            command_phase <= CMD0;
            next_phase <= CMD0;
            issued <= 1'b0;
            byte_index <= 0;
            preclock_count <= 0;
            response_tries <= 0;
            extended_index <= 0;
            acmd41_tries <= 0;
            ocr_ccs <= 1'b0;
            init_busy <= 1'b1;
            init_done <= 1'b0;
            init_failed <= 1'b0;
            xfer_start <= 1'b0;
            xfer_data <= 8'hFF;
            xfer_hold_cs <= 1'b0;
            xfer_force_cs_high <= 1'b1;
        end else begin
            xfer_start <= 1'b0;
            case (state)
                PRECLOCK: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= 1'b0;
                    xfer_force_cs_high <= 1'b1;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (preclock_count == 4'd9) begin
                        command_phase <= CMD0;
                        byte_index <= 0;
                        state <= COMMAND;
                    end else
                        preclock_count <= preclock_count + 1'b1;
                end
                COMMAND: if (!issued && !xfer_busy) begin
                    xfer_data <= command_byte(command_phase, byte_index);
                    xfer_hold_cs <= 1'b1;
                    xfer_force_cs_high <= 1'b0;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (byte_index == 4'd5) begin
                        response_tries <= 0;
                        state <= RESPONSE;
                    end else
                        byte_index <= byte_index + 1'b1;
                end
                RESPONSE: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= 1'b1;
                    xfer_force_cs_high <= 1'b0;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (xfer_rx == 8'hFF) begin
                        if (response_tries == 8'hFF)
                            fail_init;
                        else
                            response_tries <= response_tries + 1'b1;
                    end else if (command_phase == CMD0 && xfer_rx == 8'h01) begin
                        next_phase <= CMD8;
                        state <= RELEASE;
                    end else if (command_phase == CMD8 && xfer_rx == 8'h01) begin
                        extended_index <= 0;
                        state <= EXT_RESPONSE;
                    end else if (command_phase == CMD55 && (xfer_rx == 8'h00 || xfer_rx == 8'h01)) begin
                        next_phase <= ACMD41;
                        state <= RELEASE;
                    end else if (command_phase == ACMD41 && xfer_rx == 8'h00) begin
                        next_phase <= CMD58;
                        state <= RELEASE;
                    end else if (command_phase == ACMD41 && xfer_rx == 8'h01) begin
                        if (acmd41_tries == ACMD41_RETRIES - 1)
                            fail_init;
                        else begin
                            acmd41_tries <= acmd41_tries + 1'b1;
                            next_phase <= CMD55;
                            state <= RELEASE;
                        end
                    end else if (command_phase == CMD58 && xfer_rx == 8'h00) begin
                        extended_index <= 0;
                        state <= EXT_RESPONSE;
                    end else
                        fail_init;
                end
                EXT_RESPONSE: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= (extended_index != 2'd3);
                    xfer_force_cs_high <= 1'b0;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (command_phase == CMD58 && extended_index == 2'd0)
                        ocr_ccs <= xfer_rx[6];
                    if (extended_index == 2'd3) begin
                        if (command_phase == CMD8) begin
                            if (xfer_rx == 8'hAA) begin
                                command_phase <= CMD55;
                                byte_index <= 0;
                                state <= COMMAND;
                            end else
                                fail_init;
                        end else if (ocr_ccs) begin
                            init_busy <= 1'b0;
                            init_done <= 1'b1;
                            state <= COMPLETE;
                        end else
                            fail_init;
                    end else
                        extended_index <= extended_index + 1'b1;
                end
                RELEASE: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= 1'b0;
                    xfer_force_cs_high <= 1'b0;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    command_phase <= next_phase;
                    byte_index <= 0;
                    state <= COMMAND;
                end
                default: begin
                    init_busy <= 1'b0;
                    xfer_force_cs_high <= 1'b0;
                end
            endcase
        end
    end
endmodule
