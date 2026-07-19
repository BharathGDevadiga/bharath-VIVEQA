# Day 28 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a Frequency Divider using Verilog HDL on the FPGA board.

## Files

- frequency_divider.v
- frequency_divider_tb.v
- frequency_divider.xdc

## Description

**frequency_divider.v** contains the Verilog module for implementing a Frequency Divider using a 24-bit counter. The counter increments on every positive edge of the input clock and toggles the output clock after reaching a predefined count value. This reduces the frequency of the output clock while maintaining a stable waveform.

**frequency_divider_tb.v** contains the testbench used to simulate and verify the Frequency Divider. The simulation applies reset generates the input clock and observes the divided output clock. The waveform verifies that the output clock toggles correctly after the specified count value.

**frequency_divider.xdc** contains the Xilinx Design Constraints (XDC) file that maps the system clock reset signal and divided clock output to the appropriate FPGA pins. It also specifies the LVCMOS33 I/O standard required for FPGA implementation.
