`timescale 1ns/1ps
module tb_telemetry_tx;
    reg clk=0, reset=1, telemetry_valid=0, uart_busy=0;
    reg [7:0] seq=8'h11, event_code=8'h22, status=8'h33; reg [11:0] sensor=12'hABC;
    wire telemetry_ready, uart_start; wire [7:0] uart_data;
    reg [7:0] bytes [0:6]; integer count=0;
    sentinel_telemetry_tx dut (.clk(clk),.reset(reset),.telemetry_valid(telemetry_valid),.telemetry_ready(telemetry_ready),.telemetry_sequence(seq),.telemetry_event(event_code),.telemetry_sensor(sensor),.telemetry_status(status),.uart_busy(uart_busy),.uart_start(uart_start),.uart_data(uart_data));
    always #5 clk=~clk;
    always @(posedge clk) begin
        if (reset) uart_busy <= 0;
        else if (uart_start) begin bytes[count] <= uart_data; count <= count + 1; uart_busy <= 1; end
        else uart_busy <= 0;
    end
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); telemetry_valid=1; @(negedge clk); telemetry_valid=0;
        wait(count==7); #1;
        if (bytes[0]!=8'hA6 || bytes[1]!=seq || bytes[2]!=event_code || bytes[3]!={4'd0,sensor[11:8]} || bytes[4]!=sensor[7:0] || bytes[5]!=status || bytes[6]!=(8'hA6^seq^event_code^{4'd0,sensor[11:8]}^sensor[7:0]^status)) $display("FAIL: telemetry frame");
        else $display("PASS: sentinel_telemetry_tx");
        $finish;
    end
endmodule
