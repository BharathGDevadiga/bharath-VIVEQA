# Day 25 - Barrel Shifter

## Introduction

This project demonstrates the implementation of an **8-Bit Barrel Shifter** using Verilog HDL. A Barrel Shifter is a combinational logic circuit capable of shifting data by multiple bit positions in a single operation. The design supports both logical left and logical right shifts with a selectable shift amount from 0 to 7 bits.

This project introduces combinational logic variable shifting multiplexing techniques logical shift operations and FPGA implementation using Verilog HDL.

---

## Barrel Shifter

A Barrel Shifter shifts data by a specified number of bit positions in a single operation.

```verilog
always @(*) begin
    case(dir)
        1'b0: data_out = data_in << shift_amt;
        1'b1: data_out = data_in >> shift_amt;
    endcase
end
```

The circuit performs purely combinational operations.

The output changes immediately whenever the input data shift amount or direction changes.

---

## Input and Output Ports

```verilog
input [7:0] data_in;
input [2:0] shift_amt;
input dir;

output reg [7:0] data_out;
```

**data_in** – 8-bit input data

**shift_amt** – Number of bit positions to shift (0 to 7)

**dir** – Shift direction selection

**data_out** – Shifted output data

---

## Shift Operations

| Direction | Operation |
|-----------|-----------|
| dir = 0 | Logical Left Shift |
| dir = 1 | Logical Right Shift |

---

## Working Principle

Initially the Barrel Shifter continuously monitors the input signals.

If **dir = 0** the input data is shifted left by the selected number of bit positions.

If **dir = 1** the input data is shifted right by the selected number of bit positions.

The output updates immediately whenever any input changes.

---

## Combinational Logic

The Barrel Shifter is a combinational circuit.

The operation depends on:

- Input Data
- Shift Amount
- Shift Direction

No memory elements or flip-flops are used.

---

## FPGA Mapping

Typical FPGA connections:

- Slide Switches → Input Data
- Push Buttons → Shift Amount
- Push Button → Direction
- LEDs → Shifted Output

The switches provide the input data while the LEDs display the shifted output in real time.

---

## Simulation

The testbench verifies:

- Left Shift Operation
- Right Shift Operation
- Different Shift Amounts
- Multiple Input Data Values
- Correct Output Generation

The simulation confirms that the Barrel Shifter correctly performs logical left and right shift operations.

---

## Applications

- Arithmetic Logic Units (ALUs)
- Digital Signal Processing
- Processor Design
- Embedded Systems
- Data Manipulation
- FPGA Learning Projects

---

## Key Takeaways

- Learned the working principle of a Barrel Shifter.
- Implemented an 8-bit Barrel Shifter using Verilog HDL.
- Performed logical left and logical right shift operations.
- Implemented variable shift amounts using a 3-bit control input.
- Verified the design using a simulation testbench.
- Tested the design on an FPGA using switches and LEDs.
