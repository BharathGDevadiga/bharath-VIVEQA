`timescale 1ns/1ps

module tb_sentinel_rv_top;
    localparam integer UART_BIT_NS = 8681;

    reg clk_24mhz;
    reg reset;
    reg pmod_uart_rx;
    reg esp_uart_rx;
    reg adc_miso;
    reg sd_d0;
    reg sd_detect_n;
    reg [3:0] keypad_col_n;
    reg security_clear_alarm;
    reg security_xadc_sample_valid;
    reg [11:0] security_xadc_vccint_code;
    reg [11:0] security_xadc_temperature_code;
    reg security_tx_start;
    reg [127:0] security_tx_plaintext;
    reg [127:0] security_tx_key;
    reg [63:0] security_tx_nonce;
    reg [7:0] security_tx_sequence;
    reg security_audit_request;
    reg [127:0] security_audit_digest;

    wire pmod_uart_tx;
    wire esp_uart_tx;
    wire adc_sck;
    wire adc_mosi;
    wire adc_cs_n;
    wire sd_clk;
    wire sd_cmd;
    wire sd_cs_n;
    wire lcd_rs;
    wire lcd_rw;
    wire lcd_en;
    wire [7:0] lcd_d;
    wire [3:0] keypad_row_n;
    wire [15:0] led;
    wire buzzer;
    wire seg_din;
    wire seg_clk;
    wire seg_load;
    wire relay_in;
    wire motor_in1;
    wire motor_in2;
    wire [3:0] stepper;
    wire security_command_accepted;
    wire security_command_rejected;
    wire security_alarm;
    wire security_aes_reset;
    wire [239:0] security_tx_packet;
    wire security_tx_packet_valid;
    wire security_tx_busy;
    wire security_cpu_trap;
    wire security_audit_ready;
    wire [127:0] security_audit_chain_head;
    wire security_audit_storage_failed;
    wire security_key_valid;
    wire [7:0] security_key_ascii;

    reg accepted_seen;
    reg rejected_seen;
    integer bit_index;

    always #20.833 clk_24mhz = ~clk_24mhz;

    always @(posedge clk_24mhz) begin
        if (security_command_accepted)
            accepted_seen <= 1'b1;
        if (security_command_rejected)
            rejected_seen <= 1'b1;
    end

    task send_uart_byte;
        input [7:0] value;
        begin
            pmod_uart_rx = 1'b0;
            #(UART_BIT_NS);
            for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
                pmod_uart_rx = value[bit_index];
                #(UART_BIT_NS);
            end
            pmod_uart_rx = 1'b1;
            #(UART_BIT_NS);
        end
    endtask

    task send_command;
        input [7:0] opcode;
        input [7:0] sequence;
        input [15:0] argument;
        reg [7:0] checksum;
        begin
            checksum = 8'hA5 ^ opcode ^ sequence ^ argument[15:8] ^ argument[7:0];
            send_uart_byte(8'hA5);
            send_uart_byte(opcode);
            send_uart_byte(sequence);
            send_uart_byte(argument[15:8]);
            send_uart_byte(argument[7:0]);
            send_uart_byte(checksum);
        end
    endtask

    sentinel_rv_top dut (
        .clk_24mhz(clk_24mhz), .reset(reset),
        .pmod_uart_rx(pmod_uart_rx), .pmod_uart_tx(pmod_uart_tx),
        .esp_uart_rx(esp_uart_rx), .esp_uart_tx(esp_uart_tx),
        .adc_sck(adc_sck), .adc_mosi(adc_mosi), .adc_miso(adc_miso), .adc_cs_n(adc_cs_n),
        .sd_clk(sd_clk), .sd_cmd(sd_cmd), .sd_d0(sd_d0), .sd_cs_n(sd_cs_n), .sd_detect_n(sd_detect_n),
        .lcd_rs(lcd_rs), .lcd_rw(lcd_rw), .lcd_en(lcd_en), .lcd_d(lcd_d),
        .keypad_row_n(keypad_row_n), .keypad_col_n(keypad_col_n),
        .led(led), .buzzer(buzzer), .seg_din(seg_din), .seg_clk(seg_clk), .seg_load(seg_load),
        .relay_in(relay_in), .motor_in1(motor_in1), .motor_in2(motor_in2), .stepper(stepper),
        .security_clear_alarm(security_clear_alarm),
        .security_xadc_sample_valid(security_xadc_sample_valid),
        .security_xadc_vccint_code(security_xadc_vccint_code),
        .security_xadc_temperature_code(security_xadc_temperature_code),
        .security_command_accepted(security_command_accepted),
        .security_command_rejected(security_command_rejected),
        .security_alarm(security_alarm), .security_aes_reset(security_aes_reset),
        .security_tx_start(security_tx_start), .security_tx_plaintext(security_tx_plaintext),
        .security_tx_key(security_tx_key), .security_tx_nonce(security_tx_nonce),
        .security_tx_sequence(security_tx_sequence), .security_tx_packet(security_tx_packet),
        .security_tx_packet_valid(security_tx_packet_valid), .security_tx_busy(security_tx_busy),
        .security_cpu_trap(security_cpu_trap),
        .security_audit_request(security_audit_request), .security_audit_digest(security_audit_digest),
        .security_audit_ready(security_audit_ready), .security_audit_chain_head(security_audit_chain_head),
        .security_audit_storage_failed(security_audit_storage_failed),
        .security_key_valid(security_key_valid), .security_key_ascii(security_key_ascii)
    );

    initial begin
        clk_24mhz = 1'b0;
        reset = 1'b1;
        pmod_uart_rx = 1'b1;
        esp_uart_rx = 1'b1;
        adc_miso = 1'b0;
        sd_d0 = 1'b1;
        sd_detect_n = 1'b1;
        keypad_col_n = 4'b1111;
        security_clear_alarm = 1'b0;
        security_xadc_sample_valid = 1'b0;
        security_xadc_vccint_code = 12'h550;
        security_xadc_temperature_code = 12'h500;
        security_tx_start = 1'b0;
        security_tx_plaintext = 128'd0;
        security_tx_key = 128'd0;
        security_tx_nonce = 64'd0;
        security_tx_sequence = 8'd0;
        security_audit_request = 1'b0;
        security_audit_digest = 128'd0;
        accepted_seen = 1'b0;
        rejected_seen = 1'b0;

        repeat (12) @(posedge clk_24mhz);
        reset = 1'b0;
        repeat (20) @(posedge clk_24mhz);

        send_command(8'h01, 8'h01, 16'h0001);
        repeat (5000) @(posedge clk_24mhz);

        if (!accepted_seen)
            $display("FAIL: sentinel_rv_top command was not accepted");
        else if (!relay_in)
            $display("FAIL: sentinel_rv_top relay was not authorized");
        else if (rejected_seen)
            $display("FAIL: sentinel_rv_top rejected the valid command");
        else if (security_alarm || security_aes_reset)
            $display("FAIL: sentinel_rv_top raised an alarm for a valid command");
        else if (security_cpu_trap)
            $display("FAIL: sentinel_rv_top CPU trap asserted");
        else
            $display("PASS: sentinel_rv_top reset, UART command, security, and relay path");
        $finish;
    end
endmodule
