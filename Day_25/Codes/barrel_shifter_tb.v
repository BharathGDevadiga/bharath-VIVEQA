`timescale 1ns / 1ps

module barrel_shifter_tb;

reg [7:0] data_in;
reg [2:0] shift_amt;
reg dir;

wire [7:0] data_out;

barrel_shifter uut(
    .data_in(data_in),
    .shift_amt(shift_amt),
    .dir(dir),
    .data_out(data_out)
);

initial begin

    data_in = 8'b10110101;

    // Left Shift by 1
    dir = 0;
    shift_amt = 3'd1;
    #10;

    // Left Shift by 2
    shift_amt = 3'd2;
    #10;

    // Left Shift by 3
    shift_amt = 3'd3;
    #10;

    // Right Shift by 1
    dir = 1;
    shift_amt = 3'd1;
    #10;

    // Right Shift by 2
    shift_amt = 3'd2;
    #10;

    // Right Shift by 3
    shift_amt = 3'd3;
    #10;

    // New Input
    data_in = 8'b11001010;

    dir = 0;
    shift_amt = 3'd4;
    #10;

    dir = 1;
    shift_amt = 3'd4;
    #10;

    $finish;

end

initial begin
  
    $monitor("Time=%0t Dir=%b Shift=%d Input=%b Output=%b",
             $time,dir,shift_amt,data_in,data_out);
  
end

endmodule
