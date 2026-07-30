`timescale 1ns/1ps
module tb_aes128_encrypt;
    reg clk=0, reset=1, start=0;
    reg [127:0] plaintext=128'h00112233445566778899AABBCCDDEEFF;
    reg [127:0] key=128'h000102030405060708090A0B0C0D0E0F;
    wire [127:0] ciphertext; wire busy, done;
    aes128_encrypt dut (.clk(clk),.reset(reset),.start(start),.plaintext(plaintext),.key(key),.ciphertext(ciphertext),.busy(busy),.done(done));
    always #5 clk=~clk;
    initial begin
        repeat(3) @(posedge clk); reset=0;
        @(negedge clk); start=1; @(negedge clk); start=0;
        wait(done); #1;
        if (ciphertext !== 128'h69C4E0D86A7B0430D8CDB78070B4C55A) $display("FAIL: AES ciphertext=%h",ciphertext);
        else $display("PASS: aes128_encrypt FIPS-197 vector");
        $finish;
    end
endmodule
