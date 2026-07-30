# Cryptographic Engine: `aes128_encrypt.v`

This directory contains the hardware AES-128 cryptographic engine module.

---

### 📌 Module Explanation: `aes128_encrypt.v`

* **What it is:** A 10-round hardware AES-128 encryption block.
* **Why it is used:** Encrypts 128-bit plaintext data blocks into 128-bit ciphertext in hardware in under 12 clock cycles.
* **Uses and Capabilities:**
  * Secures live sensor telemetry streams transmitted over UART at 115200 baud.
  * Encrypts audit log records written to Micro-SD storage.
  * Eliminates software encryption overhead from the RISC-V CPU core.
