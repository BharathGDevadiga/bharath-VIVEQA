# ESP32

The RTL exposes the ESP32-C3 UART as a second asynchronous link. Incoming
dashboard commands use `E3 type value_hi value_lo xor8`; outgoing display data
uses `D3 sequence event sensor_hi sensor_lo status xor8`.

The dashboard link is untrusted. `esp32_packet_parser` only checks transport
framing; Team 1 must authenticate, authorize, and replay-check every message.
The supplied manual does not state FPGA package pins for the J13 UART path, so
the corresponding XDC entries are intentionally omitted.
