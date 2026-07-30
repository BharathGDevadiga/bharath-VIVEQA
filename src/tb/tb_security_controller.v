`timescale 1ns/1ps
module tb_security_controller;
    reg clk=0, reset=1, packet_valid=0, packet_crc_ok=0, replay_done=0, replay_detected=0, xadc_glitch=0, clear_alarm=0;
    wire replay_start, accepted, rejected, alarm, aes_reset; wire [2:0] state;
    security_controller dut (.clk(clk),.reset(reset),.packet_valid(packet_valid),.packet_crc_ok(packet_crc_ok),.replay_done(replay_done),.replay_detected(replay_detected),.xadc_glitch(xadc_glitch),.clear_alarm(clear_alarm),.replay_check_start(replay_start),.command_accepted(accepted),.command_rejected(rejected),.alarm_latched(alarm),.aes_reset(aes_reset),.secure_state(state));
    always #5 clk=~clk;
    initial begin
        repeat(3) @(posedge clk); reset=0;
        packet_crc_ok=1; @(negedge clk); packet_valid=1; @(negedge clk); packet_valid=0;
        wait(replay_start); @(negedge clk); replay_done=1; replay_detected=0; @(negedge clk); replay_done=0;
        wait(accepted);
        if (alarm) $display("FAIL: valid packet alarmed");
        packet_crc_ok=0; @(negedge clk); packet_valid=1; @(negedge clk); packet_valid=0;
        wait(rejected); if (!alarm || !aes_reset) $display("FAIL: CRC failure not locked down");
        else $display("PASS: security_controller");
        $finish;
    end
endmodule
