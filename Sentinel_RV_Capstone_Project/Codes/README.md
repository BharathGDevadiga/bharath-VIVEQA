# Sentinel-RV: Code Directory Specification

Welcome to the **`Codes/`** directory of the **Sentinel-RV Capstone Project**. This directory contains all hardware design modules and software applications needed to synthesize, program, and run the secure RISC-V System-on-Chip.

## Directory Structure

* **[`Verilog/`](Verilog/)**: Contains the complete hardware description codebase.
  * **[`src/`](Verilog/src/)**: Verilog source files organized by subsystem (CPU, Security, Storage, Integration, etc.). *See the READMEs within each subfolder for detailed module specifications.*
  * **[`Sentinel_RV-Project/`](Verilog/Sentinel_RV-Project/)**: AMD/Xilinx Vivado workspace files (`.xpr`).
* **[`Python/`](Python/)**: Contains the desktop GUI control applications.
  * **`App1_FPGA_Control_And_Sensors.py`**: Main control center for live sensor graphing and telemetry over UART.
  * **`App2_SD_Card_Reader.py`**: Audit log reader for decrypting security events stored on the physical SD card.
