`timescale 1ns / 1ps

module digital_dice(
    input clk_24mhz,
    input rst,
    input roll,
    output reg [6:0] seg,
    output [3:0] an
);

reg [15:0] lfsr;
reg [2:0] dice_value;

// Always enable first display
assign an = 4'b1110;

// LFSR and Dice
always @(posedge clk_24mhz or posedge rst) begin

    if(rst) begin
      
        lfsr <= 16'hACE1;
        dice_value <= 3'd1;
      
    end else begin

        // LFSR
        lfsr <= {lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};

        // Roll Dice
        if(roll)
          
            dice_value <= (lfsr % 6) + 1;

    end
end


// Seven Segment Decoder
  always @(*) begin

    case(dice_value)

        3'd1: seg = 7'b1111001;
        3'd2: seg = 7'b0100100;
        3'd3: seg = 7'b0110000;
        3'd4: seg = 7'b0011001;
        3'd5: seg = 7'b0010010;
        3'd6: seg = 7'b0000010;

        default: seg = 7'b1111111;

    endcase

end

endmodule
