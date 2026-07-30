`timescale 1ns/1ps
module tb_sentinel_rv_security;
    reg clk=0, reset=1, rx_valid=0, rx_crc_ok=1, clear_alarm=0, xadc_valid=0;
    reg [63:0] rx_nonce=64'hCAFEBABE12345678;
    reg [11:0] vccint=12'h550, temp=12'h500;
    reg tx_start=0; reg [127:0] tx_plain=0, tx_key=0; reg [63:0] tx_nonce=0; reg [7:0] tx_seq=0;
    wire accepted,rejected,alarm,aes_reset,tx_valid,tx_busy,cpu_trap; wire [239:0] tx_packet;
    sentinel_rv_security dut (.clk(clk),.reset(reset),.rx_packet_valid(rx_valid),.rx_nonce(rx_nonce),.rx_crc_ok(rx_crc_ok),.clear_alarm(clear_alarm),.xadc_sample_valid(xadc_valid),.xadc_vccint_code(vccint),.xadc_temperature_code(temp),.command_accepted(accepted),.command_rejected(rejected),.alarm(alarm),.aes_reset(aes_reset),.tx_start(tx_start),.tx_plaintext(tx_plain),.tx_key(tx_key),.tx_nonce(tx_nonce),.tx_sequence(tx_seq),.tx_packet(tx_packet),.tx_packet_valid(tx_valid),.tx_busy(tx_busy),.cpu_trap(cpu_trap));
    always #5 clk=~clk;
    initial begin
        repeat(3) @(posedge clk); reset=0;
        @(negedge clk); rx_valid=1; @(negedge clk); rx_valid=0;
        wait(accepted); #1;
        if (alarm || aes_reset) $display("FAIL: security top accepted packet alarmed"); else $display("PASS: sentinel_rv_security accepted packet");
        $finish;
    end
endmodule
