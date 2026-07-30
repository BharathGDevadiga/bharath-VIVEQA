# USB/UART Telemetry Subsystem

This directory contains the UART transmitter, receiver and telemetry frame formatting modules.

---

### 📌 Module Explanations:

#### 1. `uart_top.v`, `baud_gen.v`, `uart_tx.v` and `uart_rx.v`
* **What it is:** Complete UART serial transceiver operating at 115200 baud.
* **Why it is used:** Provides bi-directional serial communications over USB (FT232H port J1).
* **Uses and Capabilities:**
  * Transmits live telemetry data to the desktop control center and receives desktop control commands.

#### 2. `sentinel_telemetry_tx.v` and `sentinel_command_rx.v`
* **What it is:** Telemetry frame packetizer and command parser blocks.
* **Why it is used:** Encapsulates sensor metrics into structured 16-byte packets.
* **Uses and Capabilities:**
  * Decodes user login role packets (`0xA1`/`0xA2`/`0xA3`) transmitted from the Python desktop app.
