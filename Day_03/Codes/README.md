# Day 03 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a **4-Bit Adder/Subtractor using Full Adders**.

## Files

- half_adder.v
- full_adder.v
- adder_subtractor_4bit.v
- tb_adder_subtractor_4bit.v

## Description

- **half_adder.v** contains the Verilog module for the Half Adder.
- **full_adder.v** contains the Verilog module for the Full Adder, implemented using two Half Adders.
- **adder_subtractor_4bit.v** implements a 4-Bit Adder/Subtractor using four Full Adders. The control signal **m** selects the operation:
  - **m = 0** → Addition
  - **m = 1** → Subtraction
- **tb_adder_subtractor_4bit.v** contains the testbench used to simulate and verify the functionality of the 4-Bit Adder/Subtractor.
