`timescale 1ns / 1ps

module led_boardproj_tb;

reg  [7:0] switch;
wire [7:0] led;

// Instantiate the Design Under Test (DUT)
led_boardproj dut (
    .switch(switch),
    .led(led)
);

initial begin

    // Test Case 1
    switch = 8'b00000000;
    #10;

    // Test Case 2
    switch = 8'b11111111;
    #10;

    // Test Case 3
    switch = 8'b10101010;
    #10;

    // Test Case 4
    switch = 8'b01010101;
    #10;

    // Test Case 5
    switch = 8'b11001100;
    #10;

    // Test Case 6
    switch = 8'b00110011;
    #10;

    $finish;
  
end
  
  initial begin

   $monitor("Switch = %b | LED = %b", switch, led);

  end

endmodule
