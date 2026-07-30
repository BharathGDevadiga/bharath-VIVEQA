# Serial UART Communication Subsystem

This directory contains full-duplex asynchronous serial UART communication driver modules.

---

### 📌 Module Explanations:

#### 1. `uart_top.v`
* **What it is:** Top-level UART communication wrapper module.
* **Why it is used:** Combines transmitter, receiver, and baud rate generator into a single unified UART controller.

#### 2. `uart_tx.v` & `uart_rx.v`
* **What they are:** Asynchronous Serial Transmitter and Receiver modules with start/stop bit framing and parity checking.

#### 3. `aud_gen.v`
* **What it is:** Programmable baud rate generator.
* **Why it is used:** Divides the system clock to generate standard serial clock ticks (e.g. 115,200 baud).

#### 4. `sentinel_telemetry_tx.v` & `sentinel_command_rx.v`
* **What they are:** Dedicated telemetry streaming transmitter and command parsing receiver state machines.
