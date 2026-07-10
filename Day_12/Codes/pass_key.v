`timescale 1ns / 1ps

module pass_key(
  
    input  [7:0] sw,
    input        confirm,
    output reg   buzzer,
    output reg [7:0] leds
);

always @(*) begin

    // Default outputs
    buzzer = 1'b0;
    leds   = 8'b00000000;

    if (confirm) begin
      
        if (sw == 8'b10101010) begin
          
            // Password = AA (10101010)
            leds   = 8'b11111111;
            buzzer = 1'b0;
          
        end
        else begin
          
            leds   = 8'b00000000;
            buzzer = 1'b1;
          
        end
    end

end

endmodule
