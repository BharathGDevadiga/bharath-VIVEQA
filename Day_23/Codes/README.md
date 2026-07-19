# Day 23 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a **Parameterized Counter** using Verilog HDL on the FPGA board.

## Files

``parameterized_counter.v``

``parameterized_counter_tb.v``

``parameterized_counter.xdc``

## Description

``parameterized_counter.v`` contains the Verilog module for a configurable synchronous counter. The counter width is controlled using the `WIDTH` parameter, allowing the same design to be reused for different counter sizes. The counter increments on every positive edge of the clock when the enable (`en`) signal is HIGH and resets to zero when the reset (`rst`) signal is asserted. The design demonstrates reusable hardware implementation using Verilog parameters.

``parameterized_counter_tb.v`` contains the testbench used to simulate and verify the parameterized counter. The simulation generates the system clock, applies reset, enables and disables the counter and verifies the increment, hold and reset operations. The testbench also confirms that the counter wraps around correctly after reaching its maximum value based on the selected counter width.

``parameterized_counter.xdc`` contains the Xilinx Design Constraints (XDC) file that maps the 24 MHz system clock, reset push button, enable push button and the counter output (`count[7:0]`) to the appropriate FPGA pins. It also specifies the LVCMOS33 I/O standard required for FPGA implementation.
