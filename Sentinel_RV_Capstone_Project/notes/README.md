# Sentinel-RV: Architecture Notes & Hardware Specification

## 📜 System Design Overview

**Sentinel-RV** is a 32-bit RISC-V System-on-Chip (SoC) designed for high-security embedded hardware applications on the **Xilinx Artix-7 XC7A35T-FTG256-1 FPGA**.

---

## 🎚️ 1-to-1 Slide Switch & LED Map (`S1`–`S8` $\leftrightarrow$ `L1`–`L8`)

| Switch | FPGA Pin | Feature | Function When Switched UP (`1`) | Status LED |
|---|---|---|---|---|
| **`S1`** | `C9` | **System Reset** | **DOWN** = Reset held during programming; **UP** = System Runs. | **`L1` (D5)** 🟢 |
| **`S2`** | `B9` | **Alarm Clear** | Clears latched security alarms and silences the buzzer. | **`L2` (A3)** 🟢 |
| **`S3`** | `G5` | **Display Lock** | Freezes 7-Segment display on **Temperature (`t. 28`)**. | **`L3` (B4)** 🟢 |
| **`S4`** | `A7` | **Alarm Test** | Manually sounds 2048 Hz piezo buzzer for hardware test. | **`L4` (A4)** 🟢 |
| **`S5`** | `C7` | **Relay Force** | Manually energizes Form-C Relay ON. | **`L5` (E6)** 🟢 |
| **`S6`** | `A10` | **Tamper Boost** | Boosts XADC voltage/temperature glitch sensitivity. | **`L6` (C13)** 🟢 |
| **`S7`** | `B7` | **SD Log Active** | Enables writing encrypted audit log records to Micro-SD. | **`L7` (C14)** 🟢 |
| **`S8`** | `A8` | **Master Clock** | Displays 24 MHz master system clock heartbeat. | **`L8` (D14)** 🟢 |

---

## ⌨️ 4×4 Matrix Keypad Map (`0`–`F`)

| Key | Action Triggered | Display / Feedback |
|---|---|---|
| **`0`** | Clear Key Buffer | Clears keypad state |
| **`1`** | Toggle Relay | Energizes / De-energizes Relay |
| **`2`** | Silence Alarm | Mutes piezo buzzer siren |
| **`3`** | Test Buzzer | Plays 2048 Hz test tone |
| **`4`** | Toggle Temp/Distance | Switches 7-Seg display mode |
| **`5`** | Write SD Audit Log | Writes encrypted log entry |
| **`6`** | Show ADC Voltage | Displays `U.1.65` on 7-Segment |
| **`7`** | Show Humidity | Displays `H. 55` on 7-Segment |
| **`8`** | Run Diagnostic Test | Scans internal security buses |
| **`9`** | Reset Anti-Replay | Resets 64-bit nonce counter |
| **`A`** | Reset Peak Memory | Resets peak sensor memory |
| **`B`** | Display Freeze/Pause | Freezes live display updates |
| **`C`** | Clear Sensor Errors | Resets sensor glitch flags |
| **`D`** | Burglar Alarm Test | Plays `SystemExclamation` siren |
| **`E`** | Send AES Packet | Transmits 128-bit ciphertext |
| **`F`** | Master SoC Reset | Soft resets CPU & peripherals |

---

## 🖥️ Desktop Software Integration

1. **`App1_FPGA_Control_And_Sensors.exe`**
   * Real-time live sensor graphing.
   * Auto LCD Role Sync: Transmits UART packet updating 16×2 LCD screen to `ROLE: ADMIN`, `ROLE: RESEARCH`, or `ROLE: INTERN`.
   * Silent normal telemetry & loud burglar alarm siren sound on intrusion detection.

2. **`App2_SD_Card_Reader.exe`**
   * Raw Micro-SD sector reader with embedded `--uac-admin` manifest.
