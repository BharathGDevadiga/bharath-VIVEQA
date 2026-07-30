# Micro-SD SPI Storage Subsystem

This directory contains SPI master and sector writer modules for writing encrypted audit logs to Micro-SD cards.

---

### 📌 Module Explanations:

#### 1. `audit_log_writer.v` and `sd_logger.v`
* **What it is:** Encrypted security audit logging state machine.
* **Why it is used:** Writes 512-byte raw sector log records to Micro-SD cards when security events or slide switch **S7** (`sw_sd_log_enable`) are triggered.
* **Uses and Capabilities:**
  * Creates tamper-evident log records containing cryptographic nonces, security flags and sensor digests.

#### 2. `sd_card_init.v`, `sd_sector_writer.v` and `spi_sd_master.v`
* **What it is:** Micro-SD SPI initialization (CMD0, CMD8, ACMD41) and sector write driver blocks.
* **Why it is used:** Initializes physical Micro-SD memory cards into SPI mode and executes block writes.
* **Uses and Capabilities:**
  * Handles low-level SPI clocking, command CRC generation and response token validation.
