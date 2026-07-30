# Sentinel-RV: Synthesis & Implementation Results

## 📊 Design Verification & Performance Summary

* **Target Device:** Xilinx Artix-7 `XC7A35T-FTG256-1`
* **Synthesis Tool:** Vivado v2025.2 (64-bit)
* **Status:** 🟢 **0 Errors, 0 Critical Warnings**

---

## ⏱️ Timing Verification

| Metric | Target Clock | Achieved WNS | Status |
|---|---|---|---|
| **Worst Negative Slack (WNS)** | 24.00 MHz (41.667 ns) | **+14.744 ns** | ✅ **MET WITH HIGH MARGIN** |
| **Total Hold Slack (THS)** | 24.00 MHz | **+0.082 ns** | ✅ **PASSED** |

---

## 📂 Verification Artifacts Included

1. **`sentinel_rv_architecture.jpg`** — Complete System Architecture & Peripheral Interconnect Diagram.
2. **`sensor_telemetry_log.csv`** — Log of encrypted telemetry streaming data over USB/UART at 115200 baud.
