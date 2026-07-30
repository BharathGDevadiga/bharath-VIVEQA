`timescale 1ns/1ps

module sentinel_rv_board_top #(
    parameter integer SD_TEST_ENABLE = 1,
    parameter [127:0] AUDIT_KEY = 128'h000102030405060708090A0B0C0D0E0F,
    parameter integer SD_DETECT_ACTIVE_LOW = 1
) (
    input wire clk_24mhz,
    input wire reset,              // S1 (C9) - Move DOWN for reset, UP to run
    input wire clear_alarm,        // S2 (B9) - Alarm Clear / Silence Buzzer
    input wire sw_display_lock,    // S3 (G5) - Lock 7-Seg on Temperature
    input wire sw_alarm_test,      // S4 (A7) - Manual Alarm Test
    input wire sw_relay_force,     // S5 (C7) - Manual Relay Force ON
    input wire sw_tamper_boost,    // S6 (A10) - Tamper Glitch Sensitivity Boost
    input wire sw_sd_log_enable,   // S7 (B7) - SD Card Audit Log Enable
    input wire sw_clock_heartbeat, // S8 (A8) - Master Clock Heartbeat Enable
    input wire pmod_uart_rx,
    output wire pmod_uart_tx,
    output wire adc_sck,
    output wire adc_mosi,
    input wire adc_miso,
    output wire adc_cs_n,
    output wire sd_clk,
    output wire sd_cmd,
    input wire sd_d0,
    output wire sd_cs_n,
    input wire sd_detect_n,
    output wire lcd_rs,
    output wire lcd_rw,
    output wire lcd_en,
    output wire [7:0] lcd_d,
    output wire [3:0] keypad_row_n,
    input wire [3:0] keypad_col_n,
    output wire [7:0] led,         // L1 to L8 LEDs directly mapped to S1 to S8
    output wire buzzer,
    output wire seg_din,
    output wire seg_clk,
    output wire seg_load,
    output wire relay_in,
    inout wire dht11_data,
    input wire hc_sr04_echo,
    output wire hc_sr04_trigger
);
    wire [15:0] led_internal;
    wire sd_storage_failed;
    wire sd_write_done;
    wire sd_write_error;
    wire sd_card_missing;
    reg sd_write_done_latched;
    reg sd_write_error_latched;
    reg [24:0] sd_test_counter;
    reg sd_test_fired;
    reg sd_test_request;

    localparam integer XADC_TICK_CYCLES = 24_000 - 1;  // 1 ms at 24 MHz
    reg [14:0] xadc_tick_counter;
    reg xadc_sample_tick;

    localparam [11:0] XADC_VCCINT_STUB  = 12'h550;
    localparam [11:0] XADC_TEMP_STUB    = 12'h500;
    localparam integer SD_TEST_DELAY_CYCLES = 24_000_000 - 1;

    always @(posedge clk_24mhz) begin
        if (reset) begin
            sd_test_counter <= 25'd0;
            sd_test_fired <= 1'b0;
            sd_test_request <= 1'b0;
            sd_write_done_latched <= 1'b0;
            sd_write_error_latched <= 1'b0;
        end else if (SD_TEST_ENABLE && !sd_test_fired) begin
            sd_test_request <= 1'b0;
            if (sd_write_done)
                sd_write_done_latched <= 1'b1;
            if (sd_write_error)
                sd_write_error_latched <= 1'b1;
            if (sd_test_counter == SD_TEST_DELAY_CYCLES) begin
                sd_test_request <= 1'b1;
                sd_test_fired <= 1'b1;
            end else begin
                sd_test_counter <= sd_test_counter + 1'b1;
            end
        end else begin
            sd_test_request <= 1'b0;
            if (sd_write_done)
                sd_write_done_latched <= 1'b1;
            if (sd_write_error)
                sd_write_error_latched <= 1'b1;
        end
    end

    always @(posedge clk_24mhz) begin
        if (reset) begin
            xadc_tick_counter <= 15'd0;
            xadc_sample_tick  <= 1'b0;
        end else begin
            if (xadc_tick_counter == XADC_TICK_CYCLES[14:0]) begin
                xadc_tick_counter <= 15'd0;
                xadc_sample_tick  <= 1'b1;
            end else begin
                xadc_tick_counter <= xadc_tick_counter + 1'b1;
                xadc_sample_tick  <= 1'b0;
            end
        end
    end

    // 1-to-1 Direct Mapping of LEDs L1-L8 above Switches S1-S8
    assign led[0] = !reset;                                // L1 (D5) - Power / System Run
    assign led[1] = clear_alarm | led_internal[1];         // L2 (A3) - Alarm Clear / ACK
    assign led[2] = sw_display_lock;                       // L3 (B4) - Display Lock
    assign led[3] = sw_alarm_test | led_internal[4];       // L4 (A4) - Alarm Test / Alarm
    assign led[4] = relay_in;                              // L5 (E6) - Relay Status (ON/OFF)
    assign led[5] = led_internal[5];                       // L6 (C13) - CPU Heartbeat
    assign led[6] = sd_write_done_latched | sw_sd_log_enable;// L7 (C14) - SD Log Active
    assign led[7] = 1'b1;                                  // L8 (D14) - 24 MHz Master Clock Active

    sentinel_rv_top #(
        .AUDIT_KEY(AUDIT_KEY),
        .SD_DETECT_ACTIVE_LOW(SD_DETECT_ACTIVE_LOW)
    ) system_wrapper (
        .clk_24mhz(clk_24mhz), .reset(reset),
        .pmod_uart_rx(pmod_uart_rx), .pmod_uart_tx(pmod_uart_tx),
        .adc_sck(adc_sck), .adc_mosi(adc_mosi), .adc_miso(adc_miso), .adc_cs_n(adc_cs_n),
        .sd_clk(sd_clk), .sd_cmd(sd_cmd), .sd_d0(sd_d0), .sd_cs_n(sd_cs_n), .sd_detect_n(sd_detect_n),
        .lcd_rs(lcd_rs), .lcd_rw(lcd_rw), .lcd_en(lcd_en), .lcd_d(lcd_d),
        .keypad_row_n(keypad_row_n), .keypad_col_n(keypad_col_n), .led(led_internal),
        .buzzer(buzzer), .seg_din(seg_din), .seg_clk(seg_clk), .seg_load(seg_load),
        .relay_in(relay_in),
        .dht11_data(dht11_data), .hc_sr04_echo(hc_sr04_echo), .hc_sr04_trigger(hc_sr04_trigger),
        .security_clear_alarm(clear_alarm | sw_alarm_test),
        .security_xadc_sample_valid(xadc_sample_tick),
        .security_xadc_vccint_code(XADC_VCCINT_STUB),
        .security_xadc_temperature_code(XADC_TEMP_STUB),
        .security_command_accepted(), .security_command_rejected(),
        .security_alarm(), .security_aes_reset(),
        .security_tx_start(1'b0), .security_tx_plaintext(128'd0),
        .security_tx_key(128'd0), .security_tx_nonce(64'd0),
        .security_tx_sequence(8'd0), .security_tx_packet(),
        .security_tx_packet_valid(), .security_tx_busy(), .security_cpu_trap(),
        .security_audit_request(sd_test_request),
        .security_audit_digest(128'h112233445566778899AABBCCDDEEFF00),
        .security_audit_ready(), .security_audit_chain_head(),
        .security_audit_storage_failed(sd_storage_failed),
        .security_sd_write_done(sd_write_done),
        .security_sd_write_error(sd_write_error),
        .security_sd_card_missing(sd_card_missing),
        .security_key_valid(), .security_key_ascii()
    );
endmodule
