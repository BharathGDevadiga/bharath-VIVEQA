# Day 03 - 4-Bit Adder/Subtractor using Full Adders

## Introduction

A **4-Bit Adder/Subtractor** is a combinational logic circuit used to perform both **addition** and **subtraction** of two 4-bit binary numbers.

The circuit is built by connecting **four Full Adders** in series. A control signal **m** selects the required operation.
```text
- **m = 0** → Addition (`A + B`)
- **m = 1** → Subtraction (`A - B`) using the **2's complement** method
```
---

# Half Adder

A **Half Adder** adds two 1-bit binary numbers and produces a **Sum** and a **Carry**.

## Boolean Equations

```text
Sum   = A ^ B
Carry = A & B
```

## Truth Table

| A | B | Sum | Carry |
|:-:|:-:|:---:|:-----:|
| 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |

---

# Full Adder

A **Full Adder** adds three binary inputs.

### Inputs
```text
- A
- B
- Carry In (Cin)
```
### Outputs
```text
- Sum
- Carry Out (Carry)
```
A Full Adder is implemented using **two Half Adders** and **one OR gate**.

## Boolean Equations

```text
Sum   = A ^ B ^ Cin
Carry = (A & B) | (Cin & (A ^ B))
```

## Truth Table

| A | B | Cin | Sum | Carry |
|:-:|:-:|:---:|:---:|:-----:|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 | 0 |
| 0 | 1 | 0 | 1 | 0 |
| 0 | 1 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 | 0 |
| 1 | 0 | 1 | 0 | 1 |
| 1 | 1 | 0 | 0 | 1 |
| 1 | 1 | 1 | 1 | 1 |

---

# 4-Bit Adder/Subtractor

The circuit consists of **four Full Adders** connected in cascade.

The control signal **m** determines whether the circuit performs **addition** or **subtraction**.

## Operation Truth Table

| m | Operation | B Input | Initial Carry (Cin) | Output |
|:-:|-----------|---------|:-------------------:|--------|
| 0 | Addition | B | 0 | A + B |
| 1 | Subtraction | B is complemented (`~B`) | 1 | A - B |

---

# Working

### Addition (m = 0)
```text
- Input **B** is used directly.
- Initial Carry In = **0**.
- The circuit performs:
```
```text
A + B
```

### Subtraction (m = 1)
```text
- Every bit of **B** is inverted using XOR gates.
- Initial Carry In = **1**.
- The circuit performs:
```
```text
A + (~B + 1)
```

which is equivalent to

```text
A - B
```

using the **2's complement** method.

---

# Block Operation

### Step 1

Each bit of **B** is XORed with **m**.

```text
B' = B ^ m
```

If

```text
m = 0 → B' = B
m = 1 → B' = ~B
```

### Step 2

The first Full Adder receives

```text
Cin = m
```

### Step 3

Each Full Adder passes its Carry Out to the next Full Adder.

### Step 4

The final stage produces
```text
- 4-bit Sum
- Final Carry
```
---

# Example Truth Table

| A | B | m | Operation | Result | Carry |
|:----:|:----:|:-:|-----------|:------:|:-----:|
| 0101 | 0011 | 0 | 5 + 3 | 1000 | 0 |
| 1001 | 0110 | 0 | 9 + 6 | 1111 | 0 |
| 1111 | 0001 | 0 | 15 + 1 | 0000 | 1 |
| 0101 | 0011 | 1 | 5 - 3 | 0010 | 1 |
| 1000 | 0010 | 1 | 8 - 2 | 0110 | 1 |
| 0110 | 0110 | 1 | 6 - 6 | 0000 | 1 |
| 0011 | 0101 | 1 | 3 - 5 | 1110 | 0 |

---

# Verilog Operators Used

| Operator | Symbol | Description |
|-----------|--------|-------------|
| AND | `&` | Generates Carry |
| OR | `|` | Combines Carry outputs |
| XOR | `^` | Generates Sum and complements B |
| NOT | `~` | Produces 1's complement |

---

# Applications
```text
- Arithmetic Logic Unit (ALU)
- Binary Addition
- Binary Subtraction
- Ripple Carry Adder
- FPGA Design
- ASIC Design
- Embedded Systems
- Digital Electronics
```
---

# Advantages
```text
- Simple and modular design
- Uses the same hardware for addition and subtraction
- Easy to implement using Verilog HDL
- Suitable for FPGA implementation
- Easy to expand to 8-bit, 16-bit, or higher-bit adders
```
---

# Conclusion

A **4-Bit Adder/Subtractor** was designed using a hierarchical approach in Verilog HDL. A **Full Adder** was first constructed using two **Half Adders** and four Full Adders were connected to form the complete circuit. By using the control signal **m**, the same hardware performs both addition and subtraction through the **2's complement** method. Simulation results verified the correct operation of the design, making it suitable for FPGA-based digital systems.
