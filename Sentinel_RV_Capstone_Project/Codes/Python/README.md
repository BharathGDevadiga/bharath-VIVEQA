# Python Desktop Applications (`Codes/Python/`)

This directory contains all desktop control centers, live graphing tools and Micro-SD audit log inspection utilities.

---

### 📌 Application Explanations:

#### 1. `App1_FPGA_Control_And_Sensors.py`
* **What it is:** The primary graphical control center and live sensor telemetry dashboard built with Python and PyQt/Tkinter.
* **Why it is used:** Connects to the FPGA via USB/UART at 115200 baud to stream live telemetry and send control commands.
* **Uses and Capabilities:**
  * Plots real-time live graphs for Temperature, Humidity, Distance and Analog Voltage.
  * Automatically transmits UART role packets (`0xA1` Admin, `0xA2` Researcher, `0xA3` Intern) upon user login to sync the 16x2 LCD display.
  * Plays a loud burglar alarm siren audio sound (`SystemExclamation`) upon detecting intruder alert flags.

#### 2. `App2_SD_Card_Reader.py`
* **What it is:** Micro-SD physical sector audit log inspector.
* **Why it is used:** Reads raw physical disk sectors (`\\.\PhysicalDriveX`) directly from Micro-SD cards formatted by the FPGA.
* **Uses and Capabilities:**
  * Decrypts 512-byte hardware AES audit log records and displays historical security logs.
  * Embedded with a `--uac-admin` manifest to automatically prompt for Windows UAC Administrator rights on double-click.


