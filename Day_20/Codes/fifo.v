`timescale 1ns / 1ps

module fifo(
    input clk,
    input rst,
    input wr_en,
    input rd_en,
    input [7:0] write_data,
    output reg [7:0] read_data
);

reg [7:0] mem [0:15];

reg [4:0] wr_ptr;
reg [4:0] rd_ptr;

wire full;
wire empty;

reg wr_en_d;
reg rd_en_d;

wire pos_det_wr_en;
wire pos_det_rd_en;

integer i;

// Status Flags
assign empty = (wr_ptr == rd_ptr);

assign full = (wr_ptr[4] != rd_ptr[4]) &&
              (wr_ptr[3:0] == rd_ptr[3:0]);

// Write Logic
always @(posedge clk) begin
  
  if (rst) begin
        wr_ptr <= 5'd0;

        for(i = 0; i < 16; i = i + 1)
            mem[i] <= 8'd0;

    end
    else if(pos_det_wr_en && !full) begin
      
        mem[wr_ptr[3:0]] <= write_data;
        wr_ptr <= wr_ptr + 1;
    end
end

// Read Logic
always @(posedge clk) begin

    if(rst) begin
        rd_ptr <= 5'd0;
        read_data <= 8'd0;
    end

    else if(pos_det_rd_en && !empty) begin
        read_data <= mem[rd_ptr[3:0]];
        rd_ptr <= rd_ptr + 1;
    end

end

// Edge Detector
always @(posedge clk) begin
    if(rst)
        wr_en_d <= 1'b0;
    else
        wr_en_d <= wr_en;
end

always @(posedge clk) begin
    if(rst)
        rd_en_d <= 1'b0;
    else
        rd_en_d <= rd_en;
end

assign pos_det_wr_en = (~wr_en_d) & wr_en;
assign pos_det_rd_en = (~rd_en_d) & rd_en;

// ILA
ila_0 ila(
    .clk(clk),
    .probe0(full),
    .probe1(empty)
);

endmodule
