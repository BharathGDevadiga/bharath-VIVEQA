# Day 14 - 3-Bit Up Counter

## Introduction

This project demonstrates the implementation of a **3-Bit Up Counter** using Verilog HDL on the FPGA development board. The counter increments its value on every rising edge of the clock signal and automatically wraps around after reaching its maximum count (`111`). An asynchronous reset is provided to clear the counter at any time.

This project introduces the fundamentals of **sequential logic**, **binary counting**, and **clock-driven digital circuits**.

---

## Counter

A counter is a sequential logic circuit that counts the number of clock pulses applied to its input.

An **Up Counter**:

- Increments its value by one on every clock pulse.
- Stores the current count in flip-flops.
- Repeats the counting sequence after reaching its maximum value.

---

## Input and Output Ports

```verilog
input clk;
input rst;

output reg [2:0] count;
```

- `clk` – System clock.
- `rst` – Asynchronous reset signal.
- `count[2:0]` – 3-bit counter output displayed on the LEDs.

---

## Working Principle

Initially,

```
Count = 000
```

On every rising edge of the clock,

```
000

↓

001

↓

010

↓

011

↓

100

↓

101

↓

110

↓

111

↓

000
```

The counter continuously repeats this sequence.

If the **reset** button is pressed,

```
Count

↓

000
```

The counter immediately returns to zero regardless of the clock.

---

## Asynchronous Reset

The counter uses an **asynchronous reset**.

```verilog
always @(posedge clk or posedge rst)
```

Whenever `rst = 1`,

```verilog
count <= 3'b000;
```

The reset does not wait for the next clock edge.

---

## Truth Table

| Reset (`rst`) | Clock Edge | Counter Output (`count`) |
|:-------------:|:----------:|:------------------------:|
| 1 | X | 000 |
| 0 | ↑ | Previous Count + 1 |
| 0 | No Edge | No Change |

**Note:** `↑` represents the rising edge of the clock signal.

---

## Counting Sequence

| Clock Pulse | Counter Output | Decimal |
|:-----------:|:--------------:|:-------:|
| Reset | 000 | 0 |
| 1 | 001 | 1 |
| 2 | 010 | 2 |
| 3 | 011 | 3 |
| 4 | 100 | 4 |
| 5 | 101 | 5 |
| 6 | 110 | 6 |
| 7 | 111 | 7 |
| 8 | 000 | 0 |

---

## Why a Clock?

A counter is a **sequential circuit** because it stores its previous state.

It contains:

- Flip-flops
- Memory elements
- Sequential state transitions

Therefore, a clock signal is required to synchronize the counting operation.

---

## Sequential Logic

Unlike combinational circuits, the output of a counter depends on:

- Current clock edge
- Previous count value

Hence, the counter is a **sequential logic circuit**.

---

## FPGA Mapping

Typical FPGA connections:

- Clock → 24 MHz Oscillator
- Reset Button → `rst`
- LED0 → `count[0]`
- LED1 → `count[1]`
- LED2 → `count[2]`

The LEDs display the binary count in real time.

---

## Simulation

The testbench verifies the following operations:

- Applying reset
- Releasing reset
- Counting on each clock pulse
- Overflow from `111` back to `000`

The simulation confirms that the counter increments correctly and resets properly.

---

## Applications

- Digital clocks
- Frequency dividers
- Event counters
- Timer circuits
- Digital measurement systems
- FPGA learning projects

---

## Advantages

- Simple hardware implementation
- Easy to expand to higher-bit counters
- Reliable synchronous counting
- Widely used in digital systems

---

## Key Takeaways

- Learned the working of a 3-bit Up Counter.
- Understood asynchronous reset operation.
- Implemented sequential logic using Verilog HDL.
- Learned binary counting using flip-flops.
- Verified the design through simulation and FPGA hardware implementation.
- Observed counter overflow from `111` back to `000`.
