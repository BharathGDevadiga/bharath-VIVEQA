`timescale 1ns / 1ps

module frequency_divider(

    input clk,
    input rst,
    output reg clk_out

);

reg [23:0] counter;

always @(posedge clk) begin

    if(rst) begin
        counter <= 24'd0;
        clk_out <= 1'b0;
    end

    else begin

        if(counter == 24'd11_999_999) begin
            counter <= 24'd0;
            clk_out <= ~clk_out;
        end

        else
            counter <= counter + 1;

    end

end

endmodule
