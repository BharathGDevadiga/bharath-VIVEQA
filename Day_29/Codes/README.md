# Day 29 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a 4-bit Ring Counter using Verilog HDL on the FPGA board.

## Files

- ring_counter.v
- ring_counter_tb.v
- ring_counter.xdc

## Description

**ring_counter.v** contains the Verilog module for implementing a 4-bit Ring Counter. The design uses a shift register in which a single logic HIGH bit circulates through the four flip-flops. On every positive edge of the clock the HIGH bit shifts to the next position creating a continuous one-hot counting sequence.

**ring_counter_tb.v** contains the testbench used to simulate and verify the Ring Counter. The simulation applies reset generates the system clock and observes the counter output. The waveform verifies that the HIGH bit rotates correctly through all four output bits.

**ring_counter.xdc** contains the Xilinx Design Constraints (XDC) file that maps the system clock reset signal and counter outputs to the appropriate FPGA pins. It also specifies the LVCMOS33 I/O standard required for FPGA implementation.
