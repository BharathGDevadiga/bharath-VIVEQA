import serial
import time

PORT = "COM3"
payload = bytes.fromhex("A5 05 01 12 34 87")

with serial.Serial(PORT, 115200, timeout=2) as serial_port:
    time.sleep(0.2)
    serial_port.reset_input_buffer()
    serial_port.write(payload)
    serial_port.flush()
    received = serial_port.read(len(payload))

print("Sent:    ", payload.hex(" ").upper())
print("Received:", received.hex(" ").upper())

if received == payload:
    print("LOOPBACK PASS")
else:
    print("LOOPBACK FAIL")