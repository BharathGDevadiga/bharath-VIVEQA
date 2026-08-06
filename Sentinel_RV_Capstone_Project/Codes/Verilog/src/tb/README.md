# Verification Testbenches & Simulation Suite

This directory contains behavioral simulation testbenches (`tb_*.v`) and automated test runners.

---

### 📌 Included Testbenches:
* **`tb_sentinel_rv_top.v`**: Complete top-level system simulation testbench.
* **`tb_sentinel_rv_security.v`**: Security core simulation testbench.
* **`tb_aes128_encrypt.v`**: AES encryption unit testbench.
* **`tb_peripheral_top.v`**: Peripheral integration testbench.
* **`tb_uart_top.v` / `tb_command_rx.v` / `tb_telemetry_tx.v`**: UART serial interface testbenches.
* **`tb_sd_logger.v` / `tb_sd_card_init.v`**: SD card audit logger testbenches.
* **`tb_crc_engines.v`**: CRC checksum calculation unit testbenches.
* **`run_tests.ps1`**: PowerShell script used by the **GitHub Actions CI** pipeline to automatically compile and run all tests using Icarus Verilog on every code push.
