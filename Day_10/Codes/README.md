# Day 10 - Verilog Codes

This folder contains the Verilog HDL programs for implementing an 8-bit Arithmetic Logic Unit (ALU) using combinational logic.

## Files

- alu.v
- alu_tb.v
- alu.xdc

## Description

**alu.v** contains the Verilog module for an 8-bit Arithmetic Logic Unit (ALU). Two 4-bit operands (`A` and `B`) are obtained from the slide switches and sixteen different arithmetic and logical operations are selected using the keypad inputs. The result of the selected operation is displayed on the LEDs.

**alu_tb.v** contains the testbench used to simulate and verify the functionality of the ALU by applying different keypad inputs and observing the corresponding arithmetic and logical operation results.

**alu.xdc** contains the Xilinx Design Constraints (XDC) file that maps the slide switches to the operand inputs (`push[7:0]`), the keypad buttons to the operation selection inputs (`key[15:0]`) and the LEDs to the ALU output (`led[7:0]`). It also specifies the `LVCMOS33` I/O standard required for FPGA implementation.
