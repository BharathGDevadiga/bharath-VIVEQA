# Day 30 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a Digital Dice Game using Verilog HDL on the FPGA board.

## Files

- `digital_dice.v`
- `digital_dice_tb.v`
- `digital_dice.xdc`

## Description

`digital_dice.v` contains the Verilog module for a Digital Dice Game. The design uses a 16-bit LFSR (Linear Feedback Shift Register) to generate pseudo-random values and converts them into a dice output ranging from 1 to 6. The generated dice value is displayed on a seven-segment display. The design includes push button control for rolling the dice and seven-segment decoding logic for displaying the output.

`digital_dice_tb.v` contains the testbench used to simulate and verify the Digital Dice Game. The simulation generates the 24 MHz clock signal, applies roll button inputs, monitors the generated dice values and verifies the seven-segment display output.

`digital_dice.xdc` contains the Xilinx Design Constraints (XDC) file that maps the 24 MHz system clock, push button input, seven-segment display signals and digit enable signals to the appropriate FPGA pins. It also specifies the LVCMOS33 I/O standard required for FPGA implementation.
