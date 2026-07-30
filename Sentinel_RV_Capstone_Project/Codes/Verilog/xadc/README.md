# XADC Internal Die Monitor: `xadc_monitor.v`

This directory contains the interface module for the internal Xilinx Artix-7 XADC primitive.

---

### 📌 Module Explanation: `xadc_monitor.v`

* **What it is:** Hardware sampler for the internal Artix-7 FPGA XADC macro.
* **Why it is used:** Monitors internal $V_{CCINT}$ supply voltage (1.0V rail) and FPGA die junction temperature.
* **Uses and Capabilities:**
  * Detects supply voltage glitching and physical thermal tampering attacks in real time.
