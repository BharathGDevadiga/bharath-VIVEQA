# Cyclic Redundancy Check (CRC) Subsystem

This directory contains hardware CRC calculation modules for data integrity verification.

---

### 📌 Module Explanations:

#### 1. crc32_mpeg2.v
* **What it is:** Hardware CRC-32/MPEG-2 checksum calculation engine.
* **Why it is used:** Computes 32-bit CRC values over data streams to verify data integrity.
* **Uses & Capabilities in Sentinel-RV:**
  * Generates checksums for telemetry packets to ensure noise or corruption over serial lines is detected by receiving applications.

#### 2. crc_stream.v
* **What it is:** Streaming byte-wise CRC engine for continuous data pipelines.
* **Why it is used:** Processes multi-byte data streams on-the-fly without requiring full-packet buffering.
