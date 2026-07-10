# Day 14 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a **3-bit Up Counter** using Verilog HDL on the Basys 3 FPGA board.

## Files

- `up_counter_3bit.v`
- `tb_up_counter_3bit.v`
- `up_counter_3bit.xdc`

## Description

`up_counter_3bit.v` contains the Verilog module for a 3-bit synchronous up counter with an asynchronous reset. On every rising edge of the clock, the counter increments by one. When the reset signal is asserted, the counter is immediately cleared to `000`.

`tb_up_counter_3bit.v` contains the testbench used to simulate and verify the operation of the 3-bit up counter. The simulation applies a reset pulse and then allows the counter to increment continuously with each clock cycle while monitoring the count output.

`up_counter_3bit.xdc` contains the Xilinx Design Constraints (XDC) file that maps the system clock, reset button and the three counter output bits to the FPGA pins. It also specifies the **LVCMOS33** I/O standard required for FPGA implementation.
