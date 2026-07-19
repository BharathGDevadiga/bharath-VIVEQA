# Day 28 - Frequency Divider

## Introduction

This project demonstrates the implementation of a Frequency Divider using Verilog HDL. The design reduces the frequency of an input clock by counting clock pulses and toggling the output clock after a predefined count value. The output frequency is therefore much lower than the input frequency.

This project introduces clock division digital counters sequential logic clock generation and FPGA implementation using Verilog HDL.

---

## Frequency Divider

A Frequency Divider generates a slower clock from a high-frequency input clock.

```verilog
always @(posedge clk) begin

    if(rst) begin
        counter <= 24'd0;
        clk_out <= 1'b0;
    end

    else begin

        if(counter == 24'd11_999_999) begin
            counter <= 24'd0;
            clk_out <= ~clk_out;
        end

        else
            counter <= counter + 1;

    end

end
```

The output clock toggles whenever the counter reaches the specified count value.

---

## Counter Logic

The design uses a 24-bit counter to count the incoming clock pulses.

The counter increments on every positive edge of the system clock.

When the counter reaches the maximum count value it resets to zero and toggles the output clock.

---

## Input and Output Ports

```verilog
input clk;
input rst;

output reg clk_out;
```

**clk** – System clock

**rst** – Active HIGH reset

**clk_out** – Divided output clock

---

## Working Principle

Initially the counter is reset to zero.

The counter increments on every positive edge of the input clock.

When the counter reaches the predefined count value the output clock changes its state.

The counter then resets to zero and the process repeats continuously.

---

## Sequential Logic

The Frequency Divider is a sequential circuit.

The operation depends on:

- Clock
- Reset
- Counter
- Output Clock

---

## FPGA Mapping

Typical FPGA connections:

- 24 MHz Clock → clk
- Push Button → Reset
- LED → Divided Clock Output

The LED blinks at the divided clock frequency making the frequency division visible on the FPGA board.

---

## Simulation

The testbench verifies:

- Reset Operation
- Counter Operation
- Output Clock Generation
- Clock Division
- Continuous Frequency Division

The simulation confirms that the output clock frequency is correctly divided from the input clock.

---

## Applications

- Digital Clocks
- Clock Generation
- FPGA Designs
- Embedded Systems
- Communication Systems
- FPGA Learning Projects

---

## Key Takeaways

- Learned the working principle of a Frequency Divider.
- Implemented a Frequency Divider using Verilog HDL.
- Used a 24-bit counter for clock division.
- Generated a slower clock from a high-frequency input clock.
- Verified the design using a simulation testbench.
- Tested the design on an FPGA using a clock source and an LED.
