`timescale 1ns / 1ps

module pass_key_tb;

reg [7:0] sw;
reg confirm;
wire buzzer;
wire [7:0] leds;

// Instantiate DUT
pass_key dut(
    .sw(sw),
    .confirm(confirm),
    .buzzer(buzzer),
    .leds(leds)
);

initial begin

    // Test Case 1 : Confirm not pressed
    sw = 8'b10101010;
    confirm = 1'b0;
    #10;

    // Test Case 2 : Correct Password
    confirm = 1'b1;
    #10;

    // Test Case 3 : Wrong Password
    sw = 8'b11110000;
    #10;

    // Test Case 4 : Another Wrong Password
    sw = 8'b00001111;
    #10;

    // Test Case 5 : Correct Password Again
    sw = 8'b10101010;
    #10;

    $finish;

end

initial begin
  
    $monitor("Confirm=%b Switch=%b LEDs=%b Buzzer=%b",
              confirm, sw, leds, buzzer);
  
end

endmodule
