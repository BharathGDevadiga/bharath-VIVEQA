# Day 06 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a **Repeat Adder (149 Iterations)**.

## Files

- `repeat_adder_149.v`
- `tb_repeat_adder_149.v`

## Description

`repeat_adder_149.v` contains the Verilog module for a Repeat Adder that repeatedly adds an 8-bit input value to an accumulator using a feedback adder. The accumulator is initialized with the input during reset and an internal counter performs **149 additions**. When all additions are completed, the **done** signal is asserted.

`tb_repeat_adder_149.v` contains the testbench used to simulate and verify the functionality of the Repeat Adder by generating the clock, applying reset, providing input data and monitoring the accumulated output and completion signal.
