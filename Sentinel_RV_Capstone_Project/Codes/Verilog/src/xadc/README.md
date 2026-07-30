# On-Chip XADC System Monitor

This directory contains the driver module for the Xilinx Artix-7 FPGA internal dual 12-bit 1MSPS Analog-to-Digital Converter (XADC).

---

### 📌 Module Explanations:

#### 1. `xadc_monitor.v`
* **What it is:** Xilinx XADC Primitive Monitor.
* **Why it is used:** Continuously measures internal FPGA die temperature and internal power supply voltage rails (VCCINT, VCCAUX).
* **Uses & Capabilities in Sentinel-RV:**
  * Provides hardware tamper and brownout protection by detecting physical overheating or power-rail glitch attacks on the FPGA chip.
