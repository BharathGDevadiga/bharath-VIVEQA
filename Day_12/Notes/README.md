# Day 12 - Password Lock System

## Introduction

This project demonstrates a simple Password Lock System using Verilog HDL on the Basys 3 FPGA board. The eight slide switches are used to enter an 8-bit password, while a push button acts as the confirmation input. If the entered password matches the predefined password, all onboard LEDs turn ON; otherwise, the LEDs remain OFF.

This project introduces the use of conditional statements (`if-else`) in Verilog and demonstrates a basic digital authentication system.

---

## Conditional Statements

Conditional statements are used to make decisions based on input conditions.

```verilog
if (confirm) begin
    if (sw == 8'b10101010)
        leds = 8'b11111111;
    else
        leds = 8'b00000000;
end
```

- Executes whenever the inputs change.
- Does not require a clock.
- Suitable for combinational logic.
- The output depends on the current input values.

---

## Input and Output Ports

```verilog
input [7:0] sw;
input confirm;
output reg [7:0] leds;
```

- `sw[7:0]` represents the eight slide switches used to enter the password.
- `confirm` is the push button used to verify the entered password.
- `leds[7:0]` represents the eight onboard LEDs used to display the authentication result.

---

## Working Principle

The user enters an 8-bit password using the slide switches.

**Password = `10101010` (0xAA)**

When the **confirm** button is pressed:

```
Entered Password = 10101010

↓

Password Match

↓

LEDs = 11111111
```

If the password is incorrect:

```
Entered Password ≠ 10101010

↓

Password Mismatch

↓

LEDs = 00000000
```

---

## Why No Clock?

This design is purely combinational.

There are:

- No flip-flops
- No counters
- No registers storing previous values
- No sequential logic

Therefore, a clock signal is not required.

---

## Combinational Logic

The output depends only on the current values of the switches and the confirm button.

Mathematically,

```
If confirm = 1 and sw = 10101010

LEDs = 11111111

Else

LEDs = 00000000
```

There is no dependency on previous input values.

---

## FPGA Mapping

Typical Basys 3 connections:

- SW0 → Password Bit 0
- SW1 → Password Bit 1
- SW2 → Password Bit 2
- SW3 → Password Bit 3
- SW4 → Password Bit 4
- SW5 → Password Bit 5
- SW6 → Password Bit 6
- SW7 → Password Bit 7
- BTN0 → Confirm Button
- LED0–LED7 → Authentication Status

---

## Simulation

The testbench verifies the design using different test cases such as:

- Confirm button not pressed
- Correct password (`10101010`)
- Incorrect password (`11110000`)
- Incorrect password (`00001111`)
- Correct password again

The simulation confirms that:

- Correct password → All LEDs ON
- Incorrect password → All LEDs OFF

---

## Applications

- Digital password lock systems
- Basic authentication circuits
- FPGA learning projects
- Digital security demonstrations
- Access control systems

---

## Key Takeaways

- Learned how to use `if-else` statements in Verilog.
- Understood password comparison using conditional logic.
- Implemented a simple combinational password verification system.
- Verified the design using a testbench.
- Interfaced slide switches, push button and LEDs on the Basys 3 FPGA board.
