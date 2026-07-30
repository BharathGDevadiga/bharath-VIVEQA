import serial
import time

with serial.Serial("COM3", 115200, timeout=0.1) as serial_port:
    time.sleep(0.3)
    serial_port.reset_input_buffer()

    data = bytearray()
    end_time = time.monotonic() + 3

    while time.monotonic() < end_time:
        data.extend(serial_port.read(64))

print("Bytes received:", len(data))
print(data.hex(" ").upper())