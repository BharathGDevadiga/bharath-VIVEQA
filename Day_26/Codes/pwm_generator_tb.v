`timescale 1ns / 1ps

module pwm_generator_tb;

reg clk;
reg rst;
reg [7:0] duty_cycle;

wire pwm_out;

pwm_generator uut(
    .clk(clk),
    .rst(rst),
    .duty_cycle(duty_cycle),
    .pwm_out(pwm_out)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 1;
    duty_cycle = 8'd0;

    #20;
    rst = 0;

    duty_cycle = 8'd64;      //25%
    #3000;

    duty_cycle = 8'd128;     //50%
    #3000;

    duty_cycle = 8'd192;     //75%
    #3000;

    duty_cycle = 8'd255;     //100%
    #3000;

    $finish;

end

initial begin

    $monitor("Time=%0t | Reset=%b | Duty Cycle=%d | Counter PWM=%b",
             $time, rst, duty_cycle, pwm_out);
end


endmodule
