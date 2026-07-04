# Day 06 - Repeat Adder (149 Iterations)

## Introduction

A Repeat Adder is a sequential digital circuit used to repeatedly add the same input value over multiple clock cycles. Instead of using a hardware multiplier, the circuit performs repeated addition using a feedback accumulator.

In this design, an 8-bit input is loaded into the output register during reset. The input is then added to the accumulated value **149 times**. An internal counter keeps track of the number of additions, and a **done** signal indicates when the operation is complete.

---

## Circuit Components

The circuit consists of:

- Feedback Adder
- 8-bit Accumulator Register
- 8-bit Counter
- Clock
- Reset
- Done Signal

---

## Inputs

- **clk** – System clock
- **rst** – Asynchronous reset
- **in_data [7:0]** – 8-bit input data

## Outputs

- **out_data [7:0]** – Accumulated output
- **done** – Indicates completion of the operation

---

## Working

### Reset (rst = 1)

- The accumulator is initialized with **in_data**.
- The counter is reset to **0**.
- The **done** signal is cleared.

### Addition (rst = 0)

On every positive edge of the clock,

- The current value of **out_data** is added with **in_data**.
- The result is stored back into **out_data**.
- The counter increments by **1**.

The process continues until the counter reaches **149**.

### Completion

When

```
count = 149
```

- The additions stop.
- The **done** signal becomes **1**.

---

## Operation Flow

### Step 1

Initialize the circuit during reset.

```
out_data = in_data
count = 0
done = 0
```

### Step 2

Perform repeated addition.

```
out_data = out_data + in_data
```

### Step 3

Increment the counter.

```
count = count + 1
```

### Step 4

When **149 additions** are completed,

```
done = 1
```

---

## Example Operation

Assume

```
in_data = 8
```

| Clock Cycle | Count | out_data |
|-------------|------:|---------:|
| Reset | 0 | 8 |
| 1 | 1 | 16 |
| 2 | 2 | 24 |
| 3 | 3 | 32 |
| ... | ... | ... |
| 30 | 30 | 248 |
| 31 | 31 | 0 *(Overflow)* |
| 32 | 32 | 8 |
| ... | ... | ... |

Since **out_data** is an **8-bit register**, it stores values only from **0 to 255**.

Whenever the accumulated value exceeds **255**, it overflows and wraps around to **0**.

---

## Register Description

| Register | Function |
|----------|----------|
| **out_data** | Stores the accumulated result |
| **count** | Counts the number of additions |
| **done** | Indicates completion of the operation |

---

## Verilog Operators Used

| Operator | Symbol | Description |
|----------|--------|-------------|
| Addition | `+` | Adds the input value to the accumulated result |
| Less Than | `<` | Checks whether 149 additions are completed |
| Non-blocking Assignment | `<=` | Updates sequential registers |

---

## Applications

- Sequential arithmetic circuits
- Repeated-addition multiplication
- FPGA Design
- ASIC Design
- Digital Signal Processing
- Educational Verilog projects

---

## Advantages

- Simple sequential design
- Uses only one adder through feedback
- Requires minimal hardware
- Easy to understand and implement
- Suitable for FPGA implementation

---

## Limitations

- Requires multiple clock cycles to complete the operation.
- Slower than a dedicated hardware multiplier.
- Limited by the width of the accumulator, causing overflow for larger results.

---

## Conclusion

A Repeat Adder was designed using an 8-bit accumulator, an 8-bit counter and a feedback adder in Verilog HDL. The circuit repeatedly adds the input value for **149 clock cycles** while updating the accumulated result. Once all additions are completed, the **done** signal is asserted. This design demonstrates the concept of sequential arithmetic using repeated addition and provides a simple hardware-efficient implementation suitable for FPGA-based digital systems.
