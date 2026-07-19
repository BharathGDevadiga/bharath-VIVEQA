# Day 22 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a **MAX7219 4-Digit Seven-Segment Display Up Counter using SPI Communication** on the FPGA board.

## Files

- `seg_upcounter.v`
- `seg_upcounter_tb.v`
- `seg_upcounter.xdc`

## Description

`seg_upcounter.v` contains the complete Verilog design for the MAX7219-based seven-segment display up counter. It includes a clock divider that generates a 1 MHz SPI clock from the 24 MHz system clock, a 4-digit decimal up counter that increments every 0.5 second, decimal digit extraction logic and a Finite State Machine (FSM) that initializes the MAX7219 display driver and transmits digit data using the SPI protocol. The design continuously updates the display with the current count from **0000** to **9999** after which the counter automatically rolls over to **0000**.

`seg_upcounter_tb.v` contains the testbench used to simulate and verify the complete design. The testbench generates a 24 MHz system clock, instantiates the up counter module and runs the simulation to observe the SPI communication signals (`seg_cs`, `seg_clk` and `seg_din`). The simulation verifies the correct operation of the SPI state machine, the MAX7219 initialization sequence and serial data transmission to the seven-segment display.

`seg_upcounter.xdc` contains the Xilinx Design Constraints (XDC) file that maps the 24 MHz system clock and the SPI interface signals (`seg_cs`, `seg_clk` and `seg_din`) to the appropriate FPGA pins. It also specifies the **LVCMOS33** I/O standard required for FPGA implementation with the MAX7219 seven-segment display module.
