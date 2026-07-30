`timescale 1ns/1ps

module dht11_controller #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer UPDATE_INTERVAL_MS = 2000 // DHT11 needs ~2s between readings
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        dht_in,
    output reg         dht_out,
    output reg         dht_oe,
    output reg [7:0]   temperature,
    output reg [7:0]   humidity,
    output reg         valid
);
    localparam integer US_CLKS = CLK_HZ / 1_000_000;
    localparam integer MS_CLKS = CLK_HZ / 1_000;
    
    localparam [3:0] IDLE = 0, START_LOW = 1, START_HIGH = 2, WAIT_ACK_LOW = 3, WAIT_ACK_HIGH = 4, 
                     WAIT_DATA_LOW = 5, WAIT_DATA_HIGH = 6, DONE = 7;
    reg [3:0] state;
    
    reg [31:0] timer;
    reg [31:0] interval_timer;
    reg [5:0] bit_count;
    reg [39:0] shift_reg;
    
    reg dht_in_sync1, dht_in_sync2;
    always @(posedge clk) begin
        dht_in_sync1 <= dht_in;
        dht_in_sync2 <= dht_in_sync1;
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            dht_out <= 1'b0;
            dht_oe <= 1'b0;
            temperature <= 8'd0;
            humidity <= 8'd0;
            valid <= 1'b0;
            timer <= 0;
            interval_timer <= 0;
            bit_count <= 0;
            shift_reg <= 0;
        end else begin
            valid <= 1'b0;
            case (state)
                IDLE: begin
                    dht_oe <= 1'b0;
                    if (interval_timer >= (MS_CLKS * UPDATE_INTERVAL_MS)) begin
                        interval_timer <= 0;
                        state <= START_LOW;
                        timer <= 0;
                        dht_oe <= 1'b1;
                        dht_out <= 1'b0;
                    end else begin
                        interval_timer <= interval_timer + 1'b1;
                    end
                end
                START_LOW: begin
                    if (timer >= (MS_CLKS * 20)) begin // 20ms low
                        timer <= 0;
                        dht_oe <= 1'b0; // release line
                        state <= START_HIGH;
                    end else begin
                        timer <= timer + 1'b1;
                    end
                end
                START_HIGH: begin
                    if (!dht_in_sync2) begin
                        timer <= 0;
                        state <= WAIT_ACK_LOW;
                    end else if (timer >= (US_CLKS * 100)) begin // Timeout
                        state <= IDLE;
                    end else begin
                        timer <= timer + 1'b1;
                    end
                end
                WAIT_ACK_LOW: begin
                    if (dht_in_sync2) begin
                        timer <= 0;
                        state <= WAIT_ACK_HIGH;
                    end else if (timer >= (US_CLKS * 100)) begin
                        state <= IDLE;
                    end else begin
                        timer <= timer + 1'b1;
                    end
                end
                WAIT_ACK_HIGH: begin
                    if (!dht_in_sync2) begin
                        timer <= 0;
                        bit_count <= 0;
                        state <= WAIT_DATA_LOW;
                    end else if (timer >= (US_CLKS * 100)) begin
                        state <= IDLE;
                    end else begin
                        timer <= timer + 1'b1;
                    end
                end
                WAIT_DATA_LOW: begin
                    if (dht_in_sync2) begin
                        timer <= 0;
                        state <= WAIT_DATA_HIGH;
                    end else if (timer >= (US_CLKS * 100)) begin
                        state <= IDLE;
                    end else begin
                        timer <= timer + 1'b1;
                    end
                end
                WAIT_DATA_HIGH: begin
                    if (!dht_in_sync2) begin
                        shift_reg <= {shift_reg[38:0], (timer > (US_CLKS * 40)) ? 1'b1 : 1'b0};
                        timer <= 0;
                        if (bit_count == 39) begin
                            state <= DONE;
                        end else begin
                            bit_count <= bit_count + 1'b1;
                            state <= WAIT_DATA_LOW;
                        end
                    end else if (timer >= (US_CLKS * 100)) begin
                        state <= IDLE;
                    end else begin
                        timer <= timer + 1'b1;
                    end
                end
                DONE: begin
                    // Verify checksum
                    if (shift_reg[39:32] + shift_reg[31:24] + shift_reg[23:16] + shift_reg[15:8] == shift_reg[7:0]) begin
                        humidity <= shift_reg[39:32];
                        temperature <= shift_reg[23:16];
                        valid <= 1'b1;
                    end
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
