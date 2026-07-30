`timescale 1ns/1ps

module cpu_mmio_bridge (
    input  wire        clk,
    input  wire        reset,
    input  wire        cpu_mem_valid,
    input  wire        cpu_mem_instr,
    input  wire [31:0] cpu_mem_addr,
    input  wire [31:0] cpu_mem_wdata,
    input  wire [3:0]  cpu_mem_wstrb,
    output wire        cpu_mem_ready,
    output wire [31:0] cpu_mem_rdata,

    output wire        ram_mem_valid,
    output wire [31:0] ram_mem_addr,
    output wire [31:0] ram_mem_wdata,
    output wire [3:0]  ram_mem_wstrb,
    input  wire        ram_mem_ready,
    input  wire [31:0] ram_mem_rdata,

    input  wire        command_ready,
    output reg         cpu_command_valid,
    output reg [7:0]   cpu_command_opcode,
    output reg [7:0]   cpu_command_sequence,
    output reg [15:0]  cpu_command_argument,
    output reg         cpu_alive
);
    localparam [31:0] COMMAND_ADDRESS = 32'h1000_0000;
    localparam [31:0] STATUS_ADDRESS  = 32'h1000_0004;

    wire mmio_access;
    wire write_access;
    wire command_write;

    assign mmio_access = cpu_mem_addr[31:28] == 4'h1;
    assign write_access = cpu_mem_valid && !cpu_mem_instr && (|cpu_mem_wstrb);
    assign command_write = write_access && cpu_mem_addr == COMMAND_ADDRESS;

    assign ram_mem_valid = cpu_mem_valid && !mmio_access;
    assign ram_mem_addr = cpu_mem_addr;
    assign ram_mem_wdata = cpu_mem_wdata;
    assign ram_mem_wstrb = cpu_mem_wstrb;

    assign cpu_mem_ready = mmio_access ? 1'b1 : ram_mem_ready;
    assign cpu_mem_rdata = mmio_access ?
                           (cpu_mem_addr == STATUS_ADDRESS ?
                            {29'd0, command_ready, cpu_command_valid, cpu_alive} : 32'd0) :
                           ram_mem_rdata;

    always @(posedge clk) begin
        if (reset) begin
            cpu_command_valid <= 1'b0;
            cpu_command_opcode <= 8'd0;
            cpu_command_sequence <= 8'd0;
            cpu_command_argument <= 16'd0;
            cpu_alive <= 1'b0;
        end else begin
            if (cpu_command_valid && command_ready)
                cpu_command_valid <= 1'b0;

            if (write_access && cpu_mem_addr == 32'd0)
                cpu_alive <= 1'b1;

            if (command_write && !cpu_command_valid) begin
                cpu_command_valid <= 1'b1;
                cpu_command_opcode <= cpu_mem_wdata[7:0];
                cpu_command_sequence <= cpu_command_sequence + 1'b1;
                cpu_command_argument <= cpu_mem_wdata[31:16];
            end
        end
    end
endmodule
