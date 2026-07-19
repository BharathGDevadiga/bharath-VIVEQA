# Day 23 - Parameterized Counter

## Introduction

This project demonstrates the implementation of a **Parameterized Counter** using Verilog HDL. The counter increments on every positive edge of the clock when the enable signal is HIGH. The width of the counter is configurable using a Verilog parameter allowing the same design to be reused for different counter sizes without modifying the core logic.

This project introduces parameterized module design synchronous sequential logic reusable hardware implementation and FPGA implementation using Verilog HDL.

## Parameterized Counter

A parameterized counter allows the counter width to be changed by modifying a single parameter.

```verilog
parameter WIDTH = 8;

always @(posedge clk) begin
    if (rst)
        count <= 0;
    else if (en)
        count <= count + 1;
end
```

Triggered on the positive edge of the clock.

The counter resets when `rst` is HIGH.

The counter increments when `en` is HIGH.

The counter holds its current value when `en` is LOW.

## Parameter Declaration

The counter width is controlled using a Verilog parameter.

```verilog
parameter WIDTH = 8;
```

Changing the parameter automatically changes the size of the counter.

For example:

- WIDTH = 4 → 4-bit Counter
- WIDTH = 8 → 8-bit Counter
- WIDTH = 16 → 16-bit Counter

No changes to the internal logic are required.

## Input and Output Ports

```verilog
input clk;
input rst;
input en;

output reg [WIDTH-1:0] count;
```

**clk** – System Clock

**rst** – Active HIGH Reset Signal

**en** – Counter Enable Signal

**count** – Counter Output

## Working Principle

Initially the counter waits for the positive edge of the clock.

If `rst = 1` the counter resets to zero.

If `rst = 0` and `en = 1` the counter increments by one on every clock cycle.

If `en = 0` the counter retains its previous value.

The counter automatically wraps around after reaching its maximum value.

## Sequential Logic

The Parameterized Counter is a sequential circuit.

The counter updates only on the positive edge of the clock.

The operation depends on:

- System Clock
- Reset
- Enable Signal
- Counter Width Parameter

## FPGA Mapping

Typical FPGA connections:

- 24 MHz Clock → clk
- Push Button → rst
- Push Button → en
- LEDs → count[7:0]

The push buttons control the reset and enable operations while the LEDs display the current counter value in binary.

## Simulation

The testbench verifies:

- Clock Generation
- Reset Operation
- Counter Increment
- Enable Functionality
- Counter Hold Operation
- Counter Wrap-Around
- Parameterized Counter Operation

The simulation confirms that the counter increments correctly when enabled holds its value when disabled and resets correctly when the reset signal is asserted.

## Applications

- Event Counters
- Digital Timers
- Frequency Division
- Address Generation
- Embedded Systems
- FPGA Learning Projects

## Key Takeaways

- Learned parameterized module design using Verilog HDL.
- Understood reusable hardware design using parameters.
- Implemented a configurable synchronous counter.
- Controlled the counter using reset and enable signals.
- Verified the design using a simulation testbench.
- Tested the design on an FPGA using push buttons and LEDs.
