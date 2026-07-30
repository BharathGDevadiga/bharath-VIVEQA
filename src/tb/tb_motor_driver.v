`timescale 1ns/1ps
module tb_motor_driver;
    reg clk=0, reset=1, authorized=0, motor_enable=0; reg [1:0] motor_command=0; reg [7:0] speed=8'hFF;
    wire in1,in2,denied;
    motor_driver dut (.clk(clk),.reset(reset),.authorized(authorized),.motor_enable(motor_enable),.motor_command(motor_command),.speed(speed),.in1(in1),.in2(in2),.denied(denied));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        motor_enable=1; motor_command=2'b01; @(posedge clk);
        if (!denied || in1 || in2) $display("FAIL: motor unauthorized gate");
        authorized=1; repeat(2) @(posedge clk);
        if (!in1 || in2) $display("FAIL: motor forward"); else $display("PASS: motor_driver");
        $finish;
    end
endmodule
