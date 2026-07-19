# Day 21 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a **Parameterized 16×8 First-In First-Out (FIFO) Memory** with an **Edge Detector** on the FPGA board.

## Files

- ``top_fifo.v``
- ``top_fifo_tb.v``
- ``top_fifo.xdc``

## Description

``top_fifo.v`` contains the complete Verilog design for the Parameterized FIFO system. It includes the **fifo_parameterized** module, which implements a configurable 16×8 FIFO memory using parameters for data width, memory depth and pointer width, and the **edge_detector** module, which generates single-clock pulses from the write enable (`wr_en`) and read enable (`rd_en`) push button inputs. The top module integrates these submodules and interfaces the FPGA slide switches (`sw[7:0]`) with the FIFO input and the LEDs (`led[7:0]`) with the FIFO output, making the design suitable for FPGA implementation.

``top_fifo_tb.v`` contains the testbench used to simulate and verify the complete FIFO system. The simulation applies reset, performs multiple write operations to store data into the FIFO and then performs multiple read operations to verify that the data is retrieved in the same order in which it was written. The testbench also verifies the correct operation of the integrated FIFO and Edge Detector modules.

``top_fifo.xdc`` contains the Xilinx Design Constraints (XDC) file that maps the system clock, reset button, write enable button, read enable button, slide switches (`sw[7:0]`) and LEDs (`led[7:0]`) to the appropriate FPGA pins. It also specifies the LVCMOS33 I/O standard required for FPGA implementation.
