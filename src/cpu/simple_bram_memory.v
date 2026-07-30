`timescale 1ns/1ps

module simple_bram_memory #(
    parameter integer WORDS = 1024,
    parameter MEM_FILE = "cpu_test_program.hex"
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        mem_valid,
    input  wire [31:0] mem_addr,
    input  wire [31:0] mem_wdata,
    input  wire [3:0]  mem_wstrb,
    output reg         mem_ready,
    output reg [31:0]  mem_rdata
);
    localparam integer ADDR_W = (WORDS <= 1) ? 1 : $clog2(WORDS);
    reg [31:0] memory [0:WORDS-1];
    wire [ADDR_W-1:0] word_address = mem_addr[ADDR_W+1:2];

    initial begin
        if (MEM_FILE != "") $readmemh(MEM_FILE, memory);
    end

    always @(posedge clk) begin
        if (reset) begin
            mem_ready <= 1'b0;
            mem_rdata <= 32'd0;
        end else begin
            mem_ready <= mem_valid;
            if (mem_valid) begin
                mem_rdata <= memory[word_address];
                if (mem_wstrb[0]) memory[word_address][7:0] <= mem_wdata[7:0];
                if (mem_wstrb[1]) memory[word_address][15:8] <= mem_wdata[15:8];
                if (mem_wstrb[2]) memory[word_address][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) memory[word_address][31:24] <= mem_wdata[31:24];
            end
        end
    end
endmodule
