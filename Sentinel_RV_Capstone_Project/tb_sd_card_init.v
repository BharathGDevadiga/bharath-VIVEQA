`timescale 1ns/1ps
module tb_sd_card_init;
    reg clk=0, reset=1;
    wire init_busy, init_done, init_failed, xfer_start, xfer_hold_cs, xfer_force_cs_high;
    wire [7:0] xfer_data;
    reg [7:0] xfer_rx=8'hFF;
    reg xfer_busy=0, xfer_done=0;
    reg [7:0] next_rx=8'hFF;
    reg [2:0] current_command=0;
    reg [2:0] command_bytes_left=0;
    reg response_pending=0;
    reg [2:0] extended_bytes_left=0;

    sd_card_init dut (.clk(clk),.reset(reset),.init_busy(init_busy),.init_done(init_done),.init_failed(init_failed),.xfer_start(xfer_start),.xfer_data(xfer_data),.xfer_hold_cs(xfer_hold_cs),.xfer_force_cs_high(xfer_force_cs_high),.xfer_rx(xfer_rx),.xfer_busy(xfer_busy),.xfer_done(xfer_done));
    always #5 clk=~clk;

    // Minimal SPI-card responder: only the expected initialization replies.
    always @(posedge clk) begin
        xfer_done <= 0;
        if (xfer_start) begin
            xfer_busy <= 1;
            next_rx <= 8'hFF;
            if (!xfer_force_cs_high) begin
                if (command_bytes_left != 0) begin
                    if (command_bytes_left == 1) begin
                        command_bytes_left <= 0;
                        response_pending <= 1;
                    end else
                        command_bytes_left <= command_bytes_left - 1;
                end else if (response_pending) begin
                    response_pending <= 0;
                    case (current_command)
                        0, 1, 2: next_rx <= 8'h01;
                        3, 4: next_rx <= 8'h00;
                    endcase
                    if (current_command == 1 || current_command == 4)
                        extended_bytes_left <= 4;
                end else if (extended_bytes_left != 0) begin
                    if (current_command == 1 && extended_bytes_left == 1)
                        next_rx <= 8'hAA;
                    else if (current_command == 4 && extended_bytes_left == 4)
                        next_rx <= 8'h40; // OCR: CCS set (SDHC)
                    extended_bytes_left <= extended_bytes_left - 1;
                end else if (xfer_data == 8'h40 || xfer_data == 8'h48 || xfer_data == 8'h77 || xfer_data == 8'h69 || xfer_data == 8'h7A) begin
                    case (xfer_data)
                        8'h40: current_command <= 0;
                        8'h48: current_command <= 1;
                        8'h77: current_command <= 2;
                        8'h69: current_command <= 3;
                        default: current_command <= 4;
                    endcase
                    command_bytes_left <= 5;
                end
            end
        end else if (xfer_busy) begin
            xfer_busy <= 0;
            xfer_done <= 1;
            xfer_rx <= next_rx;
        end
    end

    initial begin
        repeat(3) @(posedge clk); reset=0;
        wait(init_done || init_failed); #1;
        if (!init_done || init_failed) $display("FAIL: sd_card_init"); else $display("PASS: sd_card_init");
        $finish;
    end
endmodule
