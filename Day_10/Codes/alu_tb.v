`timescale 1ns / 1ps

module alu_tb;

    reg  [7:0] push;
    reg  [15:0] key;
    wire [7:0] led;

    // Instantiate the ALU
    alu uut (
        .push(push),
        .key(key),
        .led(led)
    );

    initial begin

        // A = 8, B = 8
        push = 8'b10001000;

        // No key pressed
        key = 16'b0000000000000000;
        #10;

        // 1. ADD
        key = 16'b0000000000000001;
        #10;

        // 2. SUB
        key = 16'b0000000000000010;
        #10;

        // 3. AND
        key = 16'b0000000000000100;
        #10;

        // 4. OR
        key = 16'b0000000000001000;
        #10;

        // 5. A << B
        key = 16'b0000000000010000;
        #10;

        // 6. A >> B
        key = 16'b0000000000100000;
        #10;

        // 7. XOR
        key = 16'b0000000001000000;
        #10;

        // 8. NOT A
        key = 16'b0000000010000000;
        #10;

        // 9. MULTIPLY
        key = 16'b0000000100000000;
        #10;

        // 10. NOR
        key = 16'b0000001000000000;
        #10;

        // 11. NAND
        key = 16'b0000010000000000;
        #10;

        // 12. A << 2
        key = 16'b0000100000000000;
        #10;

        // 13. A >> 2
        key = 16'b0001000000000000;
        #10;

        // 14. XNOR
        key = 16'b0010000000000000;
        #10;

        // 15. A + 1
        key = 16'b0100000000000000;
        #10;

        // 16. B + 1
        key = 16'b1000000000000000;
        #10;

        // No key pressed
        key = 16'b0000000000000000;
        #10;

        $finish;

    end

    // Display results
   initial begin
     
    $monitor("A=%d B=%d Key=%b LED=%d",
             push[7:4], push[3:0], key, led);
     
end

endmodule
