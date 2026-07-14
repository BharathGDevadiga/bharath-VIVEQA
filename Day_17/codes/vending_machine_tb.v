module vending_machine_tb();
  
reg clk,rst;
reg [1:0]coin;
wire D,C;

vending_machine dut(clk,rst,coin,D,C);

always #5clk=~clk;

initial begin
  
clk=1'b0;
rst=1'b0;
coin=2'd0;
#12 rst=1'b1;
#12 rst=1'b0;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd2;
#12 coin=2'd2;
#12 coin=2'd2;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd1;

#12 $finish;
  
end

initial begin
  
    $monitor("Time=%0t rst=%b coin=%b state=%b D=%b C=%b",
             $time, rst, coin, dut.state, D, C);
  
end
  
endmodule
