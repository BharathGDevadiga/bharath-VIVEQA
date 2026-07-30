`timescale 1ns/1ps

module security_controller (
    input  wire clk,
    input  wire reset,
    input  wire packet_valid,
    input  wire packet_crc_ok,
    input  wire replay_done,
    input  wire replay_detected,
    input  wire xadc_glitch,
    input  wire clear_alarm,
    output reg  replay_check_start,
    output reg  command_accepted,
    output reg  command_rejected,
    output reg  alarm_latched,
    output wire aes_reset,
    output reg [2:0] secure_state
);
    localparam [2:0] IDLE = 3'd0, CRC_CHECK = 3'd1, REPLAY_CHECK = 3'd2,
                     ACCEPT = 3'd3, REJECT = 3'd4, LOCKDOWN = 3'd5;
    assign aes_reset = alarm_latched | xadc_glitch;

    always @(posedge clk) begin
        if (reset) begin
            replay_check_start <= 1'b0;
            command_accepted <= 1'b0;
            command_rejected <= 1'b0;
            alarm_latched <= 1'b0;
            secure_state <= IDLE;
        end else begin
            replay_check_start <= 1'b0;
            command_accepted <= 1'b0;
            command_rejected <= 1'b0;
            if (clear_alarm && !xadc_glitch && secure_state != CRC_CHECK && secure_state != REPLAY_CHECK)
                alarm_latched <= 1'b0;
            if (xadc_glitch) begin
                alarm_latched <= 1'b1;
                command_rejected <= 1'b1;
                secure_state <= LOCKDOWN;
            end else begin
                case (secure_state)
                    IDLE: if (packet_valid) secure_state <= CRC_CHECK;
                    CRC_CHECK: begin
                        if (packet_crc_ok) begin
                            replay_check_start <= 1'b1;
                            secure_state <= REPLAY_CHECK;
                        end else begin
                            alarm_latched <= 1'b1;
                            secure_state <= REJECT;
                        end
                    end
                    REPLAY_CHECK: if (replay_done) begin
                        if (replay_detected) begin
                            alarm_latched <= 1'b1;
                            secure_state <= REJECT;
                        end else
                            secure_state <= ACCEPT;
                    end
                    ACCEPT: begin
                        command_accepted <= 1'b1;
                        secure_state <= IDLE;
                    end
                    REJECT: begin
                        command_rejected <= 1'b1;
                        secure_state <= LOCKDOWN;
                    end
                    default: if (clear_alarm) secure_state <= IDLE;
                endcase
            end
        end
    end
endmodule
