# Day 09 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a 16-to-4 Priority Encoder (Hexadecimal to Binary Converter).

## Files

- hex_to_binary.v
- tb_hex_to_binary.v
- hex_to_binary.xdc

## Description

**hex_to_binary.v** contains the Verilog module for a 16-to-4 encoder that converts a one-hot 16-bit input into its corresponding 4-bit binary output using a combinational case statement.

**tb_hex_to_binary.v** contains the testbench used to simulate and verify the functionality of the encoder by applying valid and invalid input combinations.

**hex_to_binary.xdc** contains the Xilinx Design Constraints (XDC) file that maps the FPGA input switches and output LEDs to the corresponding FPGA package pins and specifies the I/O standard (`LVCMOS33`) required for hardware implementation.
