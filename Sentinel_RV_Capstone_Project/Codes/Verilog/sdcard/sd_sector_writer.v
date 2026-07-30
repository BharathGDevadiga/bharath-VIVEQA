`timescale 1ns/1ps

// Writes one 512-byte SDHC sector using CMD24. record_data is placed at the
// start of the sector and remaining bytes are zero-filled.  Card initialization
// (CMD0/CMD8/ACMD41/CMD58) must complete before write_start is asserted.
module sd_sector_writer (
    input  wire         clk,
    input  wire         reset,
    input  wire         write_start,
    input  wire [31:0]  sector_address,
    input  wire [255:0] record_data,
    input  wire [5:0]   record_length,
    output reg          busy,
    output reg          done,
    output reg          failed,
    output reg          xfer_start,
    output reg [7:0]    xfer_data,
    output reg          xfer_hold_cs,
    input  wire [7:0]   xfer_rx,
    input  wire         xfer_busy,
    input  wire         xfer_done
);
    localparam [2:0] IDLE = 3'd0, COMMAND = 3'd1, RESPONSE = 3'd2,
                     DATA = 3'd3, DATA_RESPONSE = 3'd4, BUSY_WAIT = 3'd5,
                     RELEASE = 3'd6;
    reg [2:0] state;
    reg issued;
    reg [2:0] command_index;
    reg [9:0] data_index;
    reg [8:0] response_tries;
    reg [15:0] busy_timeout;
    reg [31:0] sector_reg;
    reg [255:0] record_reg;
    reg [5:0] length_reg;

    function [7:0] command_byte;
        input [2:0] index;
        begin
            case (index)
                3'd0: command_byte = 8'h58; // CMD24
                3'd1: command_byte = sector_reg[31:24];
                3'd2: command_byte = sector_reg[23:16];
                3'd3: command_byte = sector_reg[15:8];
                3'd4: command_byte = sector_reg[7:0];
                default: command_byte = 8'hFF; // CRC ignored after initialization
            endcase
        end
    endfunction

    function [7:0] record_byte;
        input [5:0] index;
        begin
            if (index < length_reg)
                record_byte = record_reg >> (8 * (31 - index));
            else
                record_byte = 8'h00;
        end
    endfunction

    function [7:0] data_byte;
        input [9:0] index;
        begin
            if (index == 0)
                data_byte = 8'hFE;
            else if (index <= 512)
                data_byte = record_byte(index - 1'b1);
            else
                data_byte = 8'hFF; // two CRC bytes
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            issued <= 1'b0;
            command_index <= 0;
            data_index <= 0;
            response_tries <= 0;
            busy_timeout <= 0;
            sector_reg <= 0;
            record_reg <= 0;
            length_reg <= 0;
            busy <= 1'b0;
            done <= 1'b0;
            failed <= 1'b0;
            xfer_start <= 1'b0;
            xfer_data <= 8'hFF;
            xfer_hold_cs <= 1'b0;
        end else begin
            xfer_start <= 1'b0;
            done <= 1'b0;
            failed <= 1'b0;
            case (state)
                IDLE: if (write_start) begin
                    busy <= 1'b1;
                    sector_reg <= sector_address;
                    record_reg <= record_data;
                    length_reg <= (record_length > 32) ? 32 : record_length;
                    command_index <= 0;
                    issued <= 1'b0;
                    state <= COMMAND;
                end
                COMMAND: if (!issued && !xfer_busy) begin
                    xfer_data <= command_byte(command_index);
                    xfer_hold_cs <= 1'b1;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (command_index == 3'd5) begin
                        response_tries <= 0;
                        state <= RESPONSE;
                    end else
                        command_index <= command_index + 1'b1;
                end
                RESPONSE: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= 1'b1;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (xfer_rx == 8'hFF) begin
                        if (response_tries == 9'd255) begin
                            busy <= 1'b0;
                            failed <= 1'b1;
                            state <= IDLE;
                        end else
                            response_tries <= response_tries + 1'b1;
                    end else if (xfer_rx == 8'h00) begin
                        data_index <= 0;
                        state <= DATA;
                    end else begin
                        busy <= 1'b0;
                        failed <= 1'b1;
                        state <= IDLE;
                    end
                end
                DATA: if (!issued && !xfer_busy) begin
                    xfer_data <= data_byte(data_index);
                    xfer_hold_cs <= 1'b1;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (data_index == 10'd514)
                        state <= DATA_RESPONSE;
                    else
                        data_index <= data_index + 1'b1;
                end
                DATA_RESPONSE: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= 1'b1;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (xfer_rx[4:0] == 5'b00101) begin
                        busy_timeout <= 0;
                        state <= BUSY_WAIT;
                    end else begin
                        busy <= 1'b0;
                        failed <= 1'b1;
                        state <= IDLE;
                    end
                end
                BUSY_WAIT: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= 1'b1;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (xfer_rx == 8'hFF) begin
                        state <= RELEASE;
                    end else begin
                        if (busy_timeout == 16'hFFFF) begin
                            busy <= 1'b0;
                            failed <= 1'b1;
                            state <= IDLE;
                        end else
                            busy_timeout <= busy_timeout + 1'b1;
                    end
                end
                RELEASE: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= 1'b0;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
