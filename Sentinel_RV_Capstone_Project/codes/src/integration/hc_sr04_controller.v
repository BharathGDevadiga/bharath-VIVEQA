`timescale 1ns/1ps

module hc_sr04_controller #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer UPDATE_INTERVAL_MS = 100
) (
    input  wire        clk,
    input  wire        reset,
    output reg         trigger,
    input  wire        echo,
    output reg [15:0]  distance_cm,
    output reg         valid
);
    localparam integer TRIG_CLKS = (CLK_HZ / 1_000_000) * 10; // 10 us
    localparam integer CM_CLKS = (CLK_HZ / 1_000_000) * 58; // 58 us per cm
    localparam integer INTERVAL_CLKS = (CLK_HZ / 1000) * UPDATE_INTERVAL_MS;

    localparam [2:0] IDLE = 0, TRIG = 1, WAIT_ECHO = 2, MEASURE = 3;
    reg [2:0] state;
    
    reg [31:0] timer;
    reg [31:0] cm_timer;
    reg [15:0] count_cm;

    // Synchronize echo signal
    reg echo_sync1, echo_sync2;
    always @(posedge clk) begin
        echo_sync1 <= echo;
        echo_sync2 <= echo_sync1;
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            trigger <= 1'b0;
            distance_cm <= 16'd0;
            valid <= 1'b0;
            timer <= 0;
            cm_timer <= 0;
            count_cm <= 0;
        end else begin
            valid <= 1'b0;
            case (state)
                IDLE: begin
                    trigger <= 1'b0;
                    if (timer >= INTERVAL_CLKS) begin
                        timer <= 0;
                        state <= TRIG;
                        trigger <= 1'b1;
                    end else begin
                        timer <= timer + 1'b1;
                    end
                end
                TRIG: begin
                    if (timer >= TRIG_CLKS) begin
                        trigger <= 1'b0;
                        timer <= 0;
                        state <= WAIT_ECHO;
                    end else begin
                        timer <= timer + 1'b1;
                    end
                end
                WAIT_ECHO: begin
                    if (echo_sync2) begin
                        state <= MEASURE;
                        cm_timer <= 0;
                        count_cm <= 0;
                        timer <= 0; // use timer as a total timeout
                    end else if (timer >= (CLK_HZ / 20)) begin
                        // 50ms timeout if no echo received
                        distance_cm <= 16'hFFFF; // Error value
                        valid <= 1'b1;
                        timer <= 0;
                        state <= IDLE;
                    end else begin
                        timer <= timer + 1'b1;
                    end
                end
                MEASURE: begin
                    if (!echo_sync2) begin
                        distance_cm <= count_cm;
                        valid <= 1'b1;
                        timer <= 0;
                        state <= IDLE;
                    end else begin
                        if (cm_timer >= CM_CLKS) begin
                            cm_timer <= 0;
                            count_cm <= count_cm + 1'b1;
                        end else begin
                            cm_timer <= cm_timer + 1'b1;
                        end
                        // Timeout if stuck high for > 50ms
                        if (timer >= (CLK_HZ / 20)) begin
                            distance_cm <= 16'hFFFF;
                            valid <= 1'b1;
                            timer <= 0;
                            state <= IDLE;
                        end else begin
                            timer <= timer + 1'b1;
                        end
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
