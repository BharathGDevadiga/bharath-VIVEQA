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

    // Timed lockdown: 24 MHz * 5 seconds = 120_000_000 cycles
    // Using a 27-bit counter (max 134M, enough for 5s at 24 MHz)
    localparam [26:0] LOCKDOWN_TIMEOUT = 27'd120_000_000;
    reg [26:0] lockdown_counter;
    // 1-cycle buffer: prevents clear_alarm from racing against a still-high glitch signal
    reg xadc_glitch_r;

    assign aes_reset = alarm_latched | xadc_glitch_r;

    always @(posedge clk) begin
        if (reset) begin
            replay_check_start <= 1'b0;
            command_accepted   <= 1'b0;
            command_rejected   <= 1'b0;
            alarm_latched      <= 1'b0;
            secure_state       <= IDLE;
            lockdown_counter   <= 27'd0;
            xadc_glitch_r      <= 1'b0;
        end else begin
            xadc_glitch_r <= xadc_glitch;  // register one cycle ahead
            replay_check_start <= 1'b0;
            command_accepted <= 1'b0;
            command_rejected <= 1'b0;

            // Clear alarm only when FSM is idle or in lockdown (not mid-processing)
            if (clear_alarm && !xadc_glitch_r &&
                secure_state != CRC_CHECK && secure_state != REPLAY_CHECK &&
                secure_state != ACCEPT && secure_state != REJECT) begin
                alarm_latched <= 1'b0;
            end

            if (xadc_glitch_r) begin
                alarm_latched <= 1'b1;
                command_rejected <= 1'b1;
                secure_state <= LOCKDOWN;
                lockdown_counter <= 27'd0;
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
                        lockdown_counter <= 27'd0;
                    end
                    // LOCKDOWN: auto-release after timeout OR immediate release via clear_alarm
                    default: begin
                        if (clear_alarm) begin
                            secure_state <= IDLE;
                            alarm_latched <= 1'b0;
                        end else if (lockdown_counter >= LOCKDOWN_TIMEOUT) begin
                            secure_state <= IDLE;
                            // alarm_latched stays set — user must press clear_alarm to silence buzzer
                        end else begin
                            lockdown_counter <= lockdown_counter + 27'd1;
                        end
                    end
                endcase
            end
        end
    end
endmodule
