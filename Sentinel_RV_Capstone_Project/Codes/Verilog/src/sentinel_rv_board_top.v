`timescale 1ns/1ps

module sentinel_rv_board_top #(
    parameter [127:0] AUDIT_KEY = 128'h000102030405060708090A0B0C0D0E0F,
    parameter integer SD_DETECT_ACTIVE_LOW = 1
) (
    input wire clk_24mhz,
    input wire reset_pin,          // S1 (C9) - Move DOWN for reset, UP to run
    input wire clear_alarm,        // S2 (B9) - Alarm Clear / Silence Buzzer
    input wire sw_alarm_test,      // S4 (A7) - Manual Alarm Test
    input wire sw_relay_force,     // S5 (C7) - Manual Relay Force ON
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
    output wire [7:0] led,         // L1 to L8 LEDs
    output wire buzzer,
    output wire relay_in,
    inout wire dht11_data
);
    wire reset = ~reset_pin;
    wire [15:0] led_internal;
    wire sd_storage_failed;
    wire sd_write_done;
    wire sd_write_error;
    wire sd_card_missing;
    reg sd_write_done_latched;
    reg sd_write_error_latched;


    // ---------------------------------------------------------------
    // Real XADC primitive wires - reads actual on-chip voltage & temp
    // ---------------------------------------------------------------
    wire        xadc_eoc;          // End-of-conversion strobe (1 cycle pulse)
    wire [15:0] xadc_do;           // XADC data output bus (16-bit, top 12 are data)
    wire [6:0]  xadc_daddr;        // XADC address register to read (7-bit)
    wire        xadc_den;          // XADC dynamic read enable
    wire        xadc_drdy;         // XADC data ready
    reg  [11:0] xadc_vccint_reg;   // Latched VCCINT reading (12-bit)
    reg  [11:0] xadc_temp_reg;     // Latched temperature reading (12-bit)
    reg         xadc_read_phase;   // 0 = reading VCCINT, 1 = reading Temp
    reg         xadc_sample_valid_r;

    // Xilinx XADC primitive - reads VCCINT (ch1) and Temperature (ch0)
    // eoc fires every conversion; we read alternate channels each cycle.
    XADC #(
        .INIT_40(16'h9000), // Channel sequencer: continuous, ch0+ch1
        .INIT_41(16'h2ef0), // Enable averaging x16 for stability
        .INIT_42(16'h0400), // ADCCLK = DCLK/4 = 6 MHz
        .INIT_48(16'h0301), // Sequencer: measure temp + VCCINT
        .INIT_49(16'h0000)
    ) xadc_inst (
        .DCLK    (clk_24mhz),
        .RESET   (reset),
        .CONVST  (1'b0),
        .CONVSTCLK(1'b0),
        .VP      (1'b0),
        .VN      (1'b0),
        .VAUXP   (16'd0),
        .VAUXN   (16'd0),
        .ALM     (),
        .OT      (),
        .MUXADDR (),
        .CHANNEL (),
        .EOC     (xadc_eoc),
        .EOS     (),
        .BUSY    (),
        .DRDY    (xadc_drdy),
        .DO      (xadc_do),
        .DADDR   (xadc_daddr),
        .DEN     (xadc_den),
        .DWE     (1'b0),
        .DI      (16'd0),
        .JTAGLOCKED(),
        .JTAGMODIFIED(),
        .JTAGBUSY()
    );

    // On each EOC, latch the reading and switch channel for next read
    assign xadc_daddr = xadc_read_phase ? 7'h01 : 7'h00; // 0x00=Temp, 0x01=VCCINT
    assign xadc_den   = xadc_eoc;

    always @(posedge clk_24mhz) begin
        xadc_sample_valid_r <= 1'b0;
        if (reset) begin
            xadc_vccint_reg    <= 12'h550;  // Safe default until first reading
            xadc_temp_reg      <= 12'h500;  // Safe default until first reading
            xadc_read_phase    <= 1'b0;
        end else if (xadc_drdy) begin
            if (xadc_read_phase)
                xadc_vccint_reg <= xadc_do[15:4];  // VCCINT: top 12 bits
            else begin
                xadc_temp_reg   <= xadc_do[15:4];  // Temperature: top 12 bits
                xadc_sample_valid_r <= 1'b1;        // Fire valid after both read
            end
            xadc_read_phase <= ~xadc_read_phase;
        end
    end

    always @(posedge clk_24mhz) begin
        if (reset) begin
            sd_write_done_latched <= 1'b0;
            sd_write_error_latched <= 1'b0;
        end else begin
            if (sd_write_done)
                sd_write_done_latched <= 1'b1;
            if (sd_write_error)
                sd_write_error_latched <= 1'b1;
        end
    end


    wire core_buzzer;
    wire core_relay;
    wire core_cpu_trap;

    // 1-to-1 Mapping of LEDs L1-L8
    // Note: LEDs on this board are ACTIVE LOW (0 = ON). 
    assign led[0] = ~(reset_pin);                               // L1 (D5) - Power / System Run (ON when switch UP)
    assign led[1] = sd_detect_n;                                // L2 (A3) - SD Card Detect (ON when card inserted, sd_detect_n=0)
    assign led[2] = sd_cs_n;                                    // L3 (B4) - SD Card Reading/Writing Activity (ON when CS=0)
    assign led[3] = core_cpu_trap;                              // L4 (A4) - "CPU ON" (ON when CPU is NOT trapped)
    assign led[4] = ~(relay_in);                                // L5 (E6) - Relay Status (ON when relay is active)
    assign led[5] = ~(led_internal[3]);                         // L6 (C13) - Security Alarm Active
    assign led[6] = ~(led_internal[1]);                         // L7 (C14) - Security Command Accepted
    assign led[7] = ~(led_internal[2]);                         // L8 (D14) - Security Command Rejected

    assign buzzer = core_buzzer;
    assign relay_in = core_relay | sw_relay_force;

    sentinel_rv_top #(
        .AUDIT_KEY(AUDIT_KEY),
        .SD_DETECT_ACTIVE_LOW(SD_DETECT_ACTIVE_LOW)
    ) system_wrapper (
        .clk_24mhz(clk_24mhz), .reset(reset),
        .pmod_uart_rx(pmod_uart_rx), .pmod_uart_tx(pmod_uart_tx),
        .adc_sck(adc_sck), .adc_mosi(adc_mosi), .adc_miso(adc_miso), .adc_cs_n(adc_cs_n),
        .sd_clk(sd_clk), .sd_cmd(sd_cmd), .sd_d0(sd_d0), .sd_cs_n(sd_cs_n), .sd_detect_n(sd_detect_n),
        .led(led_internal),
        .buzzer(core_buzzer),
        .relay_in(core_relay),
        .dht11_data(dht11_data),
        .security_clear_alarm(clear_alarm),
        .manual_alarm_test(sw_alarm_test),
        .security_xadc_sample_valid(xadc_sample_valid_r),
        .security_xadc_vccint_code(xadc_vccint_reg),
        .security_xadc_temperature_code(xadc_temp_reg),
        .security_command_accepted(), .security_command_rejected(),
        .security_alarm(), .security_aes_reset(),
        .security_tx_start(1'b0), .security_tx_plaintext(128'd0),
        .security_tx_key(128'd0), .security_tx_nonce(64'd0),
        .security_tx_sequence(8'd0), .security_tx_packet(),
        .security_tx_packet_valid(), .security_tx_busy(), .security_cpu_trap(core_cpu_trap),
        .security_audit_request(1'b0),
        .security_audit_digest(128'h112233445566778899AABBCCDDEEFF00),
        .security_audit_ready(), .security_audit_chain_head(),
        .security_audit_storage_failed(sd_storage_failed),
        .security_sd_write_done(sd_write_done),
        .security_sd_write_error(sd_write_error),
        .security_sd_card_missing(sd_card_missing),
        .security_key_valid(), .security_key_ascii()
    );
endmodule
