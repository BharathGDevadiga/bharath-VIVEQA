# Day 02 - Full Adder using Two Half Adders

## Introduction

A **Half Adder** is a combinational logic circuit that adds two binary inputs (**A** and **B**) and produces **Sum** and **Carry** as outputs. However, it cannot add a carry input from a previous stage.

A **Full Adder** is a combinational logic circuit that adds three binary inputs (**A**, **B**, and **Carry In (Cin)**) and produces **Sum** and **Carry Out (Cout)** as outputs.

A Full Adder can be implemented using **two Half Adders and one OR gate**, making the design simple, modular, and easy to understand.

---

# Half Adder

The Half Adder adds two binary inputs and generates a **Sum** and a **Carry**.

## Boolean Equations

```text
Sum   = A ^ B
Carry = A & B
```

## Truth Table

| A | B | Sum | Carry |
|---|---|-----|-------|
| 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |

### Example
```text
Adding 1 + 1 gives:

- Sum = 0
- Carry = 1
```
---

# Full Adder

The Full Adder adds three binary inputs (**A**, **B**, and **Cin**) and produces **Sum** and **Carry Out**.

Unlike a Half Adder, it can add the carry generated from the previous stage, making it suitable for multi-bit binary addition.

## Working

### Step 1

The first Half Adder adds **A** and **B**.

```text
Sum1   = A ^ B
Carry1 = A & B
```

### Step 2

The second Half Adder adds **Sum1** and **Cin**.

```text
Sum    = Sum1 ^ Cin
Carry2 = Sum1 & Cin
```

### Step 3

The Carry outputs from both Half Adders are combined using an OR gate.

```text
Carry = Carry1 | Carry2
```

---

## Boolean Equations

```text
Sum   = A ^ B ^ Cin
Carry = (A & B) | (Cin & (A ^ B))
```

---

## Truth Table

| A | B | Cin | Sum | Carry |
|---|---|-----|-----|-------|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 | 0 |
| 0 | 1 | 0 | 1 | 0 |
| 0 | 1 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 | 0 |
| 1 | 0 | 1 | 0 | 1 |
| 1 | 1 | 0 | 0 | 1 |
| 1 | 1 | 1 | 1 | 1 |

---

## Circuit Implementation

A Full Adder is implemented using:
```text
- Two Half Adders
- One OR Gate
```
The first Half Adder generates an intermediate Sum (**Sum1**) and **Carry1**.

The second Half Adder adds **Sum1** with **Cin** to generate the final **Sum** and **Carry2**.

Finally, the OR gate combines **Carry1** and **Carry2** to produce the final **Carry Out**.

---

## Verilog Operators

```text
AND : &
OR  : |
XOR : ^
```

---

## Applications
```text
- Arithmetic Logic Unit (ALU)
- Binary Adders
- Ripple Carry Adders
- Digital Computers
- FPGA Design
- ASIC Design
- Embedded Systems
```
---

## Conclusion

The **Full Adder using Two Half Adders** was successfully designed and simulated using Verilog HDL. The simulation results verified that the generated **Sum** and **Carry Out** matched the expected truth table. This design demonstrates hierarchical design by reusing Half Adder modules to build a more complex digital circuit.
