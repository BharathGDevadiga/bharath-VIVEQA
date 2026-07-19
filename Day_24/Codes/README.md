# Day 24 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a **Universal Shift Register** using Verilog HDL on the FPGA board.

## Files

``universal_shift_register.v``

``universal_shift_register_tb.v``

``universal_shift_register.xdc``

## Description

``universal_shift_register.v`` contains the Verilog module for a 4-bit Universal Shift Register. The design supports four different modes of operation selected using a 2-bit control signal. These modes include Hold, Shift Right, Shift Left and Parallel Load. The register updates on the positive edge of the clock and includes a synchronous reset to initialize all bits to zero.

``universal_shift_register_tb.v`` contains the testbench used to simulate and verify the Universal Shift Register. The simulation applies reset, exercises all operating modes including Hold, Shift Right, Shift Left and Parallel Load and verifies that the register behaves correctly for each control input.

``universal_shift_register.xdc`` contains the Xilinx Design Constraints (XDC) file that maps the 24 MHz system clock, reset push button, mode selection switches, serial inputs, parallel data inputs and register outputs to the appropriate FPGA pins. It also specifies the LVCMOS33 I/O standard required for FPGA implementation.
