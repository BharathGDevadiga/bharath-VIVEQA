# Day 29 - Digital Clock

## Introduction

This project demonstrates the implementation of a **24-Hour Digital Clock** using **Verilog HDL**. The design generates a one-second timing pulse from the onboard 24 MHz system clock counts seconds minutes and hours and displays the current time in **HH:MM** format on a 4-digit seven-segment display using the MAX7219 display driver.

This project introduces clock division sequential logic digital counters SPI communication and FPGA interfacing using Verilog HDL.

---

## Digital Clock

A Digital Clock measures time by counting clock pulses generated from the FPGA system clock.

The design consists of

- Frequency Divider
- One Second Timer
- Seconds Counter
- Minutes Counter
- Hours Counter
- SPI Controller
- MAX7219 Display Driver

---

## One Second Clock Generation

The FPGA uses a 24 MHz system clock.

A counter divides the input clock to generate a pulse every one second.

```verilog
always @(posedge clk_24mhz)
begin
    if(sec_div == 24_000_000-1)
    begin
        sec_div <= 0;
        one_sec <= 1;
    end
    else
    begin
        sec_div <= sec_div + 1;
        one_sec <= 0;
    end
end
```

The generated pulse updates the digital clock once every second.

---

## Clock Counter Logic

The design uses three counters.

- Seconds (00–59)
- Minutes (00–59)
- Hours (00–23)

When the seconds counter reaches 59 it resets to zero and increments the minutes counter.

When the minutes counter reaches 59 it resets to zero and increments the hours counter.

When the hours counter reaches 23 it rolls over to 00.

---

## Time Display

The current time is displayed in

```text
HH : MM
```

The decimal digits are obtained using division and modulo operations.

```verilog
assign d0 = min % 10;
assign d1 = min / 10;

assign d2 = hour % 10;
assign d3 = hour / 10;
```

Each digit is transmitted to the MAX7219 display driver through SPI.

---

## SPI Communication

The MAX7219 communicates using the SPI interface.

The SPI controller performs the following operations.

- Initialize the MAX7219
- Enable Decode Mode
- Set Display Brightness
- Configure Scan Limit
- Continuously update all four display digits

---

## Input and Output Ports

```verilog
input clk_24mhz;

output seg_cs;
output seg_clk;
output seg_din;
```

- **clk_24mhz** – 24 MHz FPGA system clock
- **seg_cs** – MAX7219 Chip Select
- **seg_clk** – SPI Clock
- **seg_din** – SPI Data Input

---

## Working Principle

Initially the clock starts from **00:00**.

The frequency divider generates a one-second pulse.

Every second

- Seconds increment by one.
- Minutes increment after 59 seconds.
- Hours increment after 59 minutes.
- Hours reset to 00 after reaching 23.

The current time is continuously transmitted to the MAX7219 which refreshes the four-digit seven-segment display.

---

## Sequential Logic

The Digital Clock is a sequential circuit.

The operation depends on

- System Clock
- Frequency Divider
- Seconds Counter
- Minutes Counter
- Hours Counter
- SPI State Machine

---

## FPGA Mapping

Typical FPGA connections

- 24 MHz Clock → clk_24mhz
- MAX7219 DIN → seg_din
- MAX7219 CLK → seg_clk
- MAX7219 LOAD → seg_cs

The MAX7219 continuously displays the current time in HH:MM format.

---

## Simulation

The testbench verifies

- Clock Generation
- One Second Pulse
- Seconds Counter
- Minutes Counter
- Hours Counter
- SPI Communication
- Continuous Time Update

The simulation confirms that the digital clock operates correctly.

---

## Applications

- Digital Clocks
- FPGA Timekeeping
- Embedded Systems
- Industrial Timers
- Digital Displays
- FPGA Learning Projects

---

## Key Takeaways

- Learned the working principle of a 24-hour Digital Clock.
- Implemented a Digital Clock using Verilog HDL.
- Generated a one-second timing pulse from a 24 MHz clock.
- Implemented hours minutes and seconds counters.
- Interfaced the FPGA with the MAX7219 using SPI.
- Displayed time in HH:MM format.
- Verified the design using simulation.
- Tested the design on the FPGA.
