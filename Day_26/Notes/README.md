# Day 26 - PWM Generator

## Introduction

This project demonstrates the implementation of a Pulse Width Modulation (PWM) Generator using Verilog HDL. The design generates a PWM signal whose duty cycle is controlled by an 8-bit input value. An 8-bit counter continuously compares its value with the selected duty cycle to generate the PWM waveform.

This project introduces PWM generation digital counters comparator logic duty cycle control sequential logic and FPGA implementation using Verilog HDL.

---

## Pulse Width Modulation (PWM)

Pulse Width Modulation (PWM) is a technique used to control the average power delivered to a load by varying the width of the HIGH pulse while keeping the output frequency constant.

```verilog
assign pwm_out = (counter < duty_cycle);
```

The PWM output remains HIGH while the counter value is less than the selected duty cycle.

---

## Counter Logic

```verilog
always @(posedge clk) begin
    if(rst)
        counter <= 8'd0;
    else
        counter <= counter + 1;
end
```

Triggered on the positive edge of the clock.

The counter continuously counts from 0 to 255.

After reaching 255 the counter automatically resets to 0 and repeats the counting sequence.

---

## Input and Output Ports

```verilog
input clk;
input rst;
input [7:0] duty_cycle;

output pwm_out;
```

**clk** – System clock

**rst** – Active HIGH reset

**duty_cycle** – 8-bit duty cycle input

**pwm_out** – PWM output signal

---

## Working Principle

Initially the counter is reset to zero.

On every positive edge of the clock the counter increments by one.

The counter value is continuously compared with the selected duty cycle.

If the counter value is less than the duty cycle the PWM output remains HIGH.

Otherwise the PWM output becomes LOW.

The process continuously repeats to generate the PWM waveform.

---

## Duty Cycle

| Duty Cycle | Output |
|------------|--------|
| 0 | 0% |
| 64 | 25% |
| 128 | 50% |
| 192 | 75% |
| 255 | Nearly 100% |

---

## Sequential Logic

The PWM generator is a sequential circuit.

The operation depends on:

- Clock
- Reset
- Counter
- Duty Cycle
- Comparator

---

## FPGA Mapping

Typical FPGA connections:

- 24 MHz Clock → clk
- Slide Switches → Duty Cycle Input
- Push Button → Reset
- LED → PWM Output

---

## Simulation

The testbench verifies:

- Reset Operation
- Counter Operation
- 25% Duty Cycle
- 50% Duty Cycle
- 75% Duty Cycle
- 100% Duty Cycle
- PWM Output Generation

The simulation confirms that the PWM output changes according to the selected duty cycle while maintaining a constant output frequency.

---

## Applications

- DC Motor Speed Control
- LED Brightness Control
- Embedded Systems
- Power Electronics
- FPGA Learning Projects

---

## Key Takeaways

- Learned the working principle of Pulse Width Modulation.
- Implemented an 8-bit PWM Generator using Verilog HDL.
- Controlled the duty cycle using an 8-bit input.
- Generated PWM signals with different duty cycles.
- Verified the design using a simulation testbench.
- Tested the design on an FPGA using switches and LEDs.
