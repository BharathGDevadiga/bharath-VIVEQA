# Day 17 - Vending Machine (Finite State Machine)

This folder contains the Verilog HDL programs for implementing a **Vending Machine Controller** using a **Finite State Machine (FSM)**.

## Files
- `vending_machine.v`
- `vending_machine_tb.v`
- `vending_machine.xdc`

## Description

`vending_machine.v`
Contains the Verilog implementation of a Moore Finite State Machine (FSM) for a vending machine controller. The machine accepts two coin inputs (`₹5` and `₹10`), tracks the total amount using multiple states, dispenses the product when the required amount is reached, and returns change whenever excess money is inserted. After dispensing, the FSM automatically returns to the initial state to begin the next transaction.

`vending_machine_tb.v`
Contains the testbench used to simulate and verify the functionality of the vending machine controller. The simulation applies reset and different combinations of coin inputs to verify correct state transitions, product dispensing, and change generation.

`vending_machine.xdc`
Contains the Xilinx Design Constraints (XDC) file that maps the **24 MHz system clock**, **reset push button**, **coin input switches**, **dispense output LED** and **change output LED** to the FPGA pins. It also specifies the **LVCMOS33** I/O standard required for FPGA implementation.
