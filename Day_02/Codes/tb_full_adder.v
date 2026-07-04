`timescale 1ns / 1ps

module tb_full_adder;

reg a, b, cin;
wire sum, carry;

full_adder_using_two_half_adders dut(
    a,
    b,
    cin,
    sum,
    carry
);

integer i;

initial begin
    
    for(i = 0; i < 8; i = i + 1) begin
        {a, b, cin} = i;
        #10;
        
    end
    
    $finish;
    
end

endmodule
