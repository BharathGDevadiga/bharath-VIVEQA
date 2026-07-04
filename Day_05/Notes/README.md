# Day 05 - 7-Segment Display Decoder

## Introduction

A 7-Segment Display Decoder is a combinational logic circuit used to convert a 4-bit binary input into signals that drive a 7-segment display. Each binary input activates specific segments to display decimal digits from **0 to 9**.

In this project, the outputs are **a, b, c, d, e, f, g, and h**, where:

- **a - g** control the seven display segments.
- **h** is connected to **Ground (0)** and is not used for displaying digits.

---

## 7-Segment Display

A 7-segment display consists of seven LEDs arranged to form decimal digits.

```
      a
     ---
  f |   | b
     -g-
  e |   | c
     ---
      d

      h (Ground)
```

Each segment can be turned **ON** or **OFF** independently to display numbers.

---

## Segment Outputs

- **a** → Top segment
- **b** → Top-right segment
- **c** → Bottom-right segment
- **d** → Bottom segment
- **e** → Bottom-left segment
- **f** → Top-left segment
- **g** → Middle segment
- **h** → Ground (Always 0)

---

## Types of 7-Segment Displays

### Common Anode (CA)

- All anodes are connected together.
- Connected to **VCC**.
- A segment turns **ON** when its input is **LOW (0)**.

### Common Cathode (CC)

- All cathodes are connected together.
- Connected to **GND**.
- A segment turns **ON** when its input is **HIGH (1)**.

> This project uses a **Common Anode** display.

---

## Working

The decoder receives a **4-bit binary input** and generates the corresponding output pattern for the 7-segment display.

For each input value, the required segments are turned ON while the remaining segments stay OFF.

The output **h** remains connected to **Ground (0)** for every input.

---

## Block Operation

### Step 1

The decoder reads the 4-bit binary input.

### Step 2

A `case` statement compares the input with decimal values from **0 to 9**.

### Step 3

The corresponding segments (**a–g**) are activated to display the required digit.

### Step 4

The output **h** remains permanently connected to **Ground (0)**.

---

## Truth Table

| Binary Input | Decimal Display |
|--------------|-----------------|
| 0000 | 0 |
| 0001 | 1 |
| 0010 | 2 |
| 0011 | 3 |
| 0100 | 4 |
| 0101 | 5 |
| 0110 | 6 |
| 0111 | 7 |
| 1000 | 8 |
| 1001 | 9 |

---

## Verilog Constructs Used

| Construct | Purpose |
|-----------|---------|
| `module` | Defines the circuit |
| `input` | Accepts the 4-bit binary input |
| `output` | Drives the display segments |
| `reg` | Stores output values |
| `always @(*)` | Implements combinational logic |
| `case` | Selects the segment pattern |
| `default` | Handles invalid inputs |

---

## Applications

- Digital clocks
- Digital counters
- Calculators
- Scoreboards
- Elevator displays
- Digital meters
- FPGA projects
- Embedded systems

---

## Advantages

- Simple combinational circuit
- Fast operation
- Easy to implement using Verilog HDL
- Requires minimal hardware
- Easily expandable for hexadecimal displays
- Suitable for FPGA implementation

---

## Conclusion

A **7-Segment Display Decoder** was designed using Verilog HDL to convert a 4-bit binary input into the corresponding display pattern. A **case statement** was used to activate the required segments for decimal digits **0–9**. The additional output **h** was permanently connected to **Ground (0)** and was not used in the display operation. Simulation verified the correct functionality of the decoder, making it suitable for FPGA-based digital display applications.
