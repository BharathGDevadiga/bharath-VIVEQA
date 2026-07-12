# Day 15 - 4-Bit Asynchronous Up Counter

## Introduction

This project demonstrates a **4-Bit Asynchronous (Ripple) Up Counter** using **T Flip-Flops** in Verilog HDL. The counter increments its binary count from **0000 (0)** to **1111 (15)** and then repeats continuously. Unlike synchronous counters, each flip-flop is triggered by the output of the previous flip-flop, creating a ripple effect.

This project introduces sequential logic, flip-flops, ripple counters, and binary counting using Verilog HDL.

---

## T Flip-Flop

A **T (Toggle) Flip-Flop** changes its output state whenever the clock receives a positive edge and the **T input is HIGH**.

```verilog
always @(posedge clk) begin
    if (rst)
        Q <= 1'b0;
    else if (T)
        Q <= ~Q;
end
```

- Triggered on the positive edge of the clock.
- Reset initializes the output to **0**.
- When **T = 1**, the output toggles.
- Used as the basic building block of asynchronous counters.

---

## Input and Output Ports

```verilog
input clk;
input rst;
output [3:0] count;
```

- **clk** is the external clock input.
- **rst** resets the counter to **0000**.
- **count[3:0]** represents the 4-bit binary count displayed on the LEDs.

---

## Working Principle

Each T Flip-Flop has **T permanently connected to logic HIGH (1)**.

The first flip-flop receives the external clock.

Each subsequent flip-flop receives the inverted output (**Q̅**) of the previous flip-flop as its clock.

Clock

↓

FF0 toggles every clock pulse

↓

FF1 toggles whenever FF0 changes

↓

FF2 toggles whenever FF1 changes

↓

FF3 toggles whenever FF2 changes

This ripple action produces a binary up-count sequence.

---

## Counting Sequence

| Decimal | Binary |
|---------:|:------:|
| 0 | 0000 |
| 1 | 0001 |
| 2 | 0010 |
| 3 | 0011 |
| 4 | 0100 |
| 5 | 0101 |
| 6 | 0110 |
| 7 | 0111 |
| 8 | 1000 |
| 9 | 1001 |
| 10 | 1010 |
| 11 | 1011 |
| 12 | 1100 |
| 13 | 1101 |
| 14 | 1110 |
| 15 | 1111 |

After **1111**, the counter returns to **0000**.

---

## Why Asynchronous?

This is called an **Asynchronous Counter** because all flip-flops do **not** receive the same clock signal.

Instead:

- FF0 receives the external clock.
- FF1 receives the output of FF0.
- FF2 receives the output of FF1.
- FF3 receives the output of FF2.

Because each stage waits for the previous one, a small propagation delay (ripple delay) exists.

---

## Sequential Logic

Unlike combinational circuits, sequential circuits depend on both the current inputs and the previous output state.

The counter stores its current value using flip-flops and updates it on every clock pulse.

---

## FPGA Mapping

Typical Basys 3 connections:

CLK → 24 MHz Clock

BTN0 → Reset

LED0 → Count Bit 0

LED1 → Count Bit 1

LED2 → Count Bit 2

LED3 → Count Bit 3

---

## Simulation

The testbench verifies:

- Reset operation
- Continuous binary counting
- Proper ripple operation
- Counter rollover from **1111** to **0000**

The simulation confirms that the counter increments correctly on every clock pulse.

---

## Applications

- Digital Counters
- Frequency Division
- Event Counting
- Digital Clocks
- Sequence Generators
- Timing Circuits
- FPGA Learning Projects

---

## Key Takeaways

- Learned the working of a **T Flip-Flop**.
- Understood the concept of **Asynchronous (Ripple) Counters**.
- Implemented a **4-Bit Binary Up Counter** using Verilog HDL.
- Verified the design using a simulation testbench.
- Interfaced clock, reset button and LEDs on the FPGA board.
- Observed binary counting and ripple propagation between flip-flops.
