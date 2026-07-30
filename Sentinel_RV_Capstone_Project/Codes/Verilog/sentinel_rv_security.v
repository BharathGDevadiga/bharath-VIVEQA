`timescale 1ns/1ps

module sentinel_rv_security (
    input  wire         clk,
    input  wire         reset,
    input  wire         rx_packet_valid,
    input  wire [63:0]  rx_nonce,
    input  wire         rx_crc_ok,
    input  wire         clear_alarm,
    input  wire         xadc_sample_valid,
    input  wire [11:0]  xadc_vccint_code,
    input  wire [11:0]  xadc_temperature_code,
    output wire         command_accepted,
    output wire         command_rejected,
    output wire         alarm,
    output wire         aes_reset,
    input  wire         tx_start,
    input  wire [127:0] tx_plaintext,
    input  wire [127:0] tx_key,
    input  wire [63:0]  tx_nonce,
    input  wire [7:0]   tx_sequence,
    output wire [239:0] tx_packet,
    output wire         tx_packet_valid,
    output wire         tx_busy,
    output wire         cpu_trap,
    input  wire         cpu_command_ready,
    output wire         cpu_command_valid,
    output wire [7:0]   cpu_command_opcode,
    output wire [7:0]   cpu_command_sequence,
    output wire [15:0]  cpu_command_argument,
    output wire         cpu_alive
);
    wire replay_start, replay_busy, replay_done, replay_detected;
    wire xadc_glitch_event, xadc_alarm;

    wire [63:0] generated_nonce;
    wire generated_nonce_valid;
    wire formatter_start;
    wire formatter_busy;
    reg transmit_pending;
    reg [127:0] pending_plaintext;
    reg [127:0] pending_key;
    reg [63:0] pending_nonce;
    reg [7:0] pending_sequence;
    wire cpu_mem_valid, cpu_mem_instr, cpu_mem_ready;
    wire [31:0] cpu_mem_addr, cpu_mem_wdata, cpu_mem_rdata;
    wire [3:0] cpu_mem_wstrb;
    wire ram_mem_valid, ram_mem_ready;
    wire [31:0] ram_mem_addr, ram_mem_wdata, ram_mem_rdata;
    wire [3:0] ram_mem_wstrb;

    xadc_monitor xadc (
        .clk(clk), .reset(reset), .sample_valid(xadc_sample_valid), .vccint_code(xadc_vccint_code),
        .temperature_code(xadc_temperature_code), .clear_alarm(clear_alarm), .glitch_event(xadc_glitch_event),
        .alarm_latched(xadc_alarm), .last_vccint(), .last_temperature()
    );
    replay_protection replay (
        .clk(clk), .reset(reset), .check_start(replay_start), .nonce_in(rx_nonce), .busy(replay_busy),
        .check_done(replay_done), .replay_detected(replay_detected), .nonce_accepted()
    );
    security_controller controller (
        .clk(clk), .reset(reset), .packet_valid(rx_packet_valid), .packet_crc_ok(rx_crc_ok),
        .replay_done(replay_done), .replay_detected(replay_detected),
        .xadc_glitch(xadc_glitch_event | xadc_alarm), .clear_alarm(clear_alarm),
        .replay_check_start(replay_start), .command_accepted(command_accepted),
        .command_rejected(command_rejected), .alarm_latched(alarm), .aes_reset(aes_reset), .secure_state()
    );
    packet_formatter formatter (
        .clk(clk), .reset(reset), .aes_reset(aes_reset), .start(formatter_start), .plaintext(pending_plaintext), .key(pending_key),
        .nonce((generated_nonce_valid && pending_nonce == 64'd0) ? generated_nonce : pending_nonce), .sequence(pending_sequence), .packet(tx_packet), .packet_valid(tx_packet_valid), .busy(formatter_busy)
    );
    nonce_generator nonce_source (
        .clk(clk), .reset(reset), .request(tx_start && !transmit_pending && tx_nonce == 64'd0),
        .nonce(generated_nonce), .nonce_valid(generated_nonce_valid)
    );

    assign formatter_start = transmit_pending && (pending_nonce != 64'd0 || generated_nonce_valid);
    assign tx_busy = transmit_pending | formatter_busy;

    always @(posedge clk) begin
        if (reset) begin
            transmit_pending <= 1'b0;
            pending_plaintext <= 128'd0;
            pending_key <= 128'd0;
            pending_nonce <= 64'd0;
            pending_sequence <= 8'd0;
        end else begin
            if (aes_reset)
                transmit_pending <= 1'b0;
            else begin
                if (tx_start && !transmit_pending) begin
                    pending_plaintext <= tx_plaintext;
                    pending_key <= tx_key;
                    pending_sequence <= tx_sequence;
                    pending_nonce <= tx_nonce;
                    transmit_pending <= 1'b1;
                end
                if (transmit_pending && pending_nonce == 64'd0 && generated_nonce_valid)
                    pending_nonce <= generated_nonce;
                if (formatter_start)
                    transmit_pending <= 1'b0;
            end
        end
    end
    picorv32_wrapper cpu (
        .clk(clk), .reset(reset), .trap(cpu_trap), .mem_valid(cpu_mem_valid), .mem_instr(cpu_mem_instr),
        .mem_ready(cpu_mem_ready), .mem_addr(cpu_mem_addr), .mem_wdata(cpu_mem_wdata),
        .mem_wstrb(cpu_mem_wstrb), .mem_rdata(cpu_mem_rdata)
    );
    cpu_mmio_bridge cpu_bus (
        .clk(clk), .reset(reset),
        .cpu_mem_valid(cpu_mem_valid), .cpu_mem_instr(cpu_mem_instr), .cpu_mem_addr(cpu_mem_addr),
        .cpu_mem_wdata(cpu_mem_wdata), .cpu_mem_wstrb(cpu_mem_wstrb),
        .cpu_mem_ready(cpu_mem_ready), .cpu_mem_rdata(cpu_mem_rdata),
        .ram_mem_valid(ram_mem_valid), .ram_mem_addr(ram_mem_addr), .ram_mem_wdata(ram_mem_wdata),
        .ram_mem_wstrb(ram_mem_wstrb), .ram_mem_ready(ram_mem_ready), .ram_mem_rdata(ram_mem_rdata),
        .command_ready(cpu_command_ready), .cpu_command_valid(cpu_command_valid),
        .cpu_command_opcode(cpu_command_opcode), .cpu_command_sequence(cpu_command_sequence),
        .cpu_command_argument(cpu_command_argument), .cpu_alive(cpu_alive)
    );
    simple_bram_memory memory (
        .clk(clk), .reset(reset), .mem_valid(ram_mem_valid), .mem_addr(ram_mem_addr), .mem_wdata(ram_mem_wdata),
        .mem_wstrb(ram_mem_wstrb), .mem_ready(ram_mem_ready), .mem_rdata(ram_mem_rdata)
    );
endmodule
