# Sentinel-RV: Comprehensive Architecture Notes & Hardware Specification

## 📜 System Design Overview

**Sentinel-RV** is an advanced, high-security 32-bit RISC-V System-on-Chip (SoC) designed for embedded hardware security applications, environmental telemetry monitoring and automated safety enforcement on the **AMD/Xilinx Artix-7 XC7A35T-FTG256-1 FPGA**. 

The system integrates an open-source 32-bit RISC-V soft processor core (`PicoRV32`), hardware-accelerated AES-128 encryption, dynamic anti-replay nonce generators, multi-channel sensor telemetry drivers, persistent SPI Micro-SD audit logging and desktop GUI monitoring suites.

---

## 🏗️ Hardware Architecture & System Dataflow

```text
                               +----------------------------------+
                               |     4x4 Matrix Keypad (0-F)      |
                               +-----------------+----------------+
                                                 |
                                                 v
+-----------------------+      +-----------------+----------------+      +------------------------+
| 8x Slide Switches     | ---> |  Top Board Wrapper               | ---> | 8x Status LEDs         |
| (S1 - S8)             |      |  (sentinel_rv_board_top.v)       |      | (L1 - L8)              |
+-----------------------+      +-----------------+----------------+      +------------------------+
                                                 |
                                                 v
+------------------------------------------------+------------------------------------------------+
|                                    Sentinel-RV System-on-Chip                                   |
|                                       (sentinel_rv_top.v)                                       |
|                                                                                                 |
|  +---------------------+       +-----------------------+       +-----------------------------+  |
|  | PicoRV32 RISC-V CPU | <---> | 4KB BRAM Memory       | <---> | Security Controller Core    |  |
|  | (32-bit RV32I)      |       | (cpu_test_program.hex)|       | (security_controller.v)     |  |
|  +----------+----------+       +-----------------------+       +--------------+--------------+  |
|             |                                                                 |                 |
|             v                                                                 v                 |
|  +----------+----------+                                       +--------------+--------------+  |
|  | MMIO Bus Bridge     |                                       | AES-128 Encryption Engine   |  |
|  | (cpu_mmio_bridge.v) |                                       | (aes128_encrypt.v)           |  |
|  +----------+----------+                                       +--------------+--------------+  |
|             |                                                                 |                 |
+-------------|-----------------------------------------------------------------|-----------------+
              |                                                                 |
              v                                                                 v
+-------------+-----------------------------------------------------------------+-----------------+
|                               Peripheral Subsystem (peripheral_top.v)                           |
|                                                                                                 |
|  +--------------------+   +---------------------+   +--------------------+   +---------------+\ |
|  | DHT11 Temp/Humidity|   | HC-SR04 Distance    |   | MCP3202 12-bit ADC |   | XADC Internal | \|
|  | Sensor Reader      |   | Ultrasonic Reader   |   | SPI Sampler        |   | Voltage/Temp  |  |
|  +--------------------+   +---------------------+   +--------------------+   +---------------+  |
|                                                                                                 |
|  +--------------------+   +---------------------+   +--------------------+   +---------------+  |
|  | 16x2 HD44780 LCD   |   | 4-Digit 7-Segment   |   | Piezo Siren        |   | Form-C Safety |  |
|  | Display Controller |   | Display Driver      |   | Buzzer Controller  |   | Relay Actuator|  |
|  +--------------------+   +---------------------+   +--------------------+   +---------------+  |
|                                                                                                 |
|  +----------------------------------------------+   +----------------------------------------+  |
|  | Full-Duplex UART Serial Controller (115200)  |   | SPI Micro-SD Audit Log Sector Writer   |  |
|  +----------------------------------------------+   +----------------------------------------+  |
+-------------------------------------------------------------------------------------------------+
```

---

## 🎚️ 1-to-1 Slide Switch & LED Map (`S1`–`S8` $\leftrightarrow$ `L1`–`L8`)

The AT-STLN-ARTIX7-001 FPGA board provides 8 slide switches (`S1`–`S8`) directly mapped 1-to-1 to 8 status LEDs (`L1`–`L8`):

| Switch | FPGA Pin | Feature | Function When Switched UP (`1`) | Status LED |
|---|---|---|---|---|
| **`S1`** | `C9` | **System Reset** | **DOWN** = Reset held during programming; **UP** = System Runs. | **`L1` (D5)** 🟢 |
| **`S2`** | `B9` | **Alarm Clear** | Clears latched security alarms and silences the buzzer. | **`L2` (A3)** 🟢 |
| **`S3`** | `G5` | **Display Lock** | Freezes 7-Segment display on **Temperature (`t. 28`)**. | **`L3` (B4)** 🟢 |
| **`S4`** | `A7` | **Alarm Test** | Manually sounds 2048 Hz piezo buzzer for hardware test. | **`L4` (A4)** 🟢 |
| **`S5`** | `C7` | **Relay Force** | Manually energizes Form-C Safety Relay ON. | **`L5` (E6)** 🟢 |
| **`S6`** | `A10` | **Tamper Boost** | Boosts XADC voltage and temperature glitch sensitivity. | **`L6` (C13)** 🟢 |
| **`S7`** | `B7` | **SD Log Active** | Enables writing encrypted audit log records to Micro-SD. | **`L7` (C14)** 🟢 |
| **`S8`** | `A8` | **Master Clock** | Displays 24 MHz master system clock heartbeat. | **`L8` (D14)** 🟢 |

---

## ⌨️ 4×4 Matrix Keypad Map (`0`–`F`)

The 4x4 matrix keypad provides hardware shortcuts and local system commands:

| Key | Action Triggered | Display / Hardware Feedback |
|---|---|---|
| **`0`** | **Clear Key Buffer** | Clears keypad internal register state |
| **`1`** | **Toggle Relay** | Manually energizes / de-energizes safety relay |
| **`2`** | **Silence Alarm** | Mutes active piezo buzzer siren |
| **`3`** | **Test Buzzer** | Plays 2048 Hz piezo acoustic test tone |
| **`4`** | **Toggle Temp/Distance** | Switches 7-Segment between Temperature (`t. 28`) and Distance (`d. 34`) |
| **`5`** | **Write SD Audit Log** | Formats and writes an encrypted 512-byte audit log entry to SD card |
| **`6`** | **Show ADC Voltage** | Displays live analog voltage (`U.1.65`) on 7-Segment display |
| **`7`** | **Show Humidity** | Displays live relative humidity (`H. 55`) on 7-Segment display |
| **`8`** | **Run Diagnostic Test** | Scans internal security buses and validates peripheral status |
| **`9`** | **Reset Anti-Replay** | Clears sequence numbers and resets 64-bit anti-replay nonce counter |
| **`A`** | **Reset Peak Memory** | Resets peak temperature and minimum distance memory registers |
| **`B`** | **Display Freeze/Pause** | Freezes live 7-Segment display updates |
| **`C`** | **Clear Sensor Errors** | Clears sensor checksum and timeout error flags |
| **`D`** | **Burglar Alarm Test** | Triggers full burglar alarm siren audio simulation |
| **`E`** | **Send AES Packet** | Encrypts telemetry block and transmits 128-bit ciphertext over UART |
| **`F`** | **Master SoC Reset** | Performs soft reset of RISC-V CPU and peripheral sub-controllers |

---

## 🗺️ Memory-Mapped I/O (MMIO) Address Space

The PicoRV32 RISC-V CPU accesses peripherals via 32-bit Memory-Mapped I/O addresses:

| Base Address Range | Subsystem / Register | Access | Description |
|---|---|---|---|
| **`0x0000_0000 - 0x0000_0FFF`** | **Internal Block RAM** | R/W | 4 KB BRAM executing firmware instructions (`cpu_test_program.hex`) |
| **`0x8000_0000`** | **GPIO Output Register** | W | Controls status LEDs, relay state and buzzer enable |
| **`0x8000_0004`** | **GPIO Input Register** | R | Reads slide switches S1-S8 and push buttons |
| **`0x8000_0010`** | **7-Seg Display Register** | W | Writes BCD values for 4-digit 7-segment display multiplexer |
| **`0x8000_0020`** | **DHT11 Sensor Register** | R | Reads 8-bit temperature and 8-bit humidity data |
| **`0x8000_0024`** | **HC-SR04 Distance Register** | R | Reads ultrasonic distance measurement in centimeters |
| **`0x8000_0030`** | **MCP3202 ADC Register** | R | Reads 12-bit analog voltage sampling results |
| **`0x8000_0040`** | **UART TX Data Register** | W | Transmits byte over 115200 baud serial interface |
| **`0x8000_0044`** | **UART RX Data Register** | R | Reads incoming serial command byte |
| **`0x8000_0050`** | **AES Key / Data Register** | W | Loads 128-bit key and plaintext into AES-128 hardware cipher |
| **`0x8000_0060`** | **SD Card Command Register** | W | Triggers 512-byte sector audit log write |

---

## 🛡️ Security Core & Cryptography Subsystem

### 1. Hardware AES-128 Encryption (`aes128_encrypt.v`)
* Implements a 10-round AES-128 block cipher in pure hardware logic.
* Encrypts 128-bit plaintext blocks into ciphertext in under 12 clock cycles.
* Used for encrypting live serial telemetry frames and SD card audit logs.

### 2. Anti-Replay Protection (`replay_protection.v` & `nonce_generator.v`)
* Generates 64-bit pseudo-random dynamic nonces for every telemetry frame.
* Implements a sliding window sequence number validator to detect and reject replayed or out-of-order unauthorized commands.

### 3. XADC Die Temperature & Power-Rail Monitoring (`xadc_monitor.v`)
* Continuously samples internal FPGA die temperature and `VCCINT` / `VCCAUX` power rails using Artix-7 internal XADC primitives.
* Triggers automatic security alarms if overheating or voltage tampering occurs.

---

## 💾 SPI Micro-SD Card Audit Logging (`sd_logger.v`)

* **Storage Architecture:** Direct SPI mode communication (`sd_card_init.v`, `spi_sd_master.v`, `sd_sector_writer.v`).
* **Sector Formatting:** Formats security logs into raw 512-byte physical disk sectors.
* **Audit Record Structure:** Each sector record contains:
  * **Header:** 4-byte signature (`0x53454E54` -> "SENT")
  * **Sequence & Timestamp:** 32-bit monotonically increasing log sequence number.
  * **Sensor Payload:** Encrypted DHT11 temperature, humidity, distance, voltage and security flags.
  * **Cryptographic Hash Chain:** 128-bit hash linking the current log entry to the previous block.

---

## 🖥️ Desktop Software Integration

The system communicates seamlessly with Python desktop tools over 115200 baud serial UART:

### 1. **`App1_FPGA_Control_And_Sensors.py`**
* **Real-time Live Sensor Graphing:** Plots live charts for Temperature (°C), Humidity (%), Proximity Distance (cm) and Analog Voltage (V).
* **Automatic LCD Role Synchronization:** Transmits UART packets (`0xA1`, `0xA2`, `0xA3`) upon user login to sync the onboard 16x2 LCD display to `ROLE: ADMIN`, `ROLE: RESEARCH` or `ROLE: INTERN`.
* **Acoustic Burglar Alarm:** Plays a loud burglar alarm siren sound on intrusion detection.

### 2. **`App2_SD_Card_Reader.py`**
* **Raw Physical Sector Inspection:** Reads physical disk sectors (`\\.\PhysicalDriveX`) directly from Micro-SD cards formatted by the FPGA.
* **AES Decryption & Audit Trail Verification:** Decrypts 512-byte hardware AES audit log records and verifies timestamp sequence numbers with elevated Windows UAC Administrator rights.
