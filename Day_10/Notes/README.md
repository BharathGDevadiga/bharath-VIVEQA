# Day 10 - Arithmetic Logic Unit (ALU)

## Introduction

An **Arithmetic Logic Unit (ALU)** is a combinational digital circuit that performs arithmetic and logical operations on binary data. It is one of the fundamental components of a processor and is widely used in digital systems.

In this design, two 4-bit operands (**A** and **B**) are provided through the FPGA slide switches, while sixteen keypad inputs are used to select different arithmetic and logical operations. The result of the selected operation is displayed on the LEDs.

---

# Circuit Components

The circuit consists of:

- Two 4-bit Operands (A and B)
- Combinational Logic
- Operation Selection Keys
- LED Output

---

# Inputs

- **push[7:4]** – Operand A (4-bit)
- **push[3:0]** – Operand B (4-bit)
- **key[15:0]** – Operation Select

---

# Outputs

- **led[7:0]** – ALU Result

---

# Working

The ALU continuously monitors the keypad inputs.

- Operand **A** is obtained from `push[7:4]`.
- Operand **B** is obtained from `push[3:0]`.
- When a keypad button is pressed, the corresponding arithmetic or logical operation is performed.
- The result is displayed on the LEDs.

Since the design is purely combinational, the output updates immediately whenever the operands or selected operation change.

---

# ALU Operations

| Key | Operation | Expression |
|-----|-----------|------------|
| key[0] | Addition | A + B |
| key[1] | Subtraction | A − B |
| key[2] | AND | A & B |
| key[3] | OR | A \| B |
| key[4] | Left Shift | A << B |
| key[5] | Right Shift | A >> B |
| key[6] | XOR | A ^ B |
| key[7] | NOT | ~A |
| key[8] | Multiplication | A × B |
| key[9] | NOR | ~(A \| B) |
| key[10] | NAND | ~(A & B) |
| key[11] | Left Shift by 2 | A << 2 |
| key[12] | Right Shift by 2 | A >> 2 |
| key[13] | XNOR | ~(A ^ B) |
| key[14] | Increment A | A + 1 |
| key[15] | Increment B | B + 1 |

---

# Example Operation

Assume

```
A = 8
B = 8
```

| Selected Operation | Result |
|--------------------|--------|
| Addition | 16 |
| Subtraction | 0 |
| AND | 8 |
| OR | 8 |
| XOR | 0 |
| NOT A | 247 (8-bit) |
| Multiplication | 64 |
| NOR | 247 |
| NAND | 255 |
| A << 2 | 32 |
| A >> 2 | 2 |
| XNOR | 255 |
| A + 1 | 9 |
| B + 1 | 9 |

---

# Operation Flow

### Step 1

Read operands from the slide switches.

```
A = push[7:4]
B = push[3:0]
```

---

### Step 2

Read the keypad input.

```
key[15:0]
```

---

### Step 3

Select the required arithmetic or logical operation.

---

### Step 4

Display the result on the LEDs.

```
led = Result
```

---

# Verilog Constructs Used

| Construct | Description |
|-----------|-------------|
| always @(*) | Creates combinational logic |
| if-else | Selects the required ALU operation |
| assign | Assigns operands A and B |
| Wire | Stores operand values |
| Reg | Stores ALU output |

---

# Applications

- Microprocessors
- Microcontrollers
- Digital Signal Processing
- FPGA-Based Systems
- Arithmetic Circuits
- Embedded Systems
- Computer Architecture

---

# Advantages

- Performs multiple operations using a single circuit.
- Simple combinational design.
- Fast operation with no clock required.
- Easy to implement on an FPGA.
- Supports both arithmetic and logical operations.

---

# Limitations

- Operates on only 4-bit operands.
- Produces 8-bit output only.
- Only one operation can be selected at a time.
- Shift operations depend on the value of operand B.

---

# Conclusion

An 8-bit Arithmetic Logic Unit (ALU) was designed using Verilog HDL to perform sixteen arithmetic and logical operations on two 4-bit operands. The operation is selected using keypad inputs, and the result is displayed on LEDs. This design demonstrates the implementation of combinational logic and serves as a fundamental building block for processors and digital systems.
