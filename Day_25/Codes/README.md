# Day 25 - Verilog Codes

This folder contains the Verilog HDL programs for implementing an **8-Bit Barrel Shifter** using Verilog HDL on the FPGA board.

## Files

- ``barrel_shifter.v``
- ``barrel_shifter_tb.v``
- ``barrel_shifter.xdc``

## Description

``barrel_shifter.v`` contains the Verilog module for an 8-bit Barrel Shifter. The design performs logical left and logical right shift operations based on the direction control signal (`dir`). The amount of shift is selected using a 3-bit shift control input (`shift_amt`), allowing the input data to be shifted by 0 to 7 positions in a single operation.

``barrel_shifter_tb.v`` contains the testbench used to simulate and verify the Barrel Shifter. The simulation applies different input values, shift amounts and shift directions to verify both left and right shift operations. The testbench confirms that the output data matches the expected shifted value for every test case.

``barrel_shifter.xdc`` contains the Xilinx Design Constraints (XDC) file that maps the input data (`data_in[7:0]`), shift amount (`shift_amt[2:0]`), direction control (`dir`) and output data (`data_out[7:0]`) to the appropriate FPGA switches, push buttons and LEDs. It also specifies the **LVCMOS33** I/O standard required for FPGA implementation.
