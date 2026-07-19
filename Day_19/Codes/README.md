# Day 19 - Single Port RAM

This folder contains the Verilog HDL programs for implementing a **Single Port RAM (Random Access Memory)**.

# Files
- `single_port_ram.v`
- `single_port_ram_tb.v`
- `top.v`
- `single_port_ram.xdc`

# Description

 `single_port_ram.v`
Contains the Verilog implementation of a **32-bit Single Port RAM** with **64 memory locations**. The RAM performs synchronous read and write operations using a single port. Data is written to the selected memory location when the write enable signal is high and read from the selected address when the write enable signal is low.

 `single_port_ram_tb.v`
Contains the testbench used to simulate and verify the functionality of the Single Port RAM. The simulation writes data to multiple memory locations and then reads the stored values back to verify correct memory operation.

 `top.v`
Contains the top-level module used for FPGA hardware implementation. It instantiates the Single Port RAM along with the **Virtual Input/Output (VIO)** and **Integrated Logic Analyzer (ILA)** IP cores. The VIO is used to provide the write enable, address and write data inputs during runtime, while the ILA is used to monitor the RAM signals in real time.

 `single_port_ram.xdc`
Contains the Xilinx Design Constraints (XDC) file that maps the **24 MHz system clock** to the FPGA clock pin and specifies the **LVCMOS33** I/O standard required for FPGA implementation.
