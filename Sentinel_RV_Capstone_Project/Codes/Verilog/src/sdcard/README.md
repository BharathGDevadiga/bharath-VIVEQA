# SPI SD Card Audit Logging Subsystem

This directory contains the SPI SD card driver modules responsible for persistent audit logging.

---

### 📌 Module Explanations:

#### 1. `sd_logger.v`
* **What it is:** Master audit log coordinator State Machine.
* **Why it is used:** Formats security events and sensor data into 512-byte sectors and schedules disk writes.

#### 2. `udit_log_writer.v`
* **What it is:** Event log entry formatter.
* **Why it is used:** Formats timestamps, event codes and sensor data into standardized log entries.

#### 3. `sd_card_init.v`
* **What it is:** SD Card SPI initialization state machine.
* **Why it is used:** Sends initialization commands (CMD0, CMD8, ACMD41) to place the SD Card into SPI operational mode.

#### 4. `sd_sector_writer.v`
* **What it is:** Raw 512-byte sector block writer (CMD24).
* **Why it is used:** Writes raw data blocks directly to SD card sector addresses.

#### 5. `spi_sd_master.v`
* **What it is:** Dedicated high-speed SPI bus master for SD card operations.
