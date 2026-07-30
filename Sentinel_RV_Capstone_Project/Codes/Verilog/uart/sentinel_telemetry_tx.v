`timescale 1ns/1ps

module sentinel_telemetry_tx (
    input  wire        clk,
    input  wire        reset,
    input  wire        telemetry_valid,
    output wire        telemetry_ready,
    input  wire [7:0]  telemetry_sequence,
    input  wire [7:0]  telemetry_event,
    input  wire [11:0] telemetry_sensor,
    input  wire [7:0]  dht11_temp,
    input  wire [7:0]  dht11_hum,
    input  wire [15:0] distance,
    input  wire [7:0]  telemetry_status,
    input  wire        uart_busy,
    output reg         uart_start,
    output reg [7:0]   uart_data
);
    localparam [7:0] SOF = 8'hA6;
    reg [3:0] byte_index;
    reg active, awaiting_busy;
    reg [7:0] checksum;
    reg [7:0] sequence_reg, event_reg, status_reg;
    reg [11:0] sensor_reg;
    reg [7:0] temp_reg, hum_reg;
    reg [15:0] distance_reg;

    assign telemetry_ready = !active;

    function [7:0] payload_byte;
        input [3:0] index;
        begin
            case (index)
                4'd0:  payload_byte = SOF;
                4'd1:  payload_byte = sequence_reg;
                4'd2:  payload_byte = event_reg;
                4'd3:  payload_byte = {4'd0, sensor_reg[11:8]};
                4'd4:  payload_byte = sensor_reg[7:0];
                4'd5:  payload_byte = temp_reg;
                4'd6:  payload_byte = hum_reg;
                4'd7:  payload_byte = distance_reg[15:8];
                4'd8:  payload_byte = distance_reg[7:0];
                4'd9:  payload_byte = status_reg;
                default: payload_byte = checksum;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            active <= 1'b0;
            awaiting_busy <= 1'b0;
            byte_index <= 4'd0;
            uart_start <= 1'b0;
            uart_data <= 8'd0;
            checksum <= 8'd0;
            sequence_reg <= 8'd0;
            event_reg <= 8'd0;
            sensor_reg <= 12'd0;
            temp_reg <= 8'd0;
            hum_reg <= 8'd0;
            distance_reg <= 16'd0;
            status_reg <= 8'd0;
            awaiting_busy <= 1'b0;
        end else begin
            uart_start <= 1'b0;
            if (!active && telemetry_valid) begin
                active <= 1'b1;
                byte_index <= 4'd0;
                sequence_reg <= telemetry_sequence;
                event_reg <= telemetry_event;
                sensor_reg <= telemetry_sensor;
                temp_reg <= dht11_temp;
                hum_reg <= dht11_hum;
                distance_reg <= distance;
                status_reg <= telemetry_status;
                checksum <= SOF ^ telemetry_sequence ^ telemetry_event ^
                            {4'd0, telemetry_sensor[11:8]} ^ telemetry_sensor[7:0] ^
                            dht11_temp ^ dht11_hum ^ distance[15:8] ^ distance[7:0] ^ telemetry_status;
            end else if (active && awaiting_busy) begin
                if (uart_busy) begin
                    awaiting_busy <= 1'b0;
                    if (byte_index == 4'd10)
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
