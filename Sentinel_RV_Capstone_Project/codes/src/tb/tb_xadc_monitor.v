`timescale 1ns/1ps
module tb_xadc_monitor;
    reg clk=0, reset=1, sample_valid=0, clear_alarm=0; reg [11:0] vccint=12'h550, temperature=12'h500;
    wire glitch_event, alarm_latched; wire [11:0] last_vcc,last_temp;
    xadc_monitor #(.FAULT_SAMPLES(2)) dut (.clk(clk),.reset(reset),.sample_valid(sample_valid),.vccint_code(vccint),.temperature_code(temperature),.clear_alarm(clear_alarm),.glitch_event(glitch_event),.alarm_latched(alarm_latched),.last_vccint(last_vcc),.last_temperature(last_temp));
    always #5 clk=~clk;
    task sample; begin @(negedge clk); sample_valid=1; @(negedge clk); sample_valid=0; end endtask
    initial begin
        repeat(3) @(posedge clk); reset=0;
        sample; if (alarm_latched) $display("FAIL: normal XADC reading");
        vccint=12'h400; sample; sample;
        if (!alarm_latched) $display("FAIL: XADC glitch not latched"); else $display("PASS: xadc_monitor");
        $finish;
    end
endmodule
