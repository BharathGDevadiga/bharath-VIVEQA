# CRC Checksum Engine: `crc32_mpeg2.v` and `crc_stream.v`

This directory contains the hardware cyclic redundancy check (CRC32) calculation engines.

---

### 📌 Module Explanations:

#### 1. `crc32_mpeg2.v`
* **What it is:** MPEG-2 standard 32-bit CRC checksum calculator block.
* **Why it is used:** Computes 32-bit integrity checksums across telemetry data packets.
* **Uses and Capabilities:**
  * Appends CRC32 digest fields to encrypted UART packets to detect line noise and bit corruptions.

#### 2. `crc_stream.v`
* **What it is:** Streaming bit-by-bit CRC calculation pipeline module.
* **Why it is used:** Calculates checksums on live data streams on-the-fly without buffering entire packets.
* **Uses and Capabilities:**
  * Streamlines packet generation for fast telemetry transmission.
