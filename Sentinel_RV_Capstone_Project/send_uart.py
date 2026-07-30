import serial
import time

PORT = "COM3"
BAUDRATE = 115200

SEQUENCE = 0x01
OPCODE = 0x02
ARGUMENT = 0x0000

def xor_checksum(data):
    value = 0
    for byte in data:
        value ^= byte
    return value

command = bytes([
    0xA5,
    OPCODE,
    SEQUENCE,
    (ARGUMENT >> 8) & 0xFF,
    ARGUMENT & 0xFF
])
command += bytes([xor_checksum(command)])

with serial.Serial(PORT, BAUDRATE, timeout=0.1) as ser:
    time.sleep(0.2)
    ser.reset_input_buffer()
    ser.reset_output_buffer()

    print("Sent:    ", command.hex(" ").upper())
    ser.write(command)
    ser.flush()

    buffer = bytearray()
    deadline = time.monotonic() + 5

    while time.monotonic() < deadline:
        buffer.extend(ser.read(64))

        while len(buffer) >= 7:
            start = buffer.find(b"\xA6")

            if start < 0:
                buffer.clear()
                break

            if start > 0:
                del buffer[:start]

            if len(buffer) < 7:
                break

            frame = bytes(buffer[:7])

            if xor_checksum(frame[:6]) != frame[6]:
                del buffer[0]
                continue

            del buffer[:7]
            print("Received:", frame.hex(" ").upper())

            event = frame[2]

            if event == 0x01:
                print("ADC telemetry received; waiting for command result...")
            elif event == 0x10:
                print("COMMAND ACCEPTED - UART/security test passed")
                raise SystemExit
            elif event == 0x02:
                print("COMMAND REJECTED")
                raise SystemExit
            elif event == 0xEE:
                print("ALARM EVENT")
                raise SystemExit

print("No valid command-result frame received")