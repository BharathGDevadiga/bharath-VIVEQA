`timescale 1ns/1ps

// Command map: 10 relay on, 11 relay off, 20 motor forward, 21 motor reverse,
// 22 motor brake, 30 stepper. All outputs are one-cycle authorization pulses.
module actuator_authorizer (
    input  wire        clk,
    input  wire        reset,
    input  wire        result_valid,
    input  wire        result_accepted,
    input  wire [7:0]  opcode,
    input  wire [15:0] argument,
    output reg         authorized,
    output reg         relay_set,
    output reg         relay_reset,
    output reg         motor_enable,
    output reg [1:0]   motor_command,
    output reg [7:0]   motor_speed,
    output reg         stepper_start,
    output reg         stepper_direction,
    output reg [15:0]  stepper_count,
    output reg [23:0]  stepper_period
);
    always @(posedge clk) begin
        if (reset) begin
            authorized <= 1'b0;
            relay_set <= 1'b0;
            relay_reset <= 1'b0;
            motor_enable <= 1'b0;
            motor_command <= 2'b00;
            motor_speed <= 8'd0;
            stepper_start <= 1'b0;
            stepper_direction <= 1'b0;
            stepper_count <= 16'd0;
            stepper_period <= 24'd120000;
        end else begin
            authorized <= 1'b0;
            relay_set <= 1'b0;
            relay_reset <= 1'b0;
            motor_enable <= 1'b0;
            stepper_start <= 1'b0;
            if (result_valid && result_accepted) begin
                authorized <= 1'b1;
                case (opcode)
                    8'h10: relay_set <= 1'b1;
                    8'h11: relay_reset <= 1'b1;
                    8'h20: begin motor_enable <= 1'b1; motor_command <= 2'b01; motor_speed <= (argument[7:0] == 0) ? 8'hFF : argument[7:0]; end
                    8'h21: begin motor_enable <= 1'b1; motor_command <= 2'b10; motor_speed <= (argument[7:0] == 0) ? 8'hFF : argument[7:0]; end
                    8'h22: begin motor_enable <= 1'b1; motor_command <= 2'b11; motor_speed <= 8'hFF; end
                    8'h30: begin
                        stepper_start <= 1'b1;
                        stepper_direction <= argument[15];
                        stepper_count <= (argument[14:0] == 0) ? 16'd200 : {1'b0, argument[14:0]};
                        stepper_period <= 24'd120000;
                    end
                    default: authorized <= 1'b0;
                endcase
            end
        end
    end
endmodule
