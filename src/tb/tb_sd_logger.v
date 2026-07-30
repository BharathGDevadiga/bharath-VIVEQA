`timescale 1ns/1ps
module tb_sd_logger;
    reg clk=0, reset=1, log_valid=0, writer_busy=0, writer_done=0, writer_failed=0;
    reg [255:0] record=256'h1234;
    wire log_ready, logger_busy, log_done, log_failed, writer_start; wire [31:0] writer_sector; wire [255:0] writer_record; wire [5:0] writer_length;
    sd_logger #(.FIRST_SECTOR(32'd9)) dut (.clk(clk),.reset(reset),.log_valid(log_valid),.log_ready(log_ready),.log_record(record),.logger_busy(logger_busy),.log_done(log_done),.log_failed(log_failed),.writer_start(writer_start),.writer_sector(writer_sector),.writer_record(writer_record),.writer_length(writer_length),.writer_busy(writer_busy),.writer_done(writer_done),.writer_failed(writer_failed));
    always #5 clk=~clk;
    always @(posedge clk) begin
        writer_done <= 0;
        if (writer_start) writer_busy <= 1;
        else if (writer_busy) begin writer_busy <= 0; writer_done <= 1; end
    end
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); log_valid=1; @(negedge clk); log_valid=0;
        wait(log_done); #1;
        if (writer_sector!=32'd9 || writer_record!=record || writer_length!=32'd32 || log_failed) $display("FAIL: sd_logger");
        else $display("PASS: sd_logger");
        $finish;
    end
endmodule
