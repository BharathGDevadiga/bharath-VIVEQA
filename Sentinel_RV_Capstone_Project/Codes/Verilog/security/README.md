# Security Subsystem: Nonce and Anti-Replay Protection

This directory contains hardware anti-replay window engines and nonce generators.

---

### 📌 Module Explanations:

#### 1. `sentinel_rv_security.v` and `security_controller.v`
* **What it is:** Top security controller managing intrusion detection and tamper recovery.
* **Why it is used:** Evaluates analog supply voltage and die temperature against safety bounds.
* **Uses and Capabilities:**
  * Sounds piezo alarm sirens upon detecting voltage drops or temperature spikes.

#### 2. `nonce_generator.v` and `replay_protection.v`
* **What it is:** 64-bit pseudo-random nonce generator and 64-entry sliding window validator.
* **Why it is used:** Ensures every incoming command and outgoing telemetry frame contains a unique, non-repeating sequence number.
* **Uses and Capabilities:**
  * Blocks message replay attacks and unauthorized packet injection attempts.
