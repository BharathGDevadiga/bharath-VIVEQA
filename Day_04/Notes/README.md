# Day 04 - Flip-Flops using Verilog HDL

## Introduction

A **Flip-Flop** is a sequential logic circuit that stores **one bit of data**. Unlike combinational circuits, the output of a flip-flop depends on both the **current inputs** and the **previous state**. Flip-flops are triggered by a clock signal and are widely used in digital systems for data storage and synchronization.

This project implements the following flip-flops using Verilog HDL:

- D Flip-Flop
- T Flip-Flop
- JK Flip-Flop
- SR Flip-Flop

---

## Clock Signal

A **clock signal** controls when a flip-flop updates its output. The output changes only at a specific edge of the clock signal.

There are two types of edge triggering:

### Positive Edge Triggered (`posedge`)

- The output changes when the clock transitions from **0 to 1** (rising edge).
- This project uses **positive edge triggering**.

### Negative Edge Triggered (`negedge`)

- The output changes when the clock transitions from **1 to 0** (falling edge).

**Note:** All the flip-flops in this project are **positive edge-triggered**, so the output changes only on the **rising edge** of the clock.
---

# D Flip-Flop

A **D (Data) Flip-Flop** stores the value present at the input **D** on the rising edge of the clock.

## Boolean Equation

```text
Q(next) = D
```

## Truth Table

| Clock | D | Q(next) |
|:-----:|:-:|:-------:|
| ↑ | 0 | 0 |
| ↑ | 1 | 1 |

## Working

- When the clock rises, the output becomes equal to **D**.
- It is commonly used in registers and memory circuits.

## Example

```text
Initial Q = 0

Clock ↑
D = 1

Q = 1
```

---

# T Flip-Flop

A **T (Toggle) Flip-Flop** changes its output only when **T = 1**.

## Truth Table

| Clock | T | Q(next) | Operation |
|:-----:|:-:|:-------:|-----------|
| ↑ | 0 | Q | Hold |
| ↑ | 1 | ~Q | Toggle |

## Working

- **T = 0** → Output remains unchanged.
- **T = 1** → Output toggles on every rising edge.

## Example

```text
Initial Q = 0

Clock ↑
T = 1

Q = 1

Clock ↑
T = 1

Q = 0
```

---

# JK Flip-Flop

A **JK Flip-Flop** eliminates the invalid state found in the SR Flip-Flop.

## Truth Table

| Clock | J | K | Q(next) | Operation |
|:-----:|:-:|:-:|:-------:|-----------|
| ↑ | 0 | 0 | Q | Hold |
| ↑ | 0 | 1 | 0 | Reset |
| ↑ | 1 | 0 | 1 | Set |
| ↑ | 1 | 1 | ~Q | Toggle |

## Working

- **J = 0, K = 0** → Hold
- **J = 0, K = 1** → Reset
- **J = 1, K = 0** → Set
- **J = 1, K = 1** → Toggle

## Example

```text
Initial Q = 0

Clock ↑
J = 1
K = 0

Q = 1

Clock ↑
J = 1
K = 1

Q = 0
```

---

# SR Flip-Flop

An **SR (Set-Reset) Flip-Flop** stores one bit using **Set (S)** and **Reset (R)** inputs.

## Truth Table

| Clock | S | R | Q(next) | Operation |
|:-----:|:-:|:-:|:-------:|-----------|
| ↑ | 0 | 0 | Q | Hold |
| ↑ | 0 | 1 | 0 | Reset |
| ↑ | 1 | 0 | 1 | Set |
| ↑ | 1 | 1 | Invalid | Invalid State |

## Working

- **S = 0, R = 0** → Hold
- **S = 0, R = 1** → Reset
- **S = 1, R = 0** → Set
- **S = 1, R = 1** → Invalid State

## Example

```text
Initial Q = 0

Clock ↑
S = 1
R = 0

Q = 1

Clock ↑
S = 0
R = 1

Q = 0
```

---

# Verilog Keywords Used

| Keyword | Purpose |
|----------|---------|
| `module` | Defines a module |
| `input` | Declares input ports |
| `output` | Declares output ports |
| `reg` | Stores values inside an always block |
| `wire` | Connects modules and signals |
| `always` | Describes sequential logic |
| `posedge` | Detects the rising edge of the clock |
| `case` | Implements multiple conditions |
| `assign` | Continuous assignment |

---

# Applications

- Data Storage
- Registers
- Counters
- Shift Registers
- Memory Devices
- Finite State Machines (FSM)
- FPGA Design
- ASIC Design

---

# Advantages

- Stores one bit of information.
- Triggered by a clock signal.
- Simple and reliable sequential circuit.
- Forms the basic building block of digital memory.

---

# Conclusion

In this project, the **D, T, JK, and SR Flip-Flops** were implemented using Verilog HDL. Each flip-flop was simulated using a separate testbench to verify its operation. The simulation results confirmed the correct behavior of all four flip-flops, demonstrating the fundamental concepts of sequential logic and clock-driven digital systems.
