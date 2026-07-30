# Telemetry Packet Formatter

This directory contains packet framing modules for telemetry communication streams.

---

### 📌 Module Explanations:

#### 1. `packet_formatter.v`
* **What it is:** Telemetry packet framing and formatting State Machine.
* **Why it is used:** Formats raw sensor readings, security status, nonces, and CRC32 checksums into structured binary packets for transmission over UART or writing to SD Card storage.
