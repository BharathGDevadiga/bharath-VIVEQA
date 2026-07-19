`timescale 1ns / 1ps

//PARAMETERIZED FIFO

module fifo_parameterized #(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
    parameter PTR_WIDTH = 4
)(
    input clk,
    input rst,
    input wr_en,
    input rd_en,
    input [WIDTH-1:0] write_data,
    output reg [WIDTH-1:0] read_data,
    output full,
    output empty
);

reg [WIDTH-1:0] mem [0:DEPTH-1];
reg [PTR_WIDTH:0] wr_ptr, rd_ptr;

// Status Flags
assign empty = (wr_ptr == rd_ptr);

assign full = (wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]) &&
              (wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]);

// Write Logic
always @(posedge clk) begin
    if (rst)
      
        wr_ptr <= 0;
    else if (wr_en && !full) begin
      
        mem[wr_ptr[PTR_WIDTH-1:0]] <= write_data;
        wr_ptr <= wr_ptr + 1;
    end
end

// Read Logic
always @(posedge clk) begin
    if (rst) begin
      
        rd_ptr <= 0;
        read_data <= 0;
    end
    else if (rd_en && !empty) begin
      
        read_data <= mem[rd_ptr[PTR_WIDTH-1:0]];
        rd_ptr <= rd_ptr + 1;
    end
end

endmodule

//EDGE DETECTOR

module edge_detector(
    input clk,
    input rst,
    input signal_in,
    output pulse );
reg delay;
  
always @(posedge clk) begin
    if(rst)
      
        delay <= 0;
    else
      
        delay <= signal_in;
end
  
assign pulse = signal_in & ~delay;
  
endmodule


module top_fifo(
input clk,
input rst,
input wr_en,
input rd_en,
input [7:0] sw,
output [7:0] led 
);

wire wr_pulse;
wire rd_pulse;

// Edge Detectors
edge_detector E1(
    .clk(clk),
    .rst(rst),
    .signal_in(wr_en),
    .pulse(wr_pulse)
);

edge_detector E2(
    .clk(clk),
    .rst(rst),
    .signal_in(rd_en),
    .pulse(rd_pulse)
);

// FIFO
fifo_parameterized FIFO(
    .clk(clk),
    .rst(rst),
    .wr_en(wr_pulse),
    .rd_en(rd_pulse),
    .write_data(sw),
    .read_data(led),
    .full(),
    .empty()
);

endmodule
