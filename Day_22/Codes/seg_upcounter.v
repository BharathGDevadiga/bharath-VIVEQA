`timescale 1ns / 1ps

module seg_upcounter(
    input  wire clk_24mhz,
    output reg  seg_cs  = 1,
    output reg  seg_clk = 0,
    output reg  seg_din = 0
);

    //========================================================
    // 1 MHz SPI Tick
    //========================================================
    reg [4:0] div = 0;
    wire tick = (div == 23);

    always @(posedge clk_24mhz)
        if(tick)
            div <= 0;
        else
            div <= div + 1;

    //========================================================
    // Counter (increments every ~0.5 second)
    //========================================================
    reg [23:0] count_div = 0;
    reg [13:0] number = 0;

    always @(posedge clk_24mhz) begin
      
        if(count_div == 24'd11_999_999) begin
          
            count_div <= 0;

            if(number == 9999)
                number <= 0;
          
            else
                number <= number + 1;
        end else
          
            count_div <= count_div + 1;
    end

    //========================================================
    // Decimal Digits
    //========================================================
    wire [3:0] d0,d1,d2,d3;

    assign d0 = number % 10;
    assign d1 = (number / 10) % 10;
    assign d2 = (number / 100) % 10;
    assign d3 = (number / 1000) % 10;

    //========================================================
    // SPI FSM
    //========================================================
    reg [5:0] state = 0;
    reg [15:0] shift = 0;
    reg [2:0] cmd = 0;

    always @(posedge clk_24mhz) begin
        if(tick) begin

            if(state == 0) begin
                seg_cs  <= 0;
                seg_clk <= 0;

                case(cmd)

                    // Initialization
                    3'd0: shift <= 16'h0C01;   // Normal mode
                    3'd1: shift <= 16'h09FF;   // Decode mode
                    3'd2: shift <= 16'h0A08;   // Brightness
                    3'd3: shift <= 16'h0B03;   // 4 digits

                    // Display digits
                    3'd4: shift <= {8'h01,4'h0,d0};
                    3'd5: shift <= {8'h02,4'h0,d1};
                    3'd6: shift <= {8'h03,4'h0,d2};
                    3'd7: shift <= {8'h04,4'h0,d3};

                endcase

                state <= 1;
            end

            else if(state <= 32) begin

                if(state[0]) begin
                  
                    seg_din <= shift[15];
                    seg_clk <= 0;
                end else begin
                  
                    seg_clk <= 1;
                    shift <= {shift[14:0],1'b0};
                end

                state <= state + 1;

            end

            else begin

                seg_cs  <= 1;
                seg_clk <= 0;

                cmd <= (cmd < 7) ? cmd + 1 : 3'd4;
                state <= 0;

            end
        end
    end

endmodule
