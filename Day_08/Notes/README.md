# Day 08 - Edge Detector

## Introduction

An Edge Detector is a sequential digital circuit used to detect transitions in a digital signal. It identifies when an input signal changes from LOW to HIGH (positive edge), HIGH to LOW (negative edge) or either transition (both edges).

In this design, a **D Flip-Flop** stores the previous value of the input signal. The current input is compared with the previous value using combinational logic to generate the required edge detection outputs.

---

# Circuit Components

The circuit consists of:

- D Flip-Flop
- Combinational Logic
- Clock
- Reset

---

# Inputs

- **clk** – System clock
- **rst** – Asynchronous reset
- **sig** – Input signal to be monitored

---

# Outputs

- **pos_edge** – Detects a rising edge (0 → 1)
- **neg_edge** – Detects a falling edge (1 → 0)
- **both_edge** – Detects either a rising or falling edge

---

# Working

## Reset (rst = 1)

The D Flip-Flop is cleared.

```
q = 0
```

No edge is detected.

```
pos_edge = 0
neg_edge = 0
both_edge = 0
```

---

## Positive Edge Detection

The previous value of the signal is stored in the D Flip-Flop.

A positive edge occurs when

```
Previous Signal = 0
Current Signal = 1
```

Equation

```
pos_edge = sig & ~q
```

---

## Negative Edge Detection

A negative edge occurs when

```
Previous Signal = 1
Current Signal = 0
```

Equation

```
neg_edge = ~sig & q
```

---

## Both Edge Detection

Both-edge detection combines the positive and negative edge outputs.

Equation

```
both_edge = pos_edge | neg_edge
```

---

# Logic Equations

Positive Edge

```
pos_edge = sig · q'
```

Negative Edge

```
neg_edge = sig' · q
```

Both Edge

```
both_edge = pos_edge + neg_edge
```

---

# Truth Table

| Previous Signal (q) | Current Signal (sig) | Positive Edge | Negative Edge | Both Edge |
|---------------------|----------------------|---------------|---------------|-----------|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 | 1 |
| 1 | 1 | 0 | 0 | 0 |

---

# Operation Flow

### Step 1

Store the current input signal in the D Flip-Flop.

```
q <= sig
```

---

### Step 2

Compare the current signal with the previous signal.

---

### Step 3

If

```
0 → 1
```

Generate

```
pos_edge = 1
```

---

### Step 4

If

```
1 → 0
```

Generate

```
neg_edge = 1
```

---

### Step 5

Generate

```
both_edge = pos_edge | neg_edge
```

---

# Example Operation

Assume the input signal changes as

| Clock Cycle | Signal (sig) | Previous (q) | Positive Edge | Negative Edge | Both Edge |
|-------------|--------------|--------------|---------------|---------------|-----------|
| Reset | 0 | 0 | 0 | 0 | 0 |
| 1 | 1 | 0 | 1 | 0 | 1 |
| 2 | 1 | 1 | 0 | 0 | 0 |
| 3 | 0 | 1 | 0 | 1 | 1 |
| 4 | 0 | 0 | 0 | 0 | 0 |
| 5 | 1 | 0 | 1 | 0 | 1 |

---

# Register Description

| Register | Function |
|----------|----------|
| q | Stores the previous value of the input signal |

---

# Verilog Operators Used

| Operator | Symbol | Description |
|----------|--------|-------------|
| AND | & | Detects edge conditions |
| OR | \| | Combines positive and negative edge outputs |
| NOT | ~ | Generates complement of the stored signal |
| Non-blocking Assignment | <= | Updates the D Flip-Flop on the clock edge |

---

# Applications

- Pulse generation
- Digital communication systems
- Interrupt detection
- Finite State Machines (FSMs)
- Synchronizers
- Event detection circuits
- FPGA and ASIC designs

---

# Advantages

- Simple and efficient design.
- Uses only one D Flip-Flop.
- Detects rising, falling and both edges.
- Suitable for FPGA implementation.
- Easy to understand and verify.

---

# Limitations

- Detects edges only on clock events (synchronous operation).
- Very short pulses may be missed if they occur between clock edges.
- Requires a stable clock for reliable operation.

---

# Conclusion

An Edge Detector was designed using a D Flip-Flop and simple combinational logic in Verilog HDL. The previous value of the input signal is stored and compared with the current value to detect rising, falling and both edges. This design demonstrates the use of sequential logic for event detection and provides an efficient implementation suitable for FPGA-based digital systems.
