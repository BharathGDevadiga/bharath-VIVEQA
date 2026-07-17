`timescale 1ns / 1ps

module tb_single_port_ram;

reg clk;
reg [5:0] addr;
reg wr_en;
reg [31:0] write_data;
wire [31:0] read_data;

single_port_ram dut (
    .clk(clk),
    .addr(addr),
    .write_data(write_data),
    .wr_en(wr_en),
    .read_data(read_data)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    wr_en = 0;
    addr = 0;
    write_data = 0;

    // Write Operation
    #12 wr_en = 1;

    addr = 0;  write_data = 0;   #12;
    addr = 1;  write_data = 1;   #12;
    addr = 2;  write_data = 2;   #12;
    addr = 3;  write_data = 3;   #12;
    addr = 4;  write_data = 4;   #12;
    addr = 5;  write_data = 5;   #12;
    addr = 6;  write_data = 6;   #12;
    addr = 7;  write_data = 7;   #12;
    addr = 8;  write_data = 8;   #12;
    addr = 9;  write_data = 9;   #12;
    addr = 10; write_data = 10;  #12;
    addr = 11; write_data = 11;  #12;
    addr = 12; write_data = 12;  #12;

    // Read Operation
    wr_en = 0;

    addr = 0;   #12;
    addr = 1;   #12;
    addr = 2;   #12;
    addr = 3;   #12;
    addr = 4;   #12;
    addr = 5;   #12;
    addr = 6;   #12;
    addr = 7;   #12;
    addr = 8;   #12;
    addr = 9;   #12;
    addr = 10;  #12;
    addr = 11;  #12;
    addr = 12;  #12;

    $finish;

end

initial begin
  
    $monitor("Time=%0t | WR=%b | Addr=%d | WData=%d | RData=%d",
              $time, wr_en, addr, write_data, read_data);
  
end

endmodule
