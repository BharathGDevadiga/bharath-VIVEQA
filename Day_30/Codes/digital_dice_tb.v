`timescale 1ns / 1ps

module digital_dice_tb;

reg clk_24mhz;
reg rst;
reg roll;

wire [6:0] seg;
wire [3:0] an;

digital_dice uut(
    .clk_24mhz(clk_24mhz),
    .rst(rst),
    .roll(roll),
    .seg(seg),
    .an(an)
);

//24 MHz Clock
always #20.833 clk_24mhz = ~clk_24mhz;

initial begin

    clk_24mhz = 0;
    rst = 1;
    roll = 0;

    #100 rst = 0;

    #100 roll = 1;
    #40 roll = 0;

    #500;

    #100 roll = 1;
    #40 roll = 0;

    #500;

    $stop;

end

initial begin

$monitor("Time=%0t Roll=%b Dice=%d Seg=%b",
          $time,roll,uut.dice_value,seg);

end

endmodule
