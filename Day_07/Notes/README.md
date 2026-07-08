# Day 07 - D, T and JK Flip-Flops using a Common D Flip-Flop

## Introduction

A Flip-Flop is a sequential logic circuit that stores one bit of information. It changes its output only on the triggering edge of the clock signal, making it the basic memory element in digital systems.

In this design, a single **D Flip-Flop** is used to implement three different types of flip-flops:

- D Flip-Flop
- T Flip-Flop
- JK Flip-Flop

A **3:1 Multiplexer** selects the desired flip-flop output using a 2-bit select input (`m`).

---

# Circuit Components

The circuit consists of:

- D Flip-Flop
- T Flip-Flop (implemented using D Flip-Flop)
- JK Flip-Flop (implemented using D Flip-Flop)
- 3:1 Multiplexer
- Clock
- Reset

---

# Inputs

- **clk** – System clock
- **reset** – Asynchronous reset
- **a** – Input D or J or T
- **b** – Input K (used only for JK Flip-Flop)
- **m[1:0]** – Flip-Flop selection

---

# Outputs

- **q** – Selected Flip-Flop output
- **qb** – Complement of the selected output

---

# Flip-Flop Selection

| m | Selected Flip-Flop |
|---|--------------------|
| 00 | D Flip-Flop |
| 01 | T Flip-Flop |
| 10 | JK Flip-Flop |
| 11 | Default Output |

---

# D Flip-Flop

## Characteristic Equation

```
Q(next) = D
```

## Truth Table

| D | Q(next) |
|---|----------|
| 0 | 0 |
| 1 | 1 |

### Example

Current Q = 0

If

```
D = 1
```

After the next positive clock edge,

```
Q = 1
```

---

# T Flip-Flop

A T Flip-Flop is implemented using a D Flip-Flop.

## Equation

```
D = T ⊕ Q
```

where

- T = a
- Q = Current Output

## Truth Table

| T | Current Q | Next Q |
|---|-----------|---------|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

### Example

Current Q = 0

```
T = 1
```

```
Next Q = 1
```

Next clock

Current Q = 1

```
T = 1
```

```
Next Q = 0
```

The output toggles whenever T = 1.

---

# JK Flip-Flop

The JK Flip-Flop is implemented using a D Flip-Flop.

## Characteristic Equation

```
D = JQ' + K'Q
```

where

- J = a
- K = b

## Truth Table

| J | K | Current Q | Next Q |
|---|---|-----------|---------|
| 0 | 0 | Q | Hold |
| 0 | 1 | X | 0 |
| 1 | 0 | X | 1 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 0 |

### Example

Current Q = 0

```
J = 1
K = 0
```

Next output

```
Q = 1
```

Current Q = 1

```
J = 1
K = 1
```

Next output

```
Q = 0
```

The output toggles when both J and K are HIGH.

---

# Working

## Reset (reset = 1)

All flip-flops are cleared.

```
Q = 0
QB = 1
```

---

## D Flip-Flop Mode (m = 00)

The input **a** is directly connected to the D Flip-Flop.

```
Q(next) = a
```

---

## T Flip-Flop Mode (m = 01)

The input **a** acts as the toggle input.

```
D = a ⊕ Q
```

When

```
a = 0
```

the output remains unchanged.

When

```
a = 1
```

the output toggles.

---

## JK Flip-Flop Mode (m = 10)

Inputs

```
a = J
b = K
```

The D input becomes

```
D = JQ' + K'Q
```

The JK Flip-Flop performs

- Hold
- Reset
- Set
- Toggle

depending on J and K.

---

# Multiplexer Operation

The outputs of all three flip-flops are connected to a 3:1 multiplexer.

| Select (m) | Output |
|-------------|---------|
| 00 | D Flip-Flop |
| 01 | T Flip-Flop |
| 10 | JK Flip-Flop |
| 11 | Default (Q=0, QB=1) |

---

# Example Operation

## D Flip-Flop

| Clock | D | Q |
|--------|---|---|
| Reset | X | 0 |
| 1 | 1 | 1 |
| 2 | 0 | 0 |
| 3 | 1 | 1 |

---

## T Flip-Flop

| Clock | T | Q |
|--------|---|---|
| Reset | X | 0 |
| 1 | 1 | 1 |
| 2 | 1 | 0 |
| 3 | 0 | 0 |
| 4 | 1 | 1 |

---

## JK Flip-Flop

| Clock | J | K | Q |
|--------|---|---|---|
| Reset | X | X | 0 |
| 1 | 1 | 0 | 1 |
| 2 | 0 | 0 | 1 |
| 3 | 0 | 1 | 0 |
| 4 | 1 | 1 | 1 |
| 5 | 1 | 1 | 0 |

---

# Verilog Operators Used

| Operator | Symbol | Description |
|----------|--------|-------------|
| XOR | ^ | Used for T Flip-Flop implementation |
| AND | & | Used in JK equation |
| OR | \| | Combines JK terms |
| NOT | ~ | Generates complement |
| Non-blocking Assignment | <= | Sequential register update |
| Case Statement | case | Selects the desired Flip-Flop |

---

# Applications

- Registers
- Counters
- Shift Registers
- Frequency Division
- State Machines
- Memory Elements
- FPGA Design
- ASIC Design
- Digital Systems

---

# Advantages

- Uses a common D Flip-Flop to implement multiple flip-flops.
- Modular and reusable design.
- Easy to understand.
- Hardware efficient.
- Suitable for FPGA implementation.
- Demonstrates sequential logic concepts.

---

# Limitations

- Requires additional combinational logic for T and JK implementations.
- Only one flip-flop output can be selected at a time.
- The default selection does not represent a valid flip-flop operation.

---

# Conclusion

A versatile flip-flop module was designed using a common D Flip-Flop to implement D, T and JK Flip-Flops in Verilog HDL. A 3:1 multiplexer selects the desired flip-flop output based on the control input. This design demonstrates how different sequential circuits can be realized from a single D Flip-Flop using combinational logic, making it an efficient and educational implementation for FPGA-based digital system design.
