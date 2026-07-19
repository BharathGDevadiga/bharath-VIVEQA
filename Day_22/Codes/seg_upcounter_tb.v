`timescale 1ns / 1ps

module seg_upcounter_tb;

    reg clk_24mhz;
    wire seg_cs;
    wire seg_clk;
    wire seg_din;

    // DUT
    seg_upcounter uut (
        .clk_24mhz(clk_24mhz),
        .seg_cs(seg_cs),
        .seg_clk(seg_clk),
        .seg_din(seg_din)
    );

    // 24 MHz Clock
    initial begin
      
        clk_24mhz = 1'b0;
        forever #20.833 clk_24mhz = ~clk_24mhz;
      
    end

    // Simulation
    initial begin
        // Run long enough to observe SPI transfers
        #1000000;

        $finish;
    end

  // Simulation
initial begin

    $monitor("Time=%0t | Count=%0d | CS=%b | CLK=%b | DIN=%b",
             $time, uut.number, seg_cs, seg_clk, seg_din);

    #1000000; $finish;
  
end

endmodule
