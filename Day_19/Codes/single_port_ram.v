`timescale 1ns / 1ps

module single_port_ram(
    input clk,
    input [5:0] addr,
    input [31:0] write_data,
    input wr_en,
    output reg [31:0] read_data
);

    // 64 memory locations, each 32 bits wide
    reg [31:0] mem [0:63];

    always @(posedge clk) begin
      
        if (wr_en)
          
            mem[addr] <= write_data;
      
        else
          
            read_data <= mem[addr];
      
    end

endmodule
