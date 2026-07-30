# Hardware AES Security Engine: es128_encrypt.v

This directory contains the hardware-accelerated AES-128 block cipher encryption module.

---

### 📌 Module Explanations:

#### 1. es128_encrypt.v
* **What it is:** Hardware implementation of the Advanced Encryption Standard (AES) with a 128-bit key size.
* **Why it is used:** Encrypts sensitive telemetry data and audit logs in hardware at clock-cycle speeds.
* **Uses & Capabilities in Sentinel-RV:**
  * Encrypts sensor payloads before transmission over UART serial links to protect against eavesdropping.
  * Generates encrypted data blocks for secure SD-card audit logging.
