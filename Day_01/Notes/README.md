# Day 01 - Logic Gates

## Introduction

Logic gates are the basic building blocks of digital electronics. They perform logical operations on one or more binary inputs (0 or 1) and produce a single binary output (0 or 1).

Logic gates are widely used in digital circuits such as computers, processors, memory devices, calculators, and FPGA-based systems.

---

# 1. AND Gate

The AND gate produces an output of **1 only when both inputs are 1**.

### Boolean Expression

```text
Y = A & B
```
### Truth Table

| A | B | Y |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

### Example

Think of two switches connected in series. The light turns ON only when **both switches are ON**.

---

# 2. OR Gate

The OR gate produces an output of **1 if at least one input is 1**.

### Boolean Expression

```text
Y = A | B
```

### Truth Table

| A | B | Y |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 1 |

### Example

A bell rings if **either one of two buttons** is pressed.

---

# 3. NOT Gate

The NOT gate reverses the input value.

- Input 0 becomes Output 1.
- Input 1 becomes Output 0.

### Boolean Expression

```text
Y = ~A
```

### Truth Table

| A | Y |
|---|---|
| 0 | 1 |
| 1 | 0 |

### Example

If a sensor detects no object (0), an indicator light turns ON (1).

---

# 4. NAND Gate

The NAND gate is the opposite of the AND gate. It produces **0 only when both inputs are 1**.

### Boolean Expression

```text
Y = ~(A & B)
```

### Truth Table

| A | B | Y |
|---|---|---|
| 0 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

### Note

NAND is called a **Universal Gate** because every other logic gate can be built using only NAND gates.

---

# 5. NOR Gate

The NOR gate is the opposite of the OR gate.

### Boolean Expression

```text
Y = ~(A | B)
```

### Truth Table

| A | B | Y |
|---|---|---|
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 0 |

### Note

NOR is also a **Universal Gate**.

---

# 6. XOR Gate

The XOR (Exclusive OR) gate produces an output of **1 only when the inputs are different**.

### Boolean Expression

```text
Y = A ^ B
```

### Truth Table

| A | B | Y |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

### Example

If two switches are in different positions, the light turns ON.

---

# 7. XNOR Gate

The XNOR gate produces an output of **1 when both inputs are equal**.

### Boolean Expression

```text
Y = ~(A ^ B)
```

### Truth Table

| A | B | Y |
|---|---|---|
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

### Example

The output is HIGH only when both inputs match.

---

# Applications of Logic Gates

- Arithmetic circuits (Adders and Subtractors)
- Memory devices
- Processors
- Digital control systems
- FPGA and ASIC design
- Embedded systems

---

## Verilog Operators

## Boolean Equations

```text
AND   : Y = A & B
OR    : Y = A | B
NOT   : Y = ~A
NAND  : Y = ~(A & B)
NOR   : Y = ~(A | B)
XOR   : Y = A ^ B
XNOR  : Y = ~(A ^ B)
```

---

# Summary

- AND → Output is 1 only if both inputs are 1.
- OR → Output is 1 if at least one input is 1.
- NOT → Reverses the input.
- NAND → Opposite of AND.
- NOR → Opposite of OR.
- XOR → Output is 1 when inputs are different.
- XNOR → Output is 1 when inputs are the same.

These logic gates are the foundation of digital electronics and are essential for learning Verilog and FPGA design.
