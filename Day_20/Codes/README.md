# Day 20 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a 16×8 First-In First-Out (FIFO) Memory using Verilog HDL on the FPGA board.

## Files
- `fifo.v`
- `fifo_tb.v`
- `fifo.xdc`

## Description

`fifo.v` contains the Verilog module for a 16×8 FIFO memory. The design uses separate read and write pointers to store and retrieve data in a First-In First-Out manner. It includes Full and Empty status detection logic along with rising-edge detectors for the write enable (`wr_en`) and read enable (`rd_en`) signals to ensure that each button press performs only one write or read operation. The design also supports on-chip debugging using the Integrated Logic Analyzer (ILA).

`fifo_tb.v` contains the testbench used to simulate and verify the FIFO operation. The simulation applies reset, performs multiple write operations to store data into the FIFO and then performs read operations to verify that the data is retrieved in the same order in which it was written. The testbench also verifies the movement of the read and write pointers during FIFO operations.

`fifo.xdc` contains the Xilinx Design Constraints (XDC) file that maps the system clock, reset button, write enable button, read enable button, slide switches (`write_data[7:0]`) and LEDs (`read_data[7:0]`) to the appropriate FPGA pins. It also specifies the LVCMOS33 I/O standard required for FPGA implementation.
