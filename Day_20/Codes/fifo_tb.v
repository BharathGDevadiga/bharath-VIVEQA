`timescale 1ns / 1ps

module fifo_tb;

reg clk;
reg rst;
reg wr_en;
reg rd_en;
reg [7:0] write_data;

wire [7:0] read_data;

fifo dut(
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .write_data(write_data),
    .read_data(read_data)
);

// Clock
always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 1;
    wr_en = 0;
    rd_en = 0;
    write_data = 8'h00;

    #20;
    rst = 0;

    // Write 11
    #10;
    write_data = 8'h11;
    wr_en = 1;
    #10;
    wr_en = 0;

    // Write 22
    #20;
    write_data = 8'h22;
    wr_en = 1;
    #10;
    wr_en = 0;

    // Write 33
    #20;
    write_data = 8'h33;
    wr_en = 1;
    #10;
    wr_en = 0;

    // Write 44
    #20;
    write_data = 8'h44;
    wr_en = 1;
    #10;
    wr_en = 0;
    
       // Write 55
    #20;
    write_data = 8'h55;
    wr_en = 1;
    #10;
    wr_en = 0;

       // Write 66
    #20;
    write_data = 8'h66;
    wr_en = 1;
    #10;
    wr_en = 0;
    
       // Write 77
    #20;
    write_data = 8'h77;
    wr_en = 1;
    #10;
    wr_en = 0;
    
       // Write 88
    #20;
    write_data = 8'h88;
    wr_en = 1;
    #10;
    wr_en = 0;
    
    // Read
    #30;

    rd_en = 1;
    #10;
    rd_en = 0;

    #20;

    rd_en = 1;
    #10;
    rd_en = 0;

    #20;

    rd_en = 1;
    #10;
    rd_en = 0;

    #20;

    rd_en = 1;
    #10;
    rd_en = 0;
    
      #20;

    rd_en = 1;
    #10;
    rd_en = 0;
    
      #20;

    rd_en = 1;
    #10;
    rd_en = 0;
    
     #20;

    rd_en = 1;
    #10;
    rd_en = 0;
    
     #20;

    rd_en = 1;
    #10;
    rd_en = 0;
    
    #40;

    $finish;

end

initial begin
  
    $monitor("Time=%0t rst=%b wr=%b rd=%b write_data=%h read_data=%h wr_ptr=%d rd_ptr=%d",
             $time,rst, wr_en,rd_en,write_data,read_data, dut.wr_ptr,dut.rd_ptr);
  
end

endmodule
