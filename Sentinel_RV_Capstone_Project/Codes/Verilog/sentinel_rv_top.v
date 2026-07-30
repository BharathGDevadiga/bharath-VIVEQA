`timescale 1ns/1ps

// Combined Team 1 + Team 2 board wrapper.
// Team 2 validates transport framing; Team 1 makes the security decision.
module sentinel_rv_top #(
    parameter [127:0] AUDIT_KEY = 128'h0123456789ABCDEF0123456789ABCDEF,
    parameter SD_DETECT_ACTIVE_LOW = 1
) (
    input wire clk_24mhz, input wire reset,
    input wire pmod_uart_rx, output wire pmod_uart_tx,
    input wire esp_uart_rx, output wire esp_uart_tx,
    output wire adc_sck, output wire adc_mosi, input wire adc_miso, output wire adc_cs_n,
    output wire sd_clk, output wire sd_cmd, input wire sd_d0, output wire sd_cs_n, input wire sd_detect_n,
    output wire lcd_rs, output wire lcd_rw, output wire lcd_en, output wire [7:0] lcd_d,
    output wire [3:0] keypad_row_n, input wire [3:0] keypad_col_n, output wire [15:0] led,
    output wire buzzer, output wire seg_din, output wire seg_clk, output wire seg_load,
    output wire relay_in, output wire motor_in1, output wire motor_in2, output wire [3:0] stepper,

    input wire security_clear_alarm,
    input wire security_xadc_sample_valid,
    input wire [11:0] security_xadc_vccint_code,
    input wire [11:0] security_xadc_temperature_code,
    output wire security_command_accepted,
    output wire security_command_rejected,
    output wire security_alarm,
    output wire security_aes_reset,
    input wire security_tx_start,
    input wire [127:0] security_tx_plaintext,
    input wire [127:0] security_tx_key,
    input wire [63:0] security_tx_nonce,
    input wire [7:0] security_tx_sequence,
    output wire [239:0] security_tx_packet,
    output wire security_tx_packet_valid,
    output wire security_tx_busy,
    output wire security_cpu_trap,
    input wire security_audit_request,
    input wire [127:0] security_audit_digest,
    output wire security_audit_ready,
    output wire [127:0] security_audit_chain_head,
    output wire security_audit_storage_failed,
    output wire security_key_valid,
    output wire [7:0] security_key_ascii
);
    wire [11:0] core_adc_sample;
    wire core_adc_sample_valid;
    wire core_adc_channel;
    wire core_adc_force_sample;
    wire core_key_valid;
    wire [7:0] core_key_ascii;
    wire core_command_valid;
    wire core_command_ready;
    wire [7:0] core_command_opcode;
    wire [7:0] core_command_sequence;
    wire [15:0] core_command_argument;
    wire core_command_source;
    wire core_telemetry_valid;
    wire core_telemetry_ready;
    wire [7:0] core_telemetry_sequence;
    wire [7:0] core_telemetry_event;
    wire [11:0] core_telemetry_sensor;
    wire [7:0] core_telemetry_status;
    wire core_lcd_refresh;
    wire [127:0] core_lcd_line1;
    wire [127:0] core_lcd_line2;
    wire [15:0] core_led_status;
    wire core_alarm;
    wire core_buzzer_enable;
    wire [15:0] core_sevenseg_value;
    wire core_sevenseg_enable;
    wire core_actuator_authorized;
    wire core_relay_set;
    wire core_relay_reset;
    wire core_motor_enable;
    wire [1:0] core_motor_command;
    wire [7:0] core_motor_speed;
    wire core_stepper_start;
    wire core_stepper_direction;
    wire [15:0] core_stepper_count;
    wire [23:0] core_stepper_period;
    wire core_actuator_denied;
    wire core_stepper_busy;
    wire core_stepper_done;
    wire core_audit_request;
    wire core_audit_ready;
    wire [127:0] core_audit_digest;
    wire [127:0] core_audit_chain_head;
    wire core_audit_storage_failed;
    reg [7:0] last_opcode;
    reg [15:0] last_argument;

    always @(posedge clk_24mhz) begin
        if (reset) begin
            last_opcode <= 8'd0;
            last_argument <= 16'd0;
        end else if (core_command_valid) begin
            last_opcode <= core_command_opcode;
            last_argument <= core_command_argument;
        end
    end

    assign core_lcd_line1 = security_alarm ? "SECURITY ALARM  " : "SENTINEL-RV OK  ";
    assign core_lcd_line2 = security_command_accepted ? "CMD ACCEPTED    " :
                            security_command_rejected ? "CMD REJECTED    " : "READY           ";
    assign core_led_status = {12'd0, security_alarm, security_command_rejected,
                              security_command_accepted, core_command_valid};
    assign core_sevenseg_value = last_argument;
    assign core_actuator_authorized = security_command_accepted;
    assign core_relay_set = security_command_accepted && last_opcode == 8'h01;
    assign core_relay_reset = security_command_accepted && last_opcode == 8'h02;
    assign core_motor_enable = security_command_accepted && last_opcode == 8'h03;
    assign core_motor_command = last_argument[1:0];
    assign core_motor_speed = last_argument[15:8];
    assign core_stepper_start = security_command_accepted && last_opcode == 8'h04;
    assign core_stepper_direction = last_argument[0];
    assign core_stepper_count = last_argument;
    assign core_telemetry_valid = core_adc_sample_valid | security_command_accepted | security_command_rejected;
    assign core_telemetry_sequence = core_command_sequence;
    assign core_telemetry_event = security_alarm ? 8'hEE :
                                  security_command_accepted ? 8'h01 :
                                  security_command_rejected ? 8'h02 : 8'h10;
    assign core_telemetry_sensor = core_adc_sample;
    assign core_telemetry_status = {5'd0, security_alarm, security_aes_reset, core_command_valid};

    assign security_key_valid = core_key_valid;
    assign security_key_ascii = core_key_ascii;
    assign security_audit_ready = core_audit_ready;
    assign security_audit_chain_head = core_audit_chain_head;
    assign security_audit_storage_failed = core_audit_storage_failed;

    assign core_adc_channel = 1'b0;
    assign core_adc_force_sample = 1'b0;
    assign core_command_ready = 1'b1;
    assign core_lcd_refresh = core_telemetry_valid | security_command_accepted | security_command_rejected;
    assign core_alarm = security_alarm;
    assign core_buzzer_enable = 1'b1;
    assign core_sevenseg_enable = 1'b1;
    assign core_stepper_period = 24'd100_000;
    assign core_audit_request = security_audit_request;
    assign core_audit_digest = security_audit_digest;

    team2_top peripherals (
        .clk_24mhz(clk_24mhz), .reset(reset),
        .pmod_uart_rx(pmod_uart_rx), .pmod_uart_tx(pmod_uart_tx),
        .esp_uart_rx(esp_uart_rx), .esp_uart_tx(esp_uart_tx),
        .adc_sck(adc_sck), .adc_mosi(adc_mosi), .adc_miso(adc_miso), .adc_cs_n(adc_cs_n),
        .sd_clk(sd_clk), .sd_cmd(sd_cmd), .sd_d0(sd_d0), .sd_cs_n(sd_cs_n), .sd_detect_n(sd_detect_n),
        .lcd_rs(lcd_rs), .lcd_rw(lcd_rw), .lcd_en(lcd_en), .lcd_d(lcd_d),
        .keypad_row_n(keypad_row_n), .keypad_col_n(keypad_col_n),
        .led(led), .buzzer(buzzer), .seg_din(seg_din), .seg_clk(seg_clk), .seg_load(seg_load),
        .relay_in(relay_in), .motor_in1(motor_in1), .motor_in2(motor_in2), .stepper(stepper),
        .core_adc_sample(core_adc_sample), .core_adc_sample_valid(core_adc_sample_valid),
        .core_adc_channel(core_adc_channel), .core_adc_force_sample(core_adc_force_sample),
        .core_key_valid(core_key_valid), .core_key_ascii(core_key_ascii),
        .core_command_valid(core_command_valid), .core_command_ready(core_command_ready),
        .core_command_opcode(core_command_opcode), .core_command_sequence(core_command_sequence),
        .core_command_argument(core_command_argument), .core_command_source(core_command_source),
        .core_telemetry_valid(core_telemetry_valid), .core_telemetry_ready(core_telemetry_ready),
        .core_telemetry_sequence(core_telemetry_sequence), .core_telemetry_event(core_telemetry_event),
        .core_telemetry_sensor(core_telemetry_sensor), .core_telemetry_status(core_telemetry_status),
        .core_lcd_refresh(core_lcd_refresh), .core_lcd_line1(core_lcd_line1), .core_lcd_line2(core_lcd_line2),
        .core_led_status(core_led_status), .core_alarm(core_alarm), .core_buzzer_enable(core_buzzer_enable),
        .core_sevenseg_value(core_sevenseg_value), .core_sevenseg_enable(core_sevenseg_enable),
        .core_actuator_authorized(core_actuator_authorized), .core_relay_set(core_relay_set),
        .core_relay_reset(core_relay_reset), .core_motor_enable(core_motor_enable),
        .core_motor_command(core_motor_command), .core_motor_speed(core_motor_speed),
        .core_stepper_start(core_stepper_start), .core_stepper_direction(core_stepper_direction),
        .core_stepper_count(core_stepper_count), .core_stepper_period(core_stepper_period),
        .core_actuator_denied(core_actuator_denied), .core_stepper_busy(core_stepper_busy),
        .core_stepper_done(core_stepper_done),
        .core_audit_request(core_audit_request), .core_audit_ready(core_audit_ready),
        .core_audit_digest(core_audit_digest), .core_audit_chain_head(core_audit_chain_head),
        .core_audit_storage_failed(core_audit_storage_failed)
    );

    sentinel_rv_security security_core (
        .clk(clk_24mhz), .reset(reset),
        .rx_packet_valid(core_command_valid),
        .rx_nonce({40'd0, core_command_sequence, core_command_argument}),
        .rx_crc_ok(1'b1),
        .clear_alarm(security_clear_alarm),
        .xadc_sample_valid(security_xadc_sample_valid),
        .xadc_vccint_code(security_xadc_vccint_code),
        .xadc_temperature_code(security_xadc_temperature_code),
        .command_accepted(security_command_accepted),
        .command_rejected(security_command_rejected),
        .alarm(security_alarm), .aes_reset(security_aes_reset),
        .tx_start(security_tx_start), .tx_plaintext(security_tx_plaintext),
        .tx_key(security_tx_key), .tx_nonce(security_tx_nonce),
        .tx_sequence(security_tx_sequence), .tx_packet(security_tx_packet),
        .tx_packet_valid(security_tx_packet_valid), .tx_busy(security_tx_busy),
        .cpu_trap(security_cpu_trap)
    );
endmodule
