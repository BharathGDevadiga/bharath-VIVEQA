# Day 09 - 16-to-4 Priority Encoder (Hexadecimal to Binary Converter)

## Introduction

A **16-to-4 Priority Encoder** is a combinational logic circuit that converts a 16-bit one-hot input into its corresponding 4-bit binary output. It reduces the number of output lines required to represent one of sixteen input signals.

In this design, a **16-bit one-hot hexadecimal input** is converted into a **4-bit binary value** using a combinational `case` statement. Each valid input corresponds to one binary output, while invalid inputs produce a default output of `0000`.

---

# Circuit Components

The circuit consists of:

- 16-bit Input Bus
- Combinational Logic (Case Statement)
- 4-bit Binary Output

---

# Inputs

- **hex[15:0]** – 16-bit one-hot hexadecimal input

---

# Outputs

- **bin[3:0]** – 4-bit binary output

---

# Working

The encoder continuously monitors the 16-bit input.

- If exactly one input bit is HIGH, the corresponding binary value is generated.
- If none or multiple input bits are HIGH, the output defaults to `0000`.

The design is purely combinational, so the output changes immediately whenever the input changes.

---

# Truth Table

| Hex Input | Binary Output |
|-----------|---------------|
| 0000 0000 0000 0001 | 0000 |
| 0000 0000 0000 0010 | 0001 |
| 0000 0000 0000 0100 | 0010 |
| 0000 0000 0000 1000 | 0011 |
| 0000 0000 0001 0000 | 0100 |
| 0000 0000 0010 0000 | 0101 |
| 0000 0000 0100 0000 | 0110 |
| 0000 0000 1000 0000 | 0111 |
| 0000 0001 0000 0000 | 1000 |
| 0000 0010 0000 0000 | 1001 |
| 0000 0100 0000 0000 | 1010 |
| 0000 1000 0000 0000 | 1011 |
| 0001 0000 0000 0000 | 1100 |
| 0010 0000 0000 0000 | 1101 |
| 0100 0000 0000 0000 | 1110 |
| 1000 0000 0000 0000 | 1111 |

---

# Operation Flow

### Step 1

Read the 16-bit input.

```
hex[15:0]
```

---

### Step 2

Compare the input with all valid one-hot patterns using the `case` statement.

---

### Step 3

If a valid input is detected,

```
bin = corresponding binary value
```

---

### Step 4

If the input is invalid,

```
bin = 0000
```

---

# Example Operation

Assume

```
hex = 0000 0000 0010 0000
```

Output

```
bin = 0101
```

Another example

```
hex = 0001 0000 0000 0000
```

Output

```
bin = 1100
```

Invalid input

```
hex = 0000 0000 0000 0011
```

Output

```
bin = 0000
```

---

# Verilog Constructs Used

| Construct | Description |
|-----------|-------------|
| always @(*) | Creates combinational logic |
| case | Selects the corresponding binary value |
| default | Handles invalid input combinations |
| reg | Stores the output value |

---

# Applications

- Priority Encoders
- Keyboard Encoding
- Interrupt Controllers
- Digital Communication Systems
- FPGA and ASIC Designs
- Digital Logic Circuits

---

# Advantages

- Simple combinational design.
- Fast operation without a clock.
- Easy to implement using a `case` statement.
- Efficient conversion from one-hot input to binary output.
- Suitable for FPGA implementation.

---

# Limitations

- Works correctly only for one-hot input patterns.
- Invalid or multiple active inputs produce the default output.
- Does not provide priority handling for multiple active inputs.

---

# Conclusion

A 16-to-4 Priority Encoder was designed in Verilog HDL using a combinational `case` statement. The circuit converts a valid one-hot 16-bit hexadecimal input into its equivalent 4-bit binary output. The design is simple, efficient and suitable for FPGA implementation, demonstrating the use of combinational logic for digital encoding applications.
