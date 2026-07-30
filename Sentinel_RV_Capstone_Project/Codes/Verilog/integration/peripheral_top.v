`timescale 1ns/1ps

module peripheral_top #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer UART_BAUD = 115_200,
    parameter integer SD_DETECT_ACTIVE_LOW = 1
) (
    input  wire         clk_24mhz,
    input  wire         reset,

    input  wire         pmod_uart_rx,
    output wire         pmod_uart_tx,
    input  wire         esp_uart_rx,
    output wire         esp_uart_tx,

    output wire         adc_sck,
    output wire         adc_mosi,
    input  wire         adc_miso,
    output wire         adc_cs_n,
    output wire         sd_clk,
    output wire         sd_cmd,
    input  wire         sd_d0,
    output wire         sd_cs_n,
    input  wire         sd_detect_n,

    output wire         lcd_rs,
    output wire         lcd_rw,
    output wire         lcd_en,
    output wire [7:0]   lcd_d,
    output wire [3:0]   keypad_row_n,
    input  wire [3:0]   keypad_col_n,
    output wire [15:0]  led,
    output wire         buzzer,
    output wire         seg_din,
    output wire         seg_clk,
    output wire         seg_load,
    output wire         relay_in,

    inout  wire         dht11_data,
    input  wire         hc_sr04_echo,
    output wire         hc_sr04_trigger,

    output wire [11:0]  core_adc_sample,
    output wire         core_adc_sample_valid,
    input  wire         core_adc_channel,
    input  wire         core_adc_force_sample,
    output wire [7:0]   core_dht11_temp,
    output wire [7:0]   core_dht11_hum,
    output wire [15:0]  core_distance,
    output wire         core_key_valid,
    output wire [7:0]   core_key_ascii,
    output wire         core_command_valid,
    input  wire         core_command_ready,
    output wire [7:0]   core_command_opcode,
    output wire [7:0]   core_command_sequence,
    output wire [15:0]  core_command_argument,
    output wire         core_command_source,

    input  wire         core_telemetry_valid,
    output wire         core_telemetry_ready,
    input  wire [7:0]   core_telemetry_sequence,
    input  wire [7:0]   core_telemetry_event,
    input  wire [11:0]  core_telemetry_sensor,
    input  wire [7:0]   core_telemetry_status,

    input  wire         core_lcd_refresh,
    input  wire [127:0] core_lcd_line1,
    input  wire [127:0] core_lcd_line2,
    input  wire [15:0]  core_led_status,
    input  wire         core_alarm,
    input  wire         core_buzzer_enable,
    input  wire [15:0]  core_sevenseg_value,
    input  wire         core_sevenseg_enable,

    input  wire         core_actuator_authorized,
    input  wire         core_relay_set,
    input  wire         core_relay_reset,
    input  wire         core_motor_enable,
    input  wire [1:0]   core_motor_command,
    input  wire [7:0]   core_motor_speed,
    input  wire         core_stepper_start,
    input  wire         core_stepper_direction,
    input  wire [15:0]  core_stepper_count,
    input  wire [23:0]  core_stepper_period,
    output wire         core_actuator_denied,
    output wire         core_stepper_busy,
    output wire         core_stepper_done,
    output wire         core_transport_error,
    output wire [7:0]   core_transport_error_source_id,

    input  wire         core_audit_request,
    output wire         core_audit_ready,
    input  wire [127:0] core_audit_digest,
    input  wire [127:0] core_audit_metadata,
    output wire [127:0] core_audit_chain_head,
    output wire         core_audit_storage_failed,
    output wire         core_sd_write_done,
    output wire         core_sd_write_error,
    output wire         core_sd_card_missing
);
    wire [7:0] pmod_rx_data, esp_rx_data;
    wire pmod_rx_valid, esp_rx_valid, pmod_framing_error, esp_framing_error;
    wire pmod_tx_start, esp_tx_start, pmod_tx_busy, esp_tx_busy;
    wire [7:0] pmod_tx_data, esp_tx_data;
    wire pmod_cmd_valid, pmod_cmd_error;
    wire [7:0] pmod_cmd_opcode, pmod_cmd_sequence;
    wire [15:0] pmod_cmd_argument;
    wire esp_message_valid, esp_message_error;
    wire [7:0] esp_message_type;
    wire [15:0] esp_message_value;
    wire telemetry_valid, telemetry_ready;
    wire [7:0] telemetry_sequence, telemetry_event, telemetry_status;
    wire [11:0] telemetry_sensor;
    wire pmod_telemetry_ready, esp_telemetry_ready;

    wire lcd_write, lcd_write_rs, lcd_ready;
    wire [7:0] lcd_write_data;
    wire [3:0] keypad_code;
    wire keypad_valid;
    wire relay_denied;
    wire audit_record_valid, audit_record_ready, logger_log_ready;
    wire [255:0] audit_record;
    wire logger_busy, logger_done, logger_failed;
    wire writer_start, writer_busy, writer_done, writer_failed;
    wire [31:0] writer_sector;
    wire [255:0] writer_record;
    wire [5:0] writer_length;
    wire sd_xfer_start, sd_xfer_busy, sd_xfer_done, sd_xfer_hold_cs;
    wire [7:0] sd_xfer_data, sd_xfer_rx;
    wire sd_init_busy, sd_init_done, sd_init_failed;
    wire sd_init_xfer_start, sd_init_xfer_hold_cs, sd_init_force_cs_high;
    wire [7:0] sd_init_xfer_data;
    wire sd_bus_xfer_start, sd_bus_xfer_hold_cs, sd_bus_force_cs_high;
    wire [7:0] sd_bus_xfer_data;

    wire dht_in, dht_out, dht_oe, dht_valid;
    wire [7:0] dht_temp, dht_hum;
    wire [15:0] hc_dist;
    wire hc_valid;

    uart_top #(.CLK_HZ(CLK_HZ), .BAUD(UART_BAUD)) pmod_uart (
        .clk(clk_24mhz), .reset(reset), .uart_rx_i(pmod_uart_rx), .uart_tx_o(pmod_uart_tx),
        .tx_start(pmod_tx_start), .tx_data(pmod_tx_data), .tx_busy(pmod_tx_busy),
        .rx_data(pmod_rx_data), .rx_valid(pmod_rx_valid), .framing_error(pmod_framing_error)
    );
    sentinel_command_rx pmod_command (
        .clk(clk_24mhz), .reset(reset), .rx_data(pmod_rx_data), .rx_valid(pmod_rx_valid),
        .cmd_valid(pmod_cmd_valid), .cmd_opcode(pmod_cmd_opcode), .cmd_sequence(pmod_cmd_sequence),
        .cmd_argument(pmod_cmd_argument), .cmd_error(pmod_cmd_error)
    );
    sentinel_telemetry_tx pmod_telemetry (
        .clk(clk_24mhz), .reset(reset), .telemetry_valid(telemetry_valid),
        .telemetry_ready(pmod_telemetry_ready), .telemetry_sequence(telemetry_sequence),
        .telemetry_event(telemetry_event), .telemetry_sensor(telemetry_sensor),
        .dht11_temp(dht_temp), .dht11_hum(dht_hum), .distance(hc_dist),
        .telemetry_status(telemetry_status), .uart_busy(pmod_tx_busy),
        .uart_start(pmod_tx_start), .uart_data(pmod_tx_data)
    );

    assign esp_uart_tx = 1'b1;
    assign esp_tx_busy = 1'b0;
    assign esp_tx_start = 1'b0;
    assign esp_tx_data = 8'd0;
    assign esp_rx_data = 8'd0;
    assign esp_rx_valid = 1'b0;
    assign esp_framing_error = 1'b0;
    assign esp_message_valid = 1'b0;
    assign esp_message_type = 8'd0;
    assign esp_message_value = 16'd0;
    assign esp_message_error = 1'b0;
    assign esp_telemetry_ready = 1'b1;

    peripheral_controller controller (
        .clk(clk_24mhz), .reset(reset), .pmod_cmd_valid(pmod_cmd_valid),
        .pmod_cmd_opcode(pmod_cmd_opcode), .pmod_cmd_sequence(pmod_cmd_sequence),
        .pmod_cmd_argument(pmod_cmd_argument), .esp_cmd_valid(esp_message_valid),
        .esp_cmd_type(esp_message_type), .esp_cmd_value(esp_message_value),
        .core_command_valid(core_command_valid), .core_command_ready(core_command_ready),
        .core_command_opcode(core_command_opcode), .core_command_sequence(core_command_sequence),
        .core_command_argument(core_command_argument), .core_command_source(core_command_source),
        .core_telemetry_valid(core_telemetry_valid), .core_telemetry_ready(core_telemetry_ready),
        .core_telemetry_sequence(core_telemetry_sequence), .core_telemetry_event(core_telemetry_event),
        .core_telemetry_sensor(core_telemetry_sensor), .core_telemetry_status(core_telemetry_status),
        .telemetry_valid(telemetry_valid), .telemetry_ready(telemetry_ready),
        .telemetry_sequence(telemetry_sequence), .telemetry_event(telemetry_event),
        .telemetry_sensor(telemetry_sensor), .telemetry_status(telemetry_status)
    );
    assign telemetry_ready = pmod_telemetry_ready && esp_telemetry_ready;

    mcp3202_sampler #(.CLK_HZ(CLK_HZ)) sampler (
        .clk(clk_24mhz), .reset(reset), .force_sample(core_adc_force_sample), .channel(core_adc_channel),
        .sample_value(core_adc_sample), .sample_valid(core_adc_sample_valid), .busy(),
        .spi_sck(adc_sck), .spi_mosi(adc_mosi), .spi_miso(adc_miso), .adc_cs_n(adc_cs_n)
    );

    // DHT11 Sensor
    assign dht11_data = dht_oe ? dht_out : 1'bz;
    assign dht_in = dht11_data;
    dht11_controller #(.CLK_HZ(CLK_HZ)) dht11 (
        .clk(clk_24mhz), .reset(reset), .dht_in(dht_in), .dht_out(dht_out), .dht_oe(dht_oe),
        .temperature(dht_temp), .humidity(dht_hum), .valid(dht_valid)
    );
    assign core_dht11_temp = dht_temp;
    assign core_dht11_hum = dht_hum;

    // Ultrasonic Sensor
    hc_sr04_controller #(.CLK_HZ(CLK_HZ)) hc_sr04 (
        .clk(clk_24mhz), .reset(reset), .trigger(hc_sr04_trigger), .echo(hc_sr04_echo),
        .distance_cm(hc_dist), .valid(hc_valid)
    );
    assign core_distance = hc_dist;

    lcd_controller lcd_text (
        .clk(clk_24mhz), .reset(reset), .refresh(core_lcd_refresh), .line1(core_lcd_line1),
        .line2(core_lcd_line2), .driver_write(lcd_write), .driver_rs(lcd_write_rs),
        .driver_data(lcd_write_data), .driver_ready(lcd_ready)
    );
    lcd_driver #(.CLK_HZ(CLK_HZ)) lcd_bus (
        .clk(clk_24mhz), .reset(reset), .write_en(lcd_write), .write_rs(lcd_write_rs),
        .write_data(lcd_write_data), .ready(lcd_ready), .lcd_rs(lcd_rs), .lcd_rw(lcd_rw),
        .lcd_en(lcd_en), .lcd_d(lcd_d)
    );
    keypad_scan #(.CLK_HZ(CLK_HZ)) keypad (
        .clk(clk_24mhz), .reset(reset), .row_n(keypad_row_n), .col_n(keypad_col_n),
        .key_valid(keypad_valid), .key_code(keypad_code)
    );
    keypad_decoder key_decode (
        .clk(clk_24mhz), .reset(reset), .key_valid(keypad_valid), .key_code(keypad_code),
        .ascii_valid(core_key_valid), .ascii(core_key_ascii)
    );
    led_controller #(.CLK_HZ(CLK_HZ)) leds (
        .clk(clk_24mhz), .reset(reset), .status(core_led_status), .alarm(core_alarm), .led(led)
    );
    buzzer_controller #(.CLK_HZ(CLK_HZ)) sounder (
        .clk(clk_24mhz), .reset(reset), .alarm(core_alarm), .enable(core_buzzer_enable), .buzzer(buzzer)
    );
    sevenseg_driver #(.CLK_HZ(CLK_HZ)) sevenseg (
        .clk(clk_24mhz), .reset(reset), .value(core_sevenseg_value), .display_enable(core_sevenseg_enable),
        .seg_din(seg_din), .seg_clk(seg_clk), .seg_load(seg_load)
    );

    relay_driver relay (
        .clk(clk_24mhz), .reset(reset), .authorized(core_actuator_authorized),
        .relay_set(core_relay_set), .relay_reset(core_relay_reset), .relay_in(relay_in), .denied(relay_denied)
    );

    assign core_stepper_busy = 1'b0;
    assign core_stepper_done = 1'b0;
    assign core_actuator_denied = relay_denied;
    assign core_transport_error = pmod_cmd_error | esp_message_error;
    assign core_transport_error_source_id = pmod_cmd_error ? 8'h01 : 8'h02;

    audit_log_writer audit (
        .clk(clk_24mhz), .reset(reset), .audit_request(core_audit_request), .audit_ready(core_audit_ready),
        .event_digest(core_audit_digest), .event_metadata(core_audit_metadata),
        .record_valid(audit_record_valid), .record_ready(audit_record_ready),
        .record_data(audit_record), .chain_head(core_audit_chain_head)
    );
    assign audit_record_ready = logger_log_ready && sd_init_done;
    sd_logger logger (
        .clk(clk_24mhz), .reset(reset), .log_valid(audit_record_valid), .log_ready(logger_log_ready),
        .log_record(audit_record), .logger_busy(logger_busy), .log_done(logger_done), .log_failed(logger_failed),
        .writer_start(writer_start), .writer_sector(writer_sector), .writer_record(writer_record),
        .writer_length(writer_length), .writer_busy(writer_busy), .writer_done(writer_done), .writer_failed(writer_failed)
    );
    sd_sector_writer sector_writer (
        .clk(clk_24mhz), .reset(reset), .write_start(writer_start), .sector_address(writer_sector),
        .record_data(writer_record), .record_length(writer_length), .busy(writer_busy), .done(writer_done),
        .failed(writer_failed), .xfer_start(sd_xfer_start), .xfer_data(sd_xfer_data),
        .xfer_hold_cs(sd_xfer_hold_cs), .xfer_rx(sd_xfer_rx), .xfer_busy(sd_xfer_busy), .xfer_done(sd_xfer_done)
    );
    sd_card_init sd_init (
        .clk(clk_24mhz), .reset(reset), .init_busy(sd_init_busy), .init_done(sd_init_done),
        .init_failed(sd_init_failed), .xfer_start(sd_init_xfer_start), .xfer_data(sd_init_xfer_data),
        .xfer_hold_cs(sd_init_xfer_hold_cs), .xfer_force_cs_high(sd_init_force_cs_high),
        .xfer_rx(sd_xfer_rx), .xfer_busy(sd_xfer_busy), .xfer_done(sd_xfer_done)
    );
    assign sd_bus_xfer_start = sd_init_busy ? sd_init_xfer_start : sd_xfer_start;
    assign sd_bus_xfer_data = sd_init_busy ? sd_init_xfer_data : sd_xfer_data;
    assign sd_bus_xfer_hold_cs = sd_init_busy ? sd_init_xfer_hold_cs : sd_xfer_hold_cs;
    assign sd_bus_force_cs_high = sd_init_busy ? sd_init_force_cs_high : 1'b0;
    spi_sd_master sd_spi (
        .clk(clk_24mhz), .reset(reset), .xfer_start(sd_bus_xfer_start), .xfer_data(sd_bus_xfer_data),
        .hold_cs(sd_bus_xfer_hold_cs), .force_cs_high(sd_bus_force_cs_high),
        .xfer_rx(sd_xfer_rx), .xfer_busy(sd_xfer_busy), .xfer_done(sd_xfer_done),
        .sd_clk(sd_clk), .sd_cmd(sd_cmd), .sd_d0(sd_d0), .sd_cs_n(sd_cs_n)
    );
    assign core_sd_card_missing = SD_DETECT_ACTIVE_LOW ? sd_detect_n : !sd_detect_n;
    assign core_sd_write_done = logger_done;
    assign core_sd_write_error = (logger_failed | sd_init_failed) && !core_sd_card_missing;
    assign core_audit_storage_failed = core_sd_write_error | core_sd_card_missing;
endmodule
