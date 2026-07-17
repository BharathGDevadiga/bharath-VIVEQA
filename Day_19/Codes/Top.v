`timescale 1ns / 1ps

module Top(
    input clk
);

wire wr_en;
wire [5:0] addr;
wire [31:0] write_data;
wire [31:0] read_data;

single_port_ram ram (
    .clk(clk),
    .addr(addr),
    .write_data(write_data),
    .wr_en(wr_en),
    .read_data(read_data)
);

ila_0 ila (
    .clk(clk),
    .probe0(wr_en),
    .probe1(addr),
    .probe2(write_data),
    .probe3(read_data)
);

vio_0 vio (
    .clk(clk),
    .probe_in0(read_data),
    .probe_out0(wr_en),
    .probe_out1(addr),
    .probe_out2(write_data)
);

endmodule
