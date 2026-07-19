# Day 22 - MAX7219 4-Digit Seven-Segment Display Up Counter using SPI

## Introduction

This project demonstrates the implementation of a **4-Digit Seven-Segment Display Up Counter** using Verilog HDL and the **MAX7219 LED Display Driver**. The FPGA communicates with the MAX7219 using the **Serial Peripheral Interface (SPI)** protocol. A clock divider generates the SPI clock a decimal counter increments every 0.5 second and a Finite State Machine (FSM) controls the initialization and data transmission to the display.

This project introduces SPI communication clock division finite state machine design decimal digit extraction seven-segment display interfacing and FPGA implementation using Verilog HDL.

---

## MAX7219 Display Driver

The MAX7219 is a serially controlled display driver used to interface multiple seven-segment displays using only three communication lines.

### SPI Signals

- DIN – Serial Data Input
- CLK – Serial Clock
- CS – Chip Select (Load)

The FPGA sends 16-bit commands to configure the display and update each digit.

---

## Clock Divider

The FPGA operates at **24 MHz** while the SPI interface requires a slower clock.

```verilog
reg [4:0] div = 0;
wire tick = (div == 23);

always @(posedge clk_24mhz)
    if(tick)
        div <= 0;
    else
        div <= div + 1;
```

The divider generates a **1 MHz SPI tick** from the 24 MHz system clock.

---

## Up Counter

The design includes a 4-digit decimal up counter.

```verilog
always @(posedge clk_24mhz) begin
    if(count_div == 24'd11_999_999) begin
        count_div <= 0;

        if(number == 9999)
            number <= 0;
        else
            number <= number + 1;
    end
    else
        count_div <= count_div + 1;
end
```

Triggered on the positive edge of the system clock.

The counter increments every **0.5 second**.

After reaching **9999** the counter automatically resets to **0000**.

---

## Decimal Digit Extraction

The counter value is divided into individual decimal digits before being sent to the display.

```verilog
assign d0 = number % 10;
assign d1 = (number / 10) % 10;
assign d2 = (number / 100) % 10;
assign d3 = (number / 1000) % 10;
```

Each digit is transmitted separately to the MAX7219.

---

## SPI Finite State Machine (FSM)

The FSM controls the SPI communication with the MAX7219.

### Initialization Commands

```verilog
16'h0C01
16'h09FF
16'h0A08
16'h0B03
```

These commands configure:

- Normal Operation Mode
- BCD Decode Mode
- Display Brightness
- Four-Digit Scan Limit

After initialization the FSM continuously updates the four display digits.

---

## Input and Output Ports

```verilog
input clk_24mhz;

output seg_cs;
output seg_clk;
output seg_din;
```

- `clk_24mhz` – 24 MHz System Clock
- `seg_cs` – Chip Select for MAX7219
- `seg_clk` – SPI Clock
- `seg_din` – Serial Data Output

---

## SPI Data Transmission

Each SPI transfer sends a **16-bit command**.

```verilog
shift <= {8'h01,4'h0,d0};
shift <= {8'h02,4'h0,d1};
shift <= {8'h03,4'h0,d2};
shift <= {8'h04,4'h0,d3};
```

Each command contains:

- Display Register Address
- Decimal Digit Value

The digits are updated sequentially to display the complete number.

---

## Working Principle

Initially the FPGA powers up and initializes the MAX7219.

The clock divider generates a 1 MHz SPI clock.

The decimal counter increments every 0.5 second.

The current count is divided into four decimal digits.

The FSM serially transmits each digit to the MAX7219 using SPI.

The seven-segment display continuously updates from **0000** to **9999** after which the counter automatically repeats from **0000**.

---

## Sequential Logic

The design is a sequential digital system.

The operation depends on:

- System Clock
- Clock Divider
- Counter
- Decimal Digit Extraction
- SPI State Machine
- Shift Register
- MAX7219 Display Driver

---

## FPGA Mapping

Typical FPGA connections:

- 24 MHz Clock → `clk_24mhz`
- FPGA GPIO → `seg_cs`
- FPGA GPIO → `seg_clk`
- FPGA GPIO → `seg_din`
- MAX7219 → Four-Digit Seven-Segment Display

---

## Simulation

The testbench verifies:

- 24 MHz Clock Generation
- SPI Clock Generation
- SPI State Machine Operation
- MAX7219 Initialization
- Serial Data Transmission
- Counter Operation
- Seven-Segment Display Updates

The simulation confirms that the SPI interface correctly transmits initialization commands and display data to the MAX7219.

---

## Applications

- Digital Counters
- Digital Clocks
- Scoreboards
- Embedded Systems
- Industrial Displays
- FPGA Learning Projects

---

## Key Takeaways

- Learned SPI communication using Verilog HDL.
- Implemented a clock divider for SPI timing.
- Designed a decimal up counter.
- Extracted decimal digits for seven-segment display.
- Implemented an FSM for serial communication.
- Interfaced an FPGA with the MAX7219 display driver.
- Verified the design using a simulation testbench.
- Tested the design on an FPGA with a MAX7219 four-digit seven-segment display.
