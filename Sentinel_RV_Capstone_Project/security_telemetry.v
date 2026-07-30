`timescale 1ns/1ps

// Buffers ADC/status telemetry for Team 2 and emits AES-128 keyed event-chain
// digests for the Team 2 SD audit log. The AES operation is a one-block PRF:
// AES_K(previous_digest XOR event_metadata).
module security_telemetry (
    input  wire         clk,
    input  wire         reset,
    input  wire [11:0]  adc_sample,
    input  wire         adc_sample_valid,
    input  wire         command_busy,
    input  wire         result_valid,
    input  wire         result_accepted,
    input  wire [7:0]   result_opcode,
    input  wire [15:0]  result_argument,
    input  wire         alarm,
    input  wire [127:0] session_key,
    input  wire [127:0] previous_digest,
    output wire         telemetry_valid,
    input  wire         telemetry_ready,
    output reg [7:0]   telemetry_sequence,
    output reg [7:0]   telemetry_event,
    output reg [11:0]  telemetry_sensor,
    output reg [7:0]   telemetry_status,
    output reg         lcd_refresh,
    output reg [127:0] lcd_line1,
    output reg [127:0] lcd_line2,
    output wire [15:0] led_status,
    output wire         buzzer_enable,
    output wire [15:0] sevenseg_value,
    output wire         sevenseg_enable,
    output reg          audit_request,
    input  wire         audit_ready,
    output reg [127:0]  audit_digest
);
    reg telemetry_pending;
    reg [7:0] sequence_counter;
    reg last_accepted;
    reg last_rejected;
    reg first_refresh;
    reg audit_start;
    reg audit_busy;
    reg [127:0] audit_block;
    wire [127:0] audit_cipher;
    wire audit_cipher_busy;
    wire audit_cipher_done;

    aes128_encrypt audit_prf (
        .clk(clk), .reset(reset), .start(audit_start), .plaintext(audit_block), .key(session_key),
        .ciphertext(audit_cipher), .busy(audit_cipher_busy), .done(audit_cipher_done)
    );

    assign telemetry_valid = telemetry_pending;
    assign led_status = {11'd0, command_busy, last_rejected, last_accepted, alarm, 1'b1};
    assign buzzer_enable = 1'b1;
    assign sevenseg_value = {4'd0, adc_sample};
    assign sevenseg_enable = 1'b1;

    always @(posedge clk) begin
        if (reset) begin
            telemetry_pending <= 1'b0;
            telemetry_sequence <= 8'd0;
            telemetry_event <= 8'd0;
            telemetry_sensor <= 12'd0;
            telemetry_status <= 8'd0;
            sequence_counter <= 8'd0;
            last_accepted <= 1'b0;
            last_rejected <= 1'b0;
            first_refresh <= 1'b1;
            lcd_refresh <= 1'b0;
            lcd_line1 <= "SENTINEL-RV OK  ";
            lcd_line2 <= "ADC SECURE LINK ";
            audit_start <= 1'b0;
            audit_busy <= 1'b0;
            audit_request <= 1'b0;
            audit_digest <= 128'd0;
            audit_block <= 128'd0;
        end else begin
            lcd_refresh <= 1'b0;
            audit_start <= 1'b0;
            if (first_refresh) begin
                first_refresh <= 1'b0;
                lcd_refresh <= 1'b1;
            end
            if (telemetry_pending && telemetry_ready)
                telemetry_pending <= 1'b0;
            else if (!telemetry_pending && result_valid) begin
                telemetry_pending <= 1'b1;
                telemetry_sequence <= sequence_counter;
                telemetry_event <= result_accepted ? 8'h10 : 8'hE1;
                telemetry_sensor <= adc_sample;
                telemetry_status <= {5'd0, !result_accepted, result_accepted, alarm};
                sequence_counter <= sequence_counter + 1'b1;
            end else if (!telemetry_pending && adc_sample_valid) begin
                telemetry_pending <= 1'b1;
                telemetry_sequence <= sequence_counter;
                telemetry_event <= 8'h01;
                telemetry_sensor <= adc_sample;
                telemetry_status <= {7'd0, alarm};
                sequence_counter <= sequence_counter + 1'b1;
            end
            if (result_valid) begin
                last_accepted <= result_accepted;
                last_rejected <= !result_accepted;
                lcd_refresh <= 1'b1;
                if (alarm) begin
                    lcd_line1 <= "SECURITY ALARM  ";
                    lcd_line2 <= "ACTUATION LOCK  ";
                end else if (result_accepted) begin
                    lcd_line1 <= "COMMAND ACCEPTED";
                    lcd_line2 <= "SECURE ACTUATION";
                end else begin
                    lcd_line1 <= "COMMAND REJECTED";
                    lcd_line2 <= "SECURITY LOCKED ";
                end
                if (!audit_busy && !audit_request) begin
                    audit_block <= previous_digest ^ {result_opcode, result_argument, result_accepted,
                                                      1'b0, adc_sample, 90'd0};
                    audit_start <= 1'b1;
                    audit_busy <= 1'b1;
                end
            end
            if (audit_busy && audit_cipher_done) begin
                audit_digest <= audit_cipher;
                audit_request <= 1'b1;
                audit_busy <= 1'b0;
            end else if (audit_request && audit_ready) begin
                audit_request <= 1'b0;
            end
        end
    end
endmodule
