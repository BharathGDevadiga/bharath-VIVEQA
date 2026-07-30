# Sentinel-RV: Code Directory Specification

Welcome to the **`Codes/`** directory of the **Sentinel-RV Capstone Project**. This directory contains all hardware design modules and software applications needed to synthesize, program and run the secure RISC-V System-on-Chip.

The codebase is organized into two distinct sections:

* ⚡ **[`Verilog/`](Verilog/)**: Hardware description code, testbenches, XDC constraints and Vivado project files.
* 🐍 **[`Python/`](Python/)**: Desktop control center applications, real-time sensor graphing tools and SD card reader utilities.

---

## ⚡ 1. Verilog Hardware Modules (`Verilog/`)

This directory contains the 32-bit RISC-V hardware description code written in Verilog HDL.

### 📌 Top-Level Core Modules
* **`sentinel_rv_board_top.v`**
  * **What it is:** The top-level physical board wrapper module.
  * **Why it is used:** Connects physical FPGA I/O pins (clock, slide switches S1-S8, LEDs L1-L8, 4x4 keypad, LCD and SD card) to the internal SoC core.
  * **Uses:** Handles board-level hardware initialization and 1-to-1 slide switch status LED illumination.

* **`sentinel_rv_top.v`**
  * **What it is:** The central System-on-Chip integration wrapper.
  * **Why it is used:** Connects the RISC-V CPU core, Block RAM, security controller and peripheral drivers together over the MMIO bus.
  * **Uses:** Coordinates system memory mapping, keypad shortcut execution and 7-segment display mode multiplexing.

* **`picorv32.v` and `picorv32_wrapper.v`**
  * **What it is:** A 32-bit RISC-V CPU core implementation.
  * **Why it is used:** Executes embedded control firmware directly from fast 1-cycle internal Block RAM.
  * **Uses:** Runs security protocol logic and orchestrates telemetry streaming.

* **`simple_bram_memory.v`**
  * **What it is:** On-chip Block RAM memory module (4 KB capacity).
  * **Why it is used:** Stores CPU instructions and transient telemetry buffers with zero wait states.
  * **Uses:** Enables fast program execution without external DRAM dependencies.

---

### 🛡️ Security and Cryptography Subsystem
* **`sentinel_rv_security.v`**
  * **What it is:** The top security management engine.
  * **Why it is used:** Integrates cryptographic engines, anti-replay nonces and tamper monitoring.
  * **Uses:** Protects sensor packets from replay attacks and unauthorized access.

* **`aes128_encrypt.v`**
  * **What it is:** A 10-round hardware AES-128 encryption block.
  * **Why it is used:** Encrypts 128-bit payload blocks in hardware in under 12 clock cycles.
  * **Uses:** Encrypts live telemetry streams and Micro-SD audit logs.

* **`nonce_generator.v` and `replay_protection.v`**
  * **What it is:** 64-bit hardware pseudo-random nonce generator and sliding window validator.
  * **Why it is used:** Generates unique cryptographic nonces for every telemetry frame.
  * **Uses:** Prevents packet injection and malicious message replay attacks.

* **`security_controller.v`**
  * **What it is:** Security state machine controller.
  * **Why it is used:** Monitors hardware tamper events, voltage glitches and unauthorized commands.
  * **Uses:** Triggers the piezo alarm siren upon detecting intrusion attempts.

---

### 💾 Storage and Peripheral Controllers
* **`audit_log_writer.v` and `sd_logger.v`**
  * **What it is:** Micro-SD audit log storage manager.
  * **Why it is used:** Formats encrypted event records and writes them to physical SD card sectors over SPI.
  * **Uses:** Provides non-volatile tamper-evident security audit trails.

* **`sevenseg_driver.v`**
  * **What it is:** Multiplexed 4-digit 7-segment display driver.
  * **Why it is used:** Drives segment multiplexing for temperature, distance and voltage readouts.
  * **Uses:** Displays real-time sensor metrics (`t. 28`, `d. 34`, `U.1.65`).

* **`lcd_controller.v` and `lcd_driver.v`**
  * **What it is:** 16x2 HD44780 LCD display driver.
  * **Why it is used:** Displays user role status (`ROLE: ADMIN`, `ROLE: RESEARCH` or `ROLE: INTERN`).
  * **Uses:** Provides visual feedback during desktop application login.

* **`keypad_scan.v` and `keypad_decoder.v`**
  * **What it is:** 4x4 matrix keypad scanner and ASCII decoder.
  * **Why it is used:** Scans 16 push-buttons and generates single-pulse keycodes.
  * **Uses:** Provides direct hardware shortcuts (Key 1 to F) for display modes, buzzer tests and relay toggles.

* **`dht11_controller.v` and `hc_sr04_controller.v`**
  * **What it is:** Single-wire DHT11 temperature/humidity and HC-SR04 ultrasonic distance sensor controllers.
  * **Why it is used:** Measures environmental conditions and object proximity.
  * **Uses:** Feeds real-time sensor metrics into the telemetry pipeline.

* **`mcp3202_sampler.v` and `xadc_monitor.v`**
  * **What it is:** External MCP3202 ADC sampler and internal Artix-7 XADC monitor.
  * **Why it is used:** Digitizes analog voltage rails and monitors internal FPGA die temperature.
  * **Uses:** Detects power supply brownouts and over-temperature tampering.

* **`sentinel_rv.xdc`**
  * **What it is:** Xilinx Design Constraints file for the AT-STLN-ARTIX7-001 board.
  * **Why it is used:** Maps Verilog module port signals to physical Artix-7 package pins (XC7A35T-FTG256-1).
  * **Uses:** Assigns pin locations, I/O voltage standards (LVCMOS33) and 24 MHz clock constraints.

---

## 🐍 2. Python Desktop Applications (`Python/`)

This directory contains desktop graphical user interface tools built using Python and PyQt/Tkinter.

* **`App1_FPGA_Control_And_Sensors.py`**
  * **What it is:** The main control center and live sensor graphing desktop app.
  * **Why it is used:** Connects to the FPGA via USB/UART at 115200 baud to receive encrypted telemetry.
  * **Uses:** Plots live temperature, humidity, distance and voltage charts. Automatically transmits UART role packets (`0xA1`/`0xA2`/`0xA3`) upon user login to sync the 16x2 LCD display. Plays a loud burglar alarm siren sound on intrusion detection.

* **`App2_SD_Card_Reader.py`**
  * **What it is:** Micro-SD physical sector audit log reader.
  * **Why it is used:** Reads raw physical disk sectors (`\\.\PhysicalDriveX`) from Micro-SD cards formatted by the FPGA.
  * **Uses:** Decrypts AES audit records and displays security log histories with elevated Windows UAC administrator permissions.

