import serial
import time

PORT = "COM3"
BAUD_RATES = [57600, 96000, 115200, 128000, 230400]

def xor_checksum(data):
    value = 0
    for byte in data:
        value ^= byte
    return value

for baud in BAUD_RATES:
    frames = 0
    data = bytearray()

    with serial.Serial(
        PORT, baud, timeout=0.1,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        xonxoff=False, rtscts=False
    ) as ser:
        time.sleep(0.2)
        ser.reset_input_buffer()

        end_time = time.monotonic() + 2
        while time.monotonic() < end_time:
            data.extend(ser.read(64))

    while len(data) >= 7:
        start = data.find(b"\xA6")
        if start < 0:
            break
        if len(data) < start + 7:
            break

        frame = bytes(data[start:start + 7])
        del data[:start + 7]

        if xor_checksum(frame[:6]) == frame[6]:
            print("PASS at", baud, ":", frame.hex(" ").upper())
            frames += 1

    if frames == 0:
        print("No valid frame at", baud)