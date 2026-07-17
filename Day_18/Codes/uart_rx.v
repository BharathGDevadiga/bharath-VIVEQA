`timescale 1ns / 1ps

module uart_rx #(
    parameter CLKS_PER_BIT = 2500,
    parameter PARITY_EN    = 1,
    parameter PARITY_TYPE  = 0
)(
    input            clk,
    input            rst,
    input            rx,
    output reg [7:0] rx_data,
    output reg       rx_done,
    output reg       parity_err,
    output reg       frame_err
);

    localparam S_IDLE   = 3'd0;
    localparam S_START  = 3'd1;
    localparam S_DATA   = 3'd2;
    localparam S_PARITY = 3'd3;
    localparam S_STOP   = 3'd4;

    reg rx_sync1, rx_sync2;
  
    always @(posedge clk) begin
      
        if (rst) {rx_sync1, rx_sync2} <= 2'b11;
      
        else    
        {rx_sync1, rx_sync2} <= {rx, rx_sync1};
      
    end
  
    wire rx_s = rx_sync2;

    reg [2:0] state;
    reg [$clog2(CLKS_PER_BIT):0] baud_cnt;
    reg [2:0] bit_idx;
    reg [7:0] rx_shift;
    reg rx_parity;
    reg parity_latch;

    localparam HALF_BIT = CLKS_PER_BIT / 2;

    always @(posedge clk) begin
      
        if (rst) begin
          
            state        <= S_IDLE;
            baud_cnt     <= 0;
            bit_idx      <= 0;
            rx_shift     <= 0;
            rx_data      <= 0;
            rx_done      <= 1'b0;
            parity_err   <= 1'b0;
            frame_err    <= 1'b0;
            rx_parity    <= 0;
            parity_latch <= 0;
          
        end else begin
          
            rx_done    <= 1'b0;
            parity_err <= 1'b0;
            frame_err  <= 1'b0;

            case (state)
              
                S_IDLE: begin
                  
                    baud_cnt     <= 0;
                    bit_idx      <= 0;
                    rx_parity    <= 0;
                    parity_latch <= 0;
                  
                    if (!rx_s)
                      
                        state <= S_START;
                end

                S_START: begin
                  
                    if (baud_cnt == HALF_BIT - 1) begin
                      
                        baud_cnt <= 0;
                        if (!rx_s)
                            state <= S_DATA;
                      
                        else
                            state <= S_IDLE;
                      
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                S_DATA: begin
                  
                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                      
                        baud_cnt          <= 0;
                        rx_shift[bit_idx] <= rx_s;
                        rx_parity         <= rx_parity ^ rx_s;
                      
                        if (bit_idx == 7) begin
                          
                            bit_idx <= 0;
                            state   <= PARITY_EN ? S_PARITY : S_STOP;
                          
                        end else
                            bit_idx <= bit_idx + 1;
                      
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                S_PARITY: begin
                  
                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                      
                        baud_cnt <= 0;
                        parity_latch <= PARITY_TYPE ?
                                        ~(rx_parity ^ rx_s) :
                                         (rx_parity ^ rx_s);
                        state <= S_STOP;
                      
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                S_STOP: begin
                  
                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                      
                        rx_data    <= rx_shift;
                        rx_done    <= 1'b1;
                        parity_err <= PARITY_EN ? parity_latch : 1'b0;
                        frame_err  <= !rx_s;
                        baud_cnt   <= 0;
                        state      <= S_IDLE;
                      
                    end else
                        baud_cnt <= baud_cnt + 1;
                  
                end

                default: state <= S_IDLE;
              
            endcase
          
        end
    end

endmodule
