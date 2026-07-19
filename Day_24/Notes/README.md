# Day 24 - Universal Shift Register

## Introduction

This project demonstrates the implementation of a **Universal Shift Register** using Verilog HDL. A Universal Shift Register is a versatile sequential circuit capable of performing multiple operations including Hold Shift Left Shift Right and Parallel Load. The operation is selected using a 2-bit control signal while all operations are synchronized with the system clock.

This project introduces shift register design sequential logic data movement parallel loading serial shifting and FPGA implementation using Verilog HDL.

## Universal Shift Register

A Universal Shift Register supports four operating modes.

```verilog
00 → Hold
01 → Shift Right
10 → Shift Left
11 → Parallel Load
```

The register updates only on the positive edge of the clock.

## Input and Output Ports

```verilog
input clk;
input rst;
input [1:0] mode;
input serial_left;
input serial_right;
input [3:0] parallel_in;

output reg [3:0] q;
```

**clk** – System Clock

**rst** – Active HIGH Reset Signal

**mode** – Operation Select

**serial_left** – Serial Input for Left Shift

**serial_right** – Serial Input for Right Shift

**parallel_in** – Parallel Data Input

**q** – Register Output

## Working Principle

Initially the register waits for the positive edge of the clock.

If `rst = 1` the register clears all bits.

Depending on the mode selection the register performs one of the following operations:

- Hold
- Shift Right
- Shift Left
- Parallel Load

## Mode Selection

| Mode | Operation |
|------|-----------|
| 00 | Hold |
| 01 | Shift Right |
| 10 | Shift Left |
| 11 | Parallel Load |

## Sequential Logic

The Universal Shift Register is a sequential circuit.

The operation depends on:

- System Clock
- Reset
- Mode Selection
- Serial Inputs
- Parallel Inputs

## FPGA Mapping

Typical FPGA connections:

- 24 MHz Clock → clk
- Push Button → rst
- Slide Switches → mode
- Slide Switches → serial_left
- Slide Switches → serial_right
- Slide Switches → parallel_in
- LEDs → q

The LEDs display the current register contents while the switches control the operating mode and input data.

## Simulation

The testbench verifies:

- Reset Operation
- Hold Mode
- Shift Right
- Shift Left
- Parallel Load
- Register Output

The simulation confirms that the Universal Shift Register correctly performs all four operations.

## Applications

- Serial Communication
- Data Storage
- Data Transfer
- Digital Systems
- Embedded Systems
- FPGA Learning Projects

## Key Takeaways

- Learned the fundamentals of Universal Shift Registers.
- Implemented Hold Shift Left Shift Right and Parallel Load operations.
- Understood sequential data movement.
- Verified the design using a simulation testbench.
- Tested the design on an FPGA using switches and LEDs.
