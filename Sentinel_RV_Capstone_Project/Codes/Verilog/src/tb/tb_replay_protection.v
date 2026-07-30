`timescale 1ns/1ps
module tb_replay_protection;
    reg clk=0, reset=1, check_start=0; reg [63:0] nonce_in=0;
    wire busy, check_done, replay_detected, nonce_accepted;
    replay_protection #(.DEPTH(4)) dut (.clk(clk),.reset(reset),.check_start(check_start),.nonce_in(nonce_in),.busy(busy),.check_done(check_done),.replay_detected(replay_detected),.nonce_accepted(nonce_accepted));
    always #5 clk=~clk;
    task check_nonce; input [63:0] value; begin
        @(negedge clk); nonce_in=value; check_start=1; @(negedge clk); check_start=0;
        wait(check_done); #1;
    end endtask
    initial begin
        repeat(3) @(posedge clk); reset=0;
        check_nonce(64'h0123456789ABCDEF);
        if (!nonce_accepted || replay_detected) $display("FAIL: first nonce rejected");
        check_nonce(64'h0123456789ABCDEF);
        if (!replay_detected || nonce_accepted) $display("FAIL: replay not detected");
        else $display("PASS: replay_protection");
        $finish;
    end
endmodule
