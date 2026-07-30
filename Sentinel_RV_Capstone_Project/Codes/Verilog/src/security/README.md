# Hardware Security Core

This directory contains the core security enforcement modules implementing anti-replay protection, dynamic nonces, and authorization policies.

---

### 📌 Module Explanations:

#### 1. `security_controller.v`
* **What it is:** Master Security State Machine.
* **Why it is used:** Evaluates security authorization policies, manages alarm states, and enforces access control rules.

#### 2. `once_generator.v`
* **What it is:** Pseudo-random dynamic Nonce generator.
* **Why it is used:** Generates unique cryptographic nonces for every telemetry packet to prevent replay attacks.

#### 3. `eplay_protection.v`
* **What it is:** Sequence number and anti-replay validator.
* **Why it is used:** Tracks incoming packet sequence numbers to detect and reject replayed or out-of-order unauthorized commands.
