`timescale 1ns / 1ps

module digital_clock(
    input  wire clk_24mhz,
    output reg seg_cs  = 1,
    output reg seg_clk = 0,
    output reg seg_din = 0
);

//==========================================================
// SPI Tick (1 MHz)
//==========================================================

reg [4:0] div = 0;
wire tick = (div == 23);

always @(posedge clk_24mhz)begin
    if(tick)
      
        div <= 0;
    else
      
        div <= div + 1;
end

//==========================================================
// 1 Second Timer
//==========================================================

reg [24:0] sec_div = 0;
reg one_sec = 0;

always @(posedge clk_24mhz) begin
    if(sec_div == 49) begin      // 50 clock cycles = 1 simulated second
      
        sec_div <= 0;
        one_sec <= 1;
    end else begin
      
        sec_div <= sec_div + 1;
        one_sec <= 0;
    end
end

//==========================================================
// Clock Registers
//==========================================================

reg [5:0] sec  = 0;
reg [5:0] min  = 0;
reg [4:0] hour = 0;

always @(posedge clk_24mhz) begin
    if(one_sec)begin

        if(sec == 59)begin
            sec <= 0;
            
            if(min == 59)begin
                min <= 0;

                if(hour == 23)
                    hour <= 0;
                else
                  
                    hour <= hour + 1;
            end else
              
                min <= min + 1;
        end else
          
            sec <= sec + 1;
    end
end

//==========================================================
// Decimal Digits
//==========================================================

wire [3:0] d0;
wire [3:0] d1;
wire [3:0] d2;
wire [3:0] d3;

assign d0 = min  % 10;
assign d1 = min  / 10;
assign d2 = hour % 10;
assign d3 = hour / 10;

//==========================================================
// SPI FSM
//==========================================================

reg [5:0] state = 0;
reg [15:0] shift = 0;
reg [2:0] cmd = 0;

always @(posedge clk_24mhz) begin
  if(tick) begin

//------------------------------------------------
// Load Command
//------------------------------------------------

    if(state==0) begin

    seg_cs  <= 0;
    seg_clk <= 0;

    case(cmd)

    // Initialization

    3'd0: shift <= 16'h0C01;     // Shutdown -> Normal
    3'd1: shift <= 16'h09FF;     // Decode Mode
    3'd2: shift <= 16'h0A08;     // Intensity
    3'd3: shift <= 16'h0B03;     // Scan Limit = 4 digits

    // Display

    3'd4: shift <= {8'h01,4'h0,d0};
    3'd5: shift <= {8'h02,4'h0,d1};
    3'd6: shift <= {8'h03,4'h0,d2};
    3'd7: shift <= {8'h04,4'h0,d3};

    endcase

    state <= 1;

 end

//------------------------------------------------
// Shift 16 bits
//------------------------------------------------

    else if(state<=32) begin
      if(state[0]) begin
        
        seg_din <= shift[15];
        seg_clk <= 0;
    end else begin
      
        seg_clk <= 1;
        shift <= {shift[14:0],1'b0};
    end

    state <= state + 1;
end

//------------------------------------------------
// Finish Transfer
//------------------------------------------------

else begin

    seg_cs  <= 1;
    seg_clk <= 0;

    if(cmd<7)
      
        cmd <= cmd + 1;
    else
      
        cmd <= 4;
    state <= 0;
end
    
end
end

endmodule
