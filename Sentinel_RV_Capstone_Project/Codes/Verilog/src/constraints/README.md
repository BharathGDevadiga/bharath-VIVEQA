# FPGA Design Constraints: `sentinel_rv.xdc`

This directory contains the Xilinx Design Constraints (.xdc) file for the Artix-7 FPGA target board.

---

### 📌 File Explanations:

#### 1. `sentinel_rv.xdc`
* **What it is:** Physical pin mapping and IO standard constraint configuration file.
* **Why it is used:** Maps internal Verilog signals to physical FPGA board pins and sets IO voltage standards.
* **Uses & Capabilities in Sentinel-RV:**
  * Assigns clock (clk), reset, UART serial lines, keypad matrix pins, 7-segment display pins, LEDs and relay outputs to physical pins on the Artix-7 FPGA board (xc7a35tftg256-1).
  * Enforces 3.3V LVCMOS (LVCMOS33) electrical voltage levels across all board IOs.
