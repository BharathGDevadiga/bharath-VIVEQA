`timescale 1ns / 1ps

module UART #(
    parameter CLK_FREQ    = 24_000_000,
    parameter BAUD_RATE   = 9600,
    parameter PARITY_EN   = 1,
    parameter PARITY_TYPE = 0
)(
    input clk,
    input rst,

    input uart_rx_pin,
    output uart_tx_pin,

    output [3:0] led,
    input  [3:0] btn
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam TWO_SEC = CLK_FREQ * 2;
    localparam TIMER_W = $clog2(TWO_SEC + 1);

    wire [7:0] rx_data;
    wire rx_done;
    wire rx_parity_err;
    wire rx_frame_err;

    uart_rx #(
        .CLKS_PER_BIT (CLKS_PER_BIT),
        .PARITY_EN (PARITY_EN),
        .PARITY_TYPE (PARITY_TYPE)
    ) u_rx (
        .clk (clk),
        .rst (rst),
        .rx (uart_rx_pin),
        .rx_data (rx_data),
        .rx_done (rx_done),
        .parity_err (rx_parity_err),
        .frame_err (rx_frame_err)
    );

    wire tx_busy;
    wire tx_done;
    reg tx_start;
    reg [7:0] tx_byte;

    uart_tx #(
        .CLKS_PER_BIT (CLKS_PER_BIT),
        .PARITY_EN (PARITY_EN),
        .PARITY_TYPE (PARITY_TYPE)
    ) u_tx (
        .clk (clk),
        .rst (rst),
        .tx_start (tx_start),
        .tx_data (tx_byte),
        .tx (uart_tx_pin),
        .tx_busy (tx_busy),
        .tx_done (tx_done)
    );

    localparam DEBOUNCE_MS  = 20;
    localparam DEBOUNCE_CNT = (CLK_FREQ / 1000) * DEBOUNCE_MS;
    localparam DEB_W = $clog2(DEBOUNCE_CNT + 1);

    reg [3:0] btn_sync1, btn_sync2;
    reg [3:0] btn_stable;
    reg [3:0] btn_prev;
    reg [3:0] btn_posedge;
    reg [DEB_W-1:0] deb_cnt [0:3];

    always @(posedge clk) begin
        if (rst) begin btn_sync1 <= 4'b0; btn_sync2 <= 4'b0; 
          
        end else begin 
          btn_sync1 <= btn;  btn_sync2 <= btn_sync1; 
        end
    end

    genvar gi;
  
    generate
        for (gi = 0; gi < 4; gi = gi + 1) begin : g_deb
          
            always @(posedge clk) begin
                if (rst) begin
                  
                    deb_cnt[gi]    <= 0;
                    btn_stable[gi] <= 1'b0;
                end else begin
                  
                    if (btn_sync2[gi] !== btn_stable[gi]) begin
                        if (deb_cnt[gi] == DEBOUNCE_CNT - 1) begin
                          
                            btn_stable[gi] <= btn_sync2[gi];
                            deb_cnt[gi]    <= 0;
                          
                        end else
                            deb_cnt[gi] <= deb_cnt[gi] + 1;
                      
                    end else
                        deb_cnt[gi] <= 0;
                end
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (rst) begin btn_prev <= 4'b0; btn_posedge <= 4'b0; end
      
        else begin
          
            btn_prev    <= btn_stable;
            btn_posedge <= btn_stable & ~btn_prev;
        end
    end

    reg [3:0] led_reg;
    reg timer_active;
    reg [TIMER_W-1:0] led_timer;

    always @(posedge clk) begin
        if (rst) begin
          
            led_reg <= 4'b0000;
            timer_active <= 1'b0;
            led_timer <= 0;
        end else begin
            if (rx_done && !rx_parity_err && !rx_frame_err) begin
                case (rx_data)
                    8'h31: begin led_reg <= 4'b0001; timer_active <= 1; led_timer <= TWO_SEC; end
                    8'h32: begin led_reg <= 4'b0010; timer_active <= 1; led_timer <= TWO_SEC; end
                    8'h33: begin led_reg <= 4'b0100; timer_active <= 1; led_timer <= TWO_SEC; end
                    8'h34: begin led_reg <= 4'b1000; timer_active <= 1; led_timer <= TWO_SEC; end
                    8'h61: begin led_reg <= 4'b1111; timer_active <= 0; led_timer <= 0;       end
                    8'h78: begin led_reg <= 4'b0000; timer_active <= 0; led_timer <= 0;       end
                    default: ;
                endcase
            end

            if (timer_active) begin
                if (led_timer == 0) begin
                    led_reg      <= 4'b0000;
                    timer_active <= 1'b0;
                end else
                    led_timer <= led_timer - 1;
            end
        end
    end

    assign led = led_reg;

    localparam MSG_LEN   = 19;
    localparam MSG_TOTAL = 4 * MSG_LEN;

    reg [7:0] msg_rom [0:MSG_TOTAL-1];

    initial begin
      
        msg_rom[ 0]="B"; msg_rom[ 1]="u"; msg_rom[ 2]="t"; msg_rom[ 3]="t";
        msg_rom[ 4]="o"; msg_rom[ 5]="n"; msg_rom[ 6]=" "; msg_rom[ 7]="0";
        msg_rom[ 8]=" "; msg_rom[ 9]="P"; msg_rom[10]="r"; msg_rom[11]="e";
        msg_rom[12]="s"; msg_rom[13]="s"; msg_rom[14]="e"; msg_rom[15]="d";
        msg_rom[16]=8'h0D; msg_rom[17]=8'h0A; msg_rom[18]=" ";

        msg_rom[19]="B"; msg_rom[20]="u"; msg_rom[21]="t"; msg_rom[22]="t";
        msg_rom[23]="o"; msg_rom[24]="n"; msg_rom[25]=" "; msg_rom[26]="1";
        msg_rom[27]=" "; msg_rom[28]="P"; msg_rom[29]="r"; msg_rom[30]="e";
        msg_rom[31]="s"; msg_rom[32]="s"; msg_rom[33]="e"; msg_rom[34]="d";
        msg_rom[35]=8'h0D; msg_rom[36]=8'h0A; msg_rom[37]=" ";

        msg_rom[38]="B"; msg_rom[39]="u"; msg_rom[40]="t"; msg_rom[41]="t";
        msg_rom[42]="o"; msg_rom[43]="n"; msg_rom[44]=" "; msg_rom[45]="2";
        msg_rom[46]=" "; msg_rom[47]="P"; msg_rom[48]="r"; msg_rom[49]="e";
        msg_rom[50]="s"; msg_rom[51]="s"; msg_rom[52]="e"; msg_rom[53]="d";
        msg_rom[54]=8'h0D; msg_rom[55]=8'h0A; msg_rom[56]=" ";

        msg_rom[57]="B"; msg_rom[58]="u"; msg_rom[59]="t"; msg_rom[60]="t";
        msg_rom[61]="o"; msg_rom[62]="n"; msg_rom[63]=" "; msg_rom[64]="3";
        msg_rom[65]=" "; msg_rom[66]="P"; msg_rom[67]="r"; msg_rom[68]="e";
        msg_rom[69]="s"; msg_rom[70]="s"; msg_rom[71]="e"; msg_rom[72]="d";
        msg_rom[73]=8'h0D; msg_rom[74]=8'h0A; msg_rom[75]=" ";
    end

    localparam TX_IDLE = 2'd0;
    localparam TX_LOAD = 2'd1;
    localparam TX_SEND = 2'd2;
    localparam TX_WAIT = 2'd3;

    reg [1:0] tx_state;
    reg [6:0] tx_ptr;
    reg [6:0] tx_end;
    reg [3:0] btn_pending;
    reg [3:0] btn_serving;

    function [1:0] pri_enc;
        input [3:0] pending;
        begin
            if (pending[0]) pri_enc = 2'd0;
            else if (pending[1]) pri_enc = 2'd1;
            else if (pending[2]) pri_enc = 2'd2;
          
            else  
              pri_enc = 2'd3;
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
          
            tx_state <= TX_IDLE;
            tx_ptr <= 0;
            tx_end  <= 0;
            tx_start  <= 0;
            tx_byte <= 0;
            btn_pending <= 4'b0;
          
        end else begin
            tx_start <= 1'b0;

            btn_pending <= btn_pending | btn_posedge;

            case (tx_state)
                TX_IDLE: begin
                  
                    if (btn_pending != 4'b0) begin
                        btn_serving <= pri_enc(btn_pending);
                        tx_ptr <= pri_enc(btn_pending) * MSG_LEN;
                        tx_end <= pri_enc(btn_pending) * MSG_LEN + MSG_LEN - 2;
                        btn_pending[pri_enc(btn_pending)] <= 1'b0;
                        tx_state <= TX_LOAD;
                    end
                end

                TX_LOAD: begin
                  
                    tx_byte  <= msg_rom[tx_ptr];
                    tx_state <= TX_SEND;
                end

                TX_SEND: begin
                  
                    if (!tx_busy) begin
                        tx_start <= 1'b1;
                        tx_state <= TX_WAIT;
                    end
                end

                TX_WAIT: begin
                    if (tx_done) begin
                        if (tx_ptr == tx_end)
                          
                            tx_state <= TX_IDLE;
                        else begin
                            tx_ptr   <= tx_ptr + 1;
                            tx_state <= TX_LOAD;
                          
                        end
                    end
                end

                default: tx_state <= TX_IDLE;
              
            endcase
        end
    end

endmodule
