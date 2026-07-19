# Day 27 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a Binary to Gray Code Converter and Gray Code to Binary Converter using Verilog HDL.

## Files

- ``binary_gray_converter.v``
- ``binary_gray_converter_tb.v``
- ``binary_gray_converter.xdc``

## Description

``binary_gray_converter.v`` contains the Verilog module for both Binary to Gray Code conversion and Gray Code to Binary conversion. The design uses combinational logic to perform both conversions simultaneously. The Binary to Gray conversion is implemented using XOR operations while the Gray to Binary conversion is performed using successive XOR operations.

``binary_gray_converter_tb.v`` contains the testbench used to simulate and verify both conversion methods. The simulation applies multiple Binary and Gray code input combinations and verifies that the converted outputs match the expected values.

``binary_gray_converter.xdc`` contains the Xilinx Design Constraints (XDC) file that maps the Binary input switches and Binary to Gray output LEDs to the appropriate FPGA pins. It also specifies the LVCMOS33 I/O standard required for FPGA implementation.
