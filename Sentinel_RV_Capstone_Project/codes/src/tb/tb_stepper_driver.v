`timescale 1ns/1ps
module tb_stepper_driver;
    reg clk=0, reset=1, authorized=0, start=0, direction=1; reg [15:0] step_count=2; reg [23:0] step_period=1;
    wire [3:0] stepper; wire busy,done,denied;
    stepper_driver dut (.clk(clk),.reset(reset),.authorized(authorized),.start(start),.direction(direction),.step_count(step_count),.step_period(step_period),.stepper(stepper),.busy(busy),.done(done),.denied(denied));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0; authorized=1;
        @(negedge clk); start=1; @(negedge clk); start=0;
        wait(done); #1;
        if (stepper!=0 || busy) $display("FAIL: stepper completion"); else $display("PASS: stepper_driver");
        $finish;
    end
endmodule
