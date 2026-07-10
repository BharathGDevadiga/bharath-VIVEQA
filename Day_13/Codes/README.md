# Day 13 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a **Parallel-In Serial-Out (PISO) Shift Register** using Verilog HDL on the Basys 3 FPGA board.

## Files

- `PISO.v`
- `PISO_tb.v`
- `PISO.xdc`

## Description

`PISO.v` contains the Verilog module for a 4-bit Parallel-In Serial-Out (PISO) shift register. The parallel data is loaded into an internal register when the **load** signal is asserted. On every rising edge of the **shift** signal, one bit is transmitted serially through the `data_out` output.

`PISO_tb.v` contains the testbench used to simulate and verify the operation of the PISO shift register. The simulation loads parallel data into the register and verifies that the bits are shifted out serially in the correct sequence.

`PISO.xdc` contains the Xilinx Design Constraints (XDC) file that maps the clock, reset button, load button, shift button, slide switches (`data_in[3:0]`) and serial output LED (`data_out`) to the appropriate FPGA pins. It also specifies the **LVCMOS33** I/O standard required for FPGA implementation.
