# Day 29 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a 24-Hour Digital Clock using Verilog HDL on the FPGA board.

## Files

- ``digital_clock.v``

- ``digital_clock_tb.v``

- ``digital_clock.xdc``

## Description

- ``digital_clock.v`` contains the Verilog module for implementing a 24-Hour Digital Clock. The design generates a one-second pulse from the 24 MHz system clock and maintains seconds minutes and hours counters. The current time is converted into decimal digits and transmitted to the MAX7219 display driver through the SPI interface to display the time in HH:MM format.

- ``digital_clock_tb.v`` contains the testbench used to simulate and verify the Digital Clock. The simulation generates the 24 MHz input clock verifies the one-second pulse generation checks the seconds minutes and hours counters and confirms the correct SPI communication with the MAX7219 display.

- ``digital_clock.xdc`` contains the Xilinx Design Constraints (XDC) file that maps the 24 MHz system clock and the MAX7219 SPI interface signals including DIN CLK and LOAD to the appropriate FPGA pins. It also specifies the LVCMOS33 I/O standard required for FPGA implementation.
