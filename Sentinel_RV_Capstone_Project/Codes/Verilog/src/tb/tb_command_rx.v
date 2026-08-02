`timescale 1ns/1ps
module tb_command_rx;
    reg clk, reset, rx_valid;
    reg [7:0] rx_data;
    wire cmd_valid, cmd_error;
    wire [7:0] opcode, seq_num;
    wire [15:0] argument;

    // Instantiate DUT
    sentinel_command_rx dut (
        .clk(clk),
        .reset(reset),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .cmd_valid(cmd_valid),
        .cmd_opcode(opcode),
        .cmd_sequence(seq_num),
        .cmd_argument(argument),
        .cmd_error(cmd_error)
    );

    always #5 clk = ~clk;

    task send;
        input [7:0] value;
        begin
            @(negedge clk); rx_data = value; rx_valid = 1;
            @(negedge clk); rx_valid = 0;
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        rx_valid = 0;
        rx_data = 0;
        
        repeat (2) @(posedge clk);
        reset = 0;

        send(8'hA5); send(8'h22); send(8'h09); send(8'hBE); send(8'hEF); send(8'hDF);
        @(posedge clk); #1;
        if (!cmd_valid || opcode != 8'h22 || seq_num != 8'h09 || argument != 16'hBEEF)
            $display("FAIL: command parser");
        else
            $display("PASS: sentinel_command_rx");
        $finish;
    end
endmodule
