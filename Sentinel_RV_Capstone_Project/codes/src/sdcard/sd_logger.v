`timescale 1ns/1ps

module sd_logger #(
    parameter [31:0] FIRST_SECTOR = 32'd2048
) (
    input  wire         clk,
    input  wire         reset,
    input  wire         log_valid,
    output wire         log_ready,
    input  wire [255:0] log_record,
    output reg          logger_busy,
    output reg          log_done,
    output reg          log_failed,
    output reg          writer_start,
    output reg [31:0]   writer_sector,
    output reg [255:0]  writer_record,
    output reg [5:0]    writer_length,
    input  wire         writer_busy,
    input  wire         writer_done,
    input  wire         writer_failed
);
    localparam [1:0] IDLE = 2'd0, LAUNCH = 2'd1, WAIT = 2'd2;
    reg [1:0] state;
    reg [31:0] next_sector;
    assign log_ready = (state == IDLE);

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            next_sector <= FIRST_SECTOR;
            logger_busy <= 1'b0;
            log_done <= 1'b0;
            log_failed <= 1'b0;
            writer_start <= 1'b0;
            writer_sector <= FIRST_SECTOR;
            writer_record <= 0;
            writer_length <= 0;
        end else begin
            writer_start <= 1'b0;
            log_done <= 1'b0;
            log_failed <= 1'b0;
            case (state)
                IDLE: if (log_valid) begin
                    writer_sector <= next_sector;
                    writer_record <= log_record;
                    writer_length <= 6'd32;
                    logger_busy <= 1'b1;
                    state <= LAUNCH;
                end
                LAUNCH: begin
                    writer_start <= 1'b1;
                    state <= WAIT;
                end
                default: if (writer_done) begin
                    next_sector <= next_sector + 1'b1;
                    logger_busy <= 1'b0;
                    log_done <= 1'b1;
                    state <= IDLE;
                end else if (writer_failed) begin
                    logger_busy <= 1'b0;
                    log_failed <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
