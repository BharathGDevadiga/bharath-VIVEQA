`timescale 1ns/1ps

// Combined Security + Peripheral board wrapper.
// Peripheral module validates transport framing; Security core makes authorization decisions.
module sentinel_rv_top #(
    parameter [127:0] AUDIT_KEY = 128'd0,
    parameter integer SD_DETECT_ACTIVE_LOW = 1
) (
    input wire clk_24mhz, input wire reset,
    input wire pmod_uart_rx, output wire pmod_uart_tx,
    input wire esp_uart_rx, output wire esp_uart_tx,
    output wire adc_sck, output wire adc_mosi, input wire adc_miso, output wire adc_cs_n,
    output wire sd_clk, output wire sd_cmd, input wire sd_d0, output wire sd_cs_n, input wire sd_detect_n,
    output wire lcd_rs, output wire lcd_rw, output wire lcd_en, output wire [7:0] lcd_d,
    output wire [3:0] keypad_row_n, input wire [3:0] keypad_col_n, output wire [15:0] led,
    output wire buzzer, output wire seg_din, output wire seg_clk, output wire seg_load,
    output wire relay_in,
    inout wire dht11_data, input wire hc_sr04_echo, output wire hc_sr04_trigger,

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
    output wire security_sd_write_done,
    output wire security_sd_write_error,
    output wire security_sd_card_missing,
    output wire security_key_valid,
    output wire [7:0] security_key_ascii
);
    wire [11:0] core_adc_sample;
    wire core_adc_sample_valid;
    wire [7:0] core_dht11_temp;
    wire [7:0] core_dht11_hum;
    wire [15:0] core_distance;
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
    wire command_gate_ready;
    wire security_packet_valid;
    wire [63:0] security_nonce;
    wire security_core_command_accepted;
    wire security_core_command_rejected;
    wire command_result_valid;
    wire command_result_accepted;
    wire [7:0] command_result_opcode;
    wire [15:0] command_result_argument;
    wire [7:0] command_result_sequence;
    wire [7:0] command_result_source_id;
    wire cpu_command_ready;
    wire cpu_command_valid;
    wire [7:0] cpu_command_opcode;
    wire [7:0] cpu_command_sequence;
    wire [15:0] cpu_command_argument;
    wire cpu_alive;
    wire selected_command_valid;
    wire [7:0] selected_command_opcode;
    wire [7:0] selected_command_sequence;
    wire [15:0] selected_command_argument;
    wire [7:0] selected_command_source_id;
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
    wire core_transport_error;
    wire [7:0] core_transport_error_source_id;
    wire core_audit_request;
    wire core_audit_ready;
    wire [127:0] core_audit_digest;
    wire [127:0] core_audit_metadata;
    wire [127:0] core_audit_chain_head;
    wire core_audit_storage_failed;
    wire core_sd_write_done;
    wire core_sd_write_error;
    wire core_sd_card_missing;
    wire generated_audit_request;
    wire [127:0] generated_audit_digest;
    wire [127:0] generated_audit_metadata;
    wire command_accepted_event;
    wire command_rejected_event;

    assign selected_command_valid = cpu_command_valid | core_command_valid;
    assign selected_command_opcode = cpu_command_valid ? cpu_command_opcode : core_command_opcode;
    assign selected_command_sequence = cpu_command_valid ? cpu_command_sequence : core_command_sequence;
    assign selected_command_argument = cpu_command_valid ? cpu_command_argument : core_command_argument;
    assign selected_command_source_id = cpu_command_valid ? 8'h03 :
                                        (core_command_source ? 8'h02 : 8'h01);
    assign core_command_ready = command_gate_ready && !cpu_command_valid;
    assign cpu_command_ready = command_gate_ready && cpu_command_valid;
    assign command_accepted_event = command_result_valid && command_result_accepted;
    assign command_rejected_event = command_result_valid && !command_result_accepted;
    assign security_command_accepted = command_accepted_event;
    assign security_command_rejected = command_rejected_event;

    reg [24:0] sevenseg_timer;
    reg sevenseg_mode;  // 0 = temperature, 1 = distance

    reg disp_freeze;
    reg [2:0] disp_mode_select; // 0=Auto, 1=Temp, 2=Dist, 3=Volt, 4=Hum
    reg [127:0] keypad_lcd_line2;
    reg keypad_lcd_override;

    always @(posedge clk_24mhz) begin
        if (reset) begin
            sevenseg_timer <= 25'd0;
            sevenseg_mode  <= 1'b0;
            disp_freeze    <= 1'b0;
            disp_mode_select <= 3'd0;
            keypad_lcd_override <= 1'b0;
            keypad_lcd_line2 <= "STATUS: READY   ";
        end else begin
            if (core_key_valid) begin
                case (core_key_ascii)
                    8'h31: begin // Key 1: Toggle 7-Seg mode
                        sevenseg_mode <= ~sevenseg_mode;
                    end
                    8'h34: begin // Key 4: Toggle Temp/Dist mode
                        disp_mode_select <= (disp_mode_select == 3'd1) ? 3'd2 : 3'd1;
                    end
                    8'h36: begin // Key 6: ADC Voltage Mode
                        disp_mode_select <= 3'd3;
                    end
                    8'h37: begin // Key 7: Humidity Mode
                        disp_mode_select <= 3'd4;
                    end
                    8'h41: begin // Key A: Reset Peak Memory
                        keypad_lcd_line2 <= "MEM PEAK RESET  ";
                        keypad_lcd_override <= 1'b1;
                    end
                    8'h42: begin // Key B: Display Freeze / Pause
                        disp_freeze <= ~disp_freeze;
                        keypad_lcd_line2 <= disp_freeze ? "DISP: RESUMED   " : "DISP: FROZEN    ";
                        keypad_lcd_override <= 1'b1;
                    end
                    8'h43: begin // Key C: Clear Sensor Errors
                        keypad_lcd_line2 <= "ERRORS CLEARED  ";
                        keypad_lcd_override <= 1'b1;
                    end
                    8'h46: begin // Key F: Master System Reset
                        disp_freeze <= 1'b0;
                        disp_mode_select <= 3'd0;
                        keypad_lcd_override <= 1'b0;
                    end
                    default: begin
                        // Key 0, 2, 3, 5, 8, 9, D, E
                    end
                endcase
            end else if (!disp_freeze) begin
                if (sevenseg_timer == 25'd23_999_999 * 3) begin  // 3 second cycle
                    sevenseg_timer <= 25'd0;
                    if (disp_mode_select == 3'd0)
                        sevenseg_mode  <= ~sevenseg_mode;
                end else begin
                    sevenseg_timer <= sevenseg_timer + 1'b1;
                end
            end
        end
    end

    assign core_lcd_line1 = security_alarm ? "SECURITY ALARM  " : "SECURE SOC v1.0 ";
    assign core_lcd_line2 = keypad_lcd_override ? keypad_lcd_line2 :
                            command_accepted_event ? "CMD ACCEPTED    " :
                            command_rejected_event ? "CMD REJECTED    " : "STATUS: READY   ";
    assign core_led_status = {11'd0, cpu_alive, security_alarm, command_rejected_event,
                              command_accepted_event, !command_gate_ready};

    // --- 4-sample moving average filter for HC-SR04 distance ---
    reg [15:0] dist_buf0, dist_buf1, dist_buf2, dist_buf3;
    reg [1:0]  dist_idx;
    wire [15:0] dist_avg = (dist_buf0 + dist_buf1 + dist_buf2 + dist_buf3) >> 2;
    wire [15:0] filtered_distance = dist_avg;

    reg [15:0] last_raw_dist;
    always @(posedge clk_24mhz) begin
        if (reset) begin
            dist_buf0 <= 16'd0; dist_buf1 <= 16'd0;
            dist_buf2 <= 16'd0; dist_buf3 <= 16'd0;
            dist_idx  <= 2'd0;
            last_raw_dist <= 16'd0;
        end else begin
            // Sample new distance reading whenever sensor value updates (rejecting errors)
            if (core_distance != last_raw_dist && core_distance != 16'hFFFF && core_distance != 16'd0) begin
                last_raw_dist <= core_distance;
                case (dist_idx)
                    2'd0: dist_buf0 <= core_distance;
                    2'd1: dist_buf1 <= core_distance;
                    2'd2: dist_buf2 <= core_distance;
                    2'd3: dist_buf3 <= core_distance;
                endcase
                dist_idx <= dist_idx + 1'b1;
            end
        end
    end

    // --- BCD conversion for temperature (2-digit: e.g. 28) ---
    wire [3:0] temp_tens = (core_dht11_temp >= 8'd90) ? 4'd9 : (core_dht11_temp >= 8'd80) ? 4'd8 : (core_dht11_temp >= 8'd70) ? 4'd7 : (core_dht11_temp >= 8'd60) ? 4'd6 : (core_dht11_temp >= 8'd50) ? 4'd5 : (core_dht11_temp >= 8'd40) ? 4'd4 : (core_dht11_temp >= 8'd30) ? 4'd3 : (core_dht11_temp >= 8'd20) ? 4'd2 : (core_dht11_temp >= 8'd10) ? 4'd1 : 4'd0;
    wire [3:0] temp_ones = (core_dht11_temp >= temp_tens * 10) ? (core_dht11_temp - (temp_tens * 10)) : 4'd0;

    // --- BCD conversion for filtered distance (3-digit: e.g. 045) ---
    wire [15:0] safe_dist = (filtered_distance > 16'd999) ? 16'd999 : filtered_distance;
    wire [3:0] dist_hundreds = (safe_dist >= 16'd900) ? 4'd9 : (safe_dist >= 16'd800) ? 4'd8 : (safe_dist >= 16'd700) ? 4'd7 : (safe_dist >= 16'd600) ? 4'd6 : (safe_dist >= 16'd500) ? 4'd5 : (safe_dist >= 16'd400) ? 4'd4 : (safe_dist >= 16'd300) ? 4'd3 : (safe_dist >= 16'd200) ? 4'd2 : (safe_dist >= 16'd100) ? 4'd1 : 4'd0;
    wire [15:0] dist_rem100 = safe_dist - (dist_hundreds * 100);
    wire [3:0] dist_tens = (dist_rem100 >= 16'd90) ? 4'd9 : (dist_rem100 >= 16'd80) ? 4'd8 : (dist_rem100 >= 16'd70) ? 4'd7 : (dist_rem100 >= 16'd60) ? 4'd6 : (dist_rem100 >= 16'd50) ? 4'd5 : (dist_rem100 >= 16'd40) ? 4'd4 : (dist_rem100 >= 16'd30) ? 4'd3 : (dist_rem100 >= 16'd20) ? 4'd2 : (dist_rem100 >= 16'd10) ? 4'd1 : 4'd0;
    wire [3:0] dist_ones = (dist_rem100 >= dist_tens * 10) ? (dist_rem100 - (dist_tens * 10)) : 4'd0;

    // 7-Segment Display:
    //   Mode 0 → "t. 28" = Temperature mode (Digit 4 shows "t.", Digit 3 blank, Digits 2-1 show temp)
    //   Mode 1 → "d. 34" = Distance mode    (Digit 4 shows "d.", Digit 3 hundreds or blank, Digits 2-1 show dist)
    wire [3:0] dist_hundreds_disp = (dist_hundreds == 4'd0) ? 4'hF : dist_hundreds;
    assign core_sevenseg_value = sevenseg_mode ?
        {8'hBD, dist_tens[3:0], dist_ones[3:0]} :
        {8'h8F, temp_tens[3:0], temp_ones[3:0]};
    assign core_actuator_authorized = command_accepted_event;
    assign core_relay_set = command_accepted_event && command_result_opcode == 8'h01;
    assign core_relay_reset = command_accepted_event && command_result_opcode == 8'h02;
    assign core_motor_enable = 1'b0;
    assign core_motor_command = 2'b00;
    assign core_motor_speed = 8'd0;
    assign core_stepper_start = 1'b0;
    assign core_stepper_direction = 1'b0;
    assign core_stepper_count = 16'd0;
    assign core_telemetry_valid = core_adc_sample_valid | command_accepted_event | command_rejected_event;
    assign core_telemetry_sequence = command_result_valid ? command_result_sequence : 8'd0;
    assign core_telemetry_event = security_alarm ? 8'hEE :
                                  command_accepted_event ? 8'h10 :
                                  command_rejected_event ? 8'h02 : 8'h01;
    assign core_telemetry_sensor = core_adc_sample;
    assign core_telemetry_status = {5'd0, security_alarm, security_aes_reset, !command_gate_ready};

    assign security_key_valid = core_key_valid;
    assign security_key_ascii = core_key_ascii;
    assign security_audit_ready = core_audit_ready;
    assign security_audit_chain_head = core_audit_chain_head;
    assign security_audit_storage_failed = core_audit_storage_failed;
    assign security_sd_write_done = core_sd_write_done;
    assign security_sd_write_error = core_sd_write_error;
    assign security_sd_card_missing = core_sd_card_missing;

    assign core_adc_channel = 1'b0;
    assign core_adc_force_sample = 1'b0;
    assign core_lcd_refresh = core_telemetry_valid | command_accepted_event | command_rejected_event;
    assign core_alarm = security_alarm;
    assign core_buzzer_enable = 1'b1;
    assign core_sevenseg_enable = 1'b1;
    assign core_stepper_period = 24'd100_000;
    assign core_audit_request = security_audit_request | generated_audit_request;
    assign core_audit_digest = security_audit_request ? security_audit_digest : generated_audit_digest;
    assign core_audit_metadata = generated_audit_request ? generated_audit_metadata : 128'd0;

    security_telemetry audit_events (
        .clk(clk_24mhz), .reset(reset),
        .adc_sample(core_adc_sample), .adc_sample_valid(core_adc_sample_valid),
        .dht11_temp(core_dht11_temp), .dht11_hum(core_dht11_hum), .distance(core_distance),
        .command_busy(!command_gate_ready),
        .result_valid(command_result_valid | core_transport_error),
        .result_accepted(command_result_accepted),
        .transport_error(core_transport_error),
        .result_opcode(core_transport_error ? 8'hFE : command_result_opcode),
        .result_sequence(core_transport_error ? 8'h00 : command_result_sequence),
        .result_argument(command_result_argument),
        .result_source_id(core_transport_error ? core_transport_error_source_id :
                          command_result_source_id),
        .alarm(security_alarm), .session_key(AUDIT_KEY),
        .previous_digest(core_audit_chain_head),
        .telemetry_valid(), .telemetry_ready(1'b1),
        .telemetry_sequence(), .telemetry_event(), .telemetry_sensor(), .telemetry_status(),
        .lcd_refresh(), .lcd_line1(), .lcd_line2(), .led_status(), .buzzer_enable(),
        .sevenseg_value(), .sevenseg_enable(),
        .audit_request(generated_audit_request), .audit_ready(core_audit_ready),
        .audit_digest(generated_audit_digest), .audit_metadata(generated_audit_metadata)
    );

    security_command_bridge command_gate (
        .clk(clk_24mhz), .reset(reset),
        .transport_cmd_valid(selected_command_valid), .transport_cmd_ready(command_gate_ready),
        .transport_cmd_opcode(selected_command_opcode), .transport_cmd_sequence(selected_command_sequence),
        .transport_cmd_argument(selected_command_argument), .transport_cmd_source_id(selected_command_source_id),
        .security_packet_valid(security_packet_valid), .security_nonce(security_nonce),
        .security_accepted(security_core_command_accepted), .security_rejected(security_core_command_rejected),
        .result_valid(command_result_valid), .result_accepted(command_result_accepted),
        .result_opcode(command_result_opcode), .result_argument(command_result_argument),
        .result_sequence(command_result_sequence), .result_source_id(command_result_source_id)
    );

    peripheral_top #(.SD_DETECT_ACTIVE_LOW(SD_DETECT_ACTIVE_LOW)) peripherals (
        .clk_24mhz(clk_24mhz), .reset(reset),
        .pmod_uart_rx(pmod_uart_rx), .pmod_uart_tx(pmod_uart_tx),
        .esp_uart_rx(esp_uart_rx), .esp_uart_tx(esp_uart_tx),
        .adc_sck(adc_sck), .adc_mosi(adc_mosi), .adc_miso(adc_miso), .adc_cs_n(adc_cs_n),
        .sd_clk(sd_clk), .sd_cmd(sd_cmd), .sd_d0(sd_d0), .sd_cs_n(sd_cs_n), .sd_detect_n(sd_detect_n),
        .lcd_rs(lcd_rs), .lcd_rw(lcd_rw), .lcd_en(lcd_en), .lcd_d(lcd_d),
        .keypad_row_n(keypad_row_n), .keypad_col_n(keypad_col_n),
        .led(led), .buzzer(buzzer), .seg_din(seg_din), .seg_clk(seg_clk), .seg_load(seg_load),
        .relay_in(relay_in),
        .dht11_data(dht11_data), .hc_sr04_echo(hc_sr04_echo), .hc_sr04_trigger(hc_sr04_trigger),
        .core_adc_sample(core_adc_sample), .core_adc_sample_valid(core_adc_sample_valid),
        .core_dht11_temp(core_dht11_temp), .core_dht11_hum(core_dht11_hum), .core_distance(core_distance),
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
        .core_transport_error(core_transport_error),
        .core_transport_error_source_id(core_transport_error_source_id),
        .core_audit_request(core_audit_request), .core_audit_ready(core_audit_ready),
        .core_audit_digest(core_audit_digest), .core_audit_metadata(core_audit_metadata),
        .core_audit_chain_head(core_audit_chain_head),
        .core_audit_storage_failed(core_audit_storage_failed),
        .core_sd_write_done(core_sd_write_done),
        .core_sd_write_error(core_sd_write_error),
        .core_sd_card_missing(core_sd_card_missing)
    );

    sentinel_rv_security security_core (
        .clk(clk_24mhz), .reset(reset),
        .rx_packet_valid(security_packet_valid), .rx_nonce(security_nonce),
        .rx_crc_ok(1'b1),
        .clear_alarm(security_clear_alarm),
        .xadc_sample_valid(security_xadc_sample_valid),
        .xadc_vccint_code(security_xadc_vccint_code),
        .xadc_temperature_code(security_xadc_temperature_code),
        .command_accepted(security_core_command_accepted),
        .command_rejected(security_core_command_rejected),
        .alarm(security_alarm), .aes_reset(security_aes_reset),
        .tx_start(security_tx_start), .tx_plaintext(security_tx_plaintext),
        .tx_key(security_tx_key), .tx_nonce(security_tx_nonce),
        .tx_sequence(security_tx_sequence), .tx_packet(security_tx_packet),
        .tx_packet_valid(security_tx_packet_valid), .tx_busy(security_tx_busy),
        .cpu_trap(security_cpu_trap),
        .cpu_command_ready(cpu_command_ready), .cpu_command_valid(cpu_command_valid),
        .cpu_command_opcode(cpu_command_opcode), .cpu_command_sequence(cpu_command_sequence),
        .cpu_command_argument(cpu_command_argument), .cpu_alive(cpu_alive)
    );
endmodule
