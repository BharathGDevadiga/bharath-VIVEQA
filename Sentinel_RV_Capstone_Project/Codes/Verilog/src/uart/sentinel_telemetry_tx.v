`timescale 1ns/1ps

module sentinel_telemetry_tx (
    input  wire       clk,
    input  wire       reset,
    input  wire       telemetry_valid,
    output wire       telemetry_ready,
    input  wire [7:0] telemetry_sequence,
    input  wire [7:0] telemetry_event,
    input  wire [11:0] telemetry_sensor,
    input  wire [7:0] telemetry_status,
    input  wire       uart_busy,
    output reg        uart_start,
    output reg [7:0]  uart_data
);
    localparam [7:0] SOF = 8'hA6;
    reg [2:0] byte_index;
    reg active, awaiting_busy;
    reg [7:0] checksum;
    reg [7:0] sequence_reg, event_reg, status_reg;
    reg [11:0] sensor_reg;

    assign telemetry_ready = !active;

    function [7:0] payload_byte;
        input [2:0] index;
        begin
            case (index)
                3'd0: payload_byte = SOF;
                3'd1: payload_byte = sequence_reg;
                3'd2: payload_byte = event_reg;
                3'd3: payload_byte = {4'd0, sensor_reg[11:8]};
                3'd4: payload_byte = sensor_reg[7:0];
                3'd5: payload_byte = status_reg;
                default: payload_byte = checksum;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            active <= 1'b0;
            awaiting_busy <= 1'b0;
            byte_index <= 3'd0;
            uart_start <= 1'b0;
            uart_data <= 8'd0;
            checksum <= 8'd0;
            sequence_reg <= 8'd0;
            event_reg <= 8'd0;
            sensor_reg <= 12'd0;
            status_reg <= 8'd0;
        end else begin
            uart_start <= 1'b0;
            if (!active && telemetry_valid) begin
                active <= 1'b1;
                byte_index <= 3'd0;
                sequence_reg <= telemetry_sequence;
                event_reg <= telemetry_event;
                sensor_reg <= telemetry_sensor;
                status_reg <= telemetry_status;
                checksum <= SOF ^ telemetry_sequence ^ telemetry_event ^
                            {4'd0, telemetry_sensor[11:8]} ^ telemetry_sensor[7:0] ^ telemetry_status;
            end else if (active && awaiting_busy) begin
                if (uart_busy) begin
                    awaiting_busy <= 1'b0;
                    if (byte_index == 3'd6)
                        active <= 1'b0;
                    else
                        byte_index <= byte_index + 1'b1;
                end
            end else if (active && !uart_busy) begin
                uart_data <= payload_byte(byte_index);
                uart_start <= 1'b1;
                awaiting_busy <= 1'b1;
            end
        end
    end
endmodule
