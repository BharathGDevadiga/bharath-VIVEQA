# Verification Testbenches & Simulation Suite

This directory contains behavioral simulation testbenches (	b_*.v) and automated test runners.

---

### 📌 Included Testbenches:
* **	b_sentinel_rv_top.v**: Complete top-level system simulation testbench.
* **	b_sentinel_rv_security.v**: Security core simulation testbench.
* **	b_aes128_encrypt.v**: AES encryption unit testbench.
* **	b_peripheral_top.v**: Peripheral integration testbench.
* **	b_uart_top.v / 	b_command_rx.v / 	b_telemetry_tx.v**: UART serial interface testbenches.
* **	b_sd_logger.v / 	b_sd_card_init.v**: SD card audit logger testbenches.
* **	b_crc_engines.v**: CRC checksum calculation unit testbenches.
* **
un_tests.ps1**: PowerShell script for running automated Vivado simulations.
