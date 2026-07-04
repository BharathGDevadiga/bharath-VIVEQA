`timescale 1ns/1ps

module repeat_adder_149 (

    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  in_data,
    output reg  [7:0]  out_data,
    output reg         done
);

reg [7:0] count;   // 8-bit counter for 149 repetitions

always @(posedge clk or posedge rst) 
begin

    if (rst) begin
        out_data <= in_data;
        count <= 8'd0;
        done <= 1'b0;

  end

   else if (count < 8'd149) begin

       out_data <= out_data + in_data; // feedback adder
       count <= count + 1'b1;
   end

  else begin

      done <= 1'b1;

    end
end

endmodule
