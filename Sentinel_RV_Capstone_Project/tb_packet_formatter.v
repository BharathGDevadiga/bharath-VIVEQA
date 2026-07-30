`timescale 1ns/1ps
module tb_packet_formatter;
    reg clk=0, reset=1, aes_reset=0, start=0;
    reg [127:0] plaintext=128'h00112233445566778899AABBCCDDEEFF;
    reg [127:0] key=128'h000102030405060708090A0B0C0D0E0F;
    reg [63:0] nonce=64'h0102030405060708; reg [7:0] sequence=8'h12;
    wire [239:0] packet; wire packet_valid,busy;
    packet_formatter dut (.clk(clk),.reset(reset),.aes_reset(aes_reset),.start(start),.plaintext(plaintext),.key(key),.nonce(nonce),.sequence(sequence),.packet(packet),.packet_valid(packet_valid),.busy(busy));
    always #5 clk=~clk;
    initial begin
        repeat(3) @(posedge clk); reset=0;
        @(negedge clk); start=1; @(negedge clk); start=0;
        wait(packet_valid); #1;
        if (packet[239:232]!==8'hA5 || packet[231:168]!==nonce || packet[167:160]!==sequence || packet[159:32]!==128'h69C4E0D86A7B0430D8CDB78070B4C55A) $display("FAIL: packet formatter");
        else $display("PASS: packet_formatter");
        $finish;
    end
endmodule
