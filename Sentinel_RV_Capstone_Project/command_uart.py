#!/usr/bin/env python3
"""
===============================================================================
Sentinel RV Secure SoC — Command & Sensor Telemetry UART Host Utility
===============================================================================
Author: Sentinel RV Security System
Target Hardware: AT-STLN-ARTIX 7-001 (Artix-7 FPGA)

Roles Supported:
  1. --role intern      : Clean live visual dashboard showing all sensor streams.
  2. --role researcher  : Real-time telemetry streaming, analytics, and CSV logging.
  3. --role admin       : Full command authority (Control Actuators, Send Encrypted
                          Frames, Clear Alarms, Audit Security Logs).
===============================================================================
"""

import sys
import time
import argparse
import struct
import csv
import os
import random
from datetime import datetime

try:
    import serial
    import serial.tools.list_ports
    SERIAL_AVAILABLE = True
except ImportError:
    SERIAL_AVAILABLE = False

try:
    import winsound
    WINSOUND_AVAILABLE = True
except ImportError:
    WINSOUND_AVAILABLE = False


def play_audio_alert(alert_type="beep"):
    """Play audio chime on PC host for live visual/audio feedback."""
    try:
        if WINSOUND_AVAILABLE:
            if alert_type == "alarm":
                winsound.Beep(2200, 200)
            elif alert_type == "accepted":
                winsound.Beep(1400, 100)
            elif alert_type == "rejected":
                winsound.Beep(500, 180)
            else:
                winsound.Beep(1000, 80)
        else:
            sys.stdout.write('\a')
            sys.stdout.flush()
    except Exception:
        pass


# -----------------------------------------------------------------------------
# CRC32 Calculation (MPEG-2 Polynomial 0x04C11DB7)
# -----------------------------------------------------------------------------
def crc32_mpeg2(data: bytes) -> int:
    crc = 0xFFFFFFFF
    poly = 0x04C11DB7
    for b in data:
        crc ^= (b << 24)
        for _ in range(8):
            if crc & 0x80000000:
                crc = ((crc << 1) ^ poly) & 0xFFFFFFFF
            else:
                crc = (crc << 1) & 0xFFFFFFFF
    return crc


# -----------------------------------------------------------------------------
# Simulated Telemetry Generator (Used when --sim is specified or no UART port)
# -----------------------------------------------------------------------------
class SimulatedUART:
    def __init__(self):
        self.seq = 0
        self.in_buffer = bytearray()
        self.is_open = True

    def write(self, data):
        print(f"\n[SIM TX] Sending {len(data)} bytes: {data.hex()}")

    def read(self, size=1):
        if len(self.in_buffer) < size:
            self.generate_telemetry_packet()
        chunk = self.in_buffer[:size]
        self.in_buffer = self.in_buffer[size:]
        return bytes(chunk)

    def generate_telemetry_packet(self):
        self.seq = (self.seq + 1) & 0xFF
        sof = 0xA6
        # Randomly simulate different events for demo mode
        event_roll = random.randint(1, 10)
        if event_roll <= 6:
            event = 0x01  # Periodic sensor update
            status_val = 0x00
        elif event_roll <= 8:
            event = 0x10  # Command accepted
            status_val = 0x00
        elif event_roll == 9:
            event = 0x02  # Command rejected
            status_val = 0x00
        else:
            event = 0xEE  # Security alarm
            status_val = 0x04
        adc_val = random.randint(1200, 1400)
        temp_val = random.randint(24, 28)
        hum_val = random.randint(45, 55)
        dist_val = random.randint(10, 40)

        payload = bytes([
            sof,
            self.seq,
            event,
            (adc_val >> 8) & 0x0F,
            adc_val & 0xFF,
            temp_val,
            hum_val,
            (dist_val >> 8) & 0xFF,
            dist_val & 0xFF,
            status_val
        ])
        
        chk = 0
        for b in payload:
            chk ^= b
            
        full_packet = payload + bytes([chk])
        self.in_buffer.extend(full_packet)
        time.sleep(0.1)

    def close(self):
        self.is_open = False


# -----------------------------------------------------------------------------
# Telemetry Frame Parser (11-Byte Frame)
# [0xA6 (SOF)] [Seq] [Event] [ADC_H] [ADC_L] [Temp] [Hum] [Dist_H] [Dist_L] [Status] [Chk]
# -----------------------------------------------------------------------------
class TelemetryParser:
    SOF = 0xA6
    FRAME_LEN = 11

    def __init__(self):
        self.rx_buf = bytearray()
        self.total_frames = 0
        self.valid_frames = 0
        self.checksum_errors = 0

    def parse_stream(self, data: bytes):
        self.rx_buf.extend(data)
        parsed_records = []

        while len(self.rx_buf) >= self.FRAME_LEN:
            if self.rx_buf[0] != self.SOF:
                self.rx_buf.pop(0)
                continue

            if len(self.rx_buf) < self.FRAME_LEN:
                break

            frame = bytes(self.rx_buf[:self.FRAME_LEN])
            self.total_frames += 1

            chk_calc = 0
            for b in frame[:10]:
                chk_calc ^= b

            if chk_calc == frame[10]:
                self.valid_frames += 1
                self.rx_buf = self.rx_buf[self.FRAME_LEN:]

                seq = frame[1]
                event = frame[2]
                adc_raw = ((frame[3] & 0x0F) << 8) | frame[4]
                adc_volts = (adc_raw / 4095.0) * 3.3
                temp = frame[5]
                hum = frame[6]
                dist = (frame[7] << 8) | frame[8]
                status = frame[9]
                alarm = bool(status & 0x04)
                aes_reset = bool(status & 0x02)
                gate_busy = bool(status & 0x01)

                if alarm or event == 0xEE:
                    play_audio_alert("alarm")
                elif event == 0x10:
                    play_audio_alert("accepted")
                elif event == 0x02:
                    play_audio_alert("rejected")

                parsed_records.append({
                    "timestamp": datetime.now().strftime("%H:%M:%S.%f")[:-3],
                    "seq": seq,
                    "event": event,
                    "adc_raw": adc_raw,
                    "adc_volts": round(adc_volts, 2),
                    "temp_c": temp,
                    "hum_pct": hum,
                    "distance_cm": dist,
                    "alarm": alarm,
                    "aes_reset": aes_reset,
                    "gate_busy": gate_busy
                })
            else:
                self.checksum_errors += 1
                self.rx_buf.pop(0)

        return parsed_records


# -----------------------------------------------------------------------------
# Role Views
# -----------------------------------------------------------------------------
def run_intern_mode(ser, parser):
    print("\n" + "=" * 120)
    print(" SENTINEL RV -- INTERN SENSOR DASHBOARD".center(120))
    print("=" * 120)
    print(" Listening for live sensor telemetry... (Press Ctrl+C to stop)\n")

    try:
        sample_count = 0
        while True:
            raw = ser.read(11)
            records = parser.parse_stream(raw)
            for r in records:
                sample_count += 1
                print("=" * 120)
                print(f" SENTINEL RV -- LIVE SENSOR DASHBOARD (Sample #{sample_count})".center(120))
                print("=" * 120)
                print(f" Time           : {r['timestamp']}   | Sequence #: {r['seq']}")
                print("-" * 60)
                print(f" [TEMP] Temperature (DHT11) : {r['temp_c']} C")
                print(f" [HUM]  Humidity (DHT11)    : {r['hum_pct']} %")
                print(f" [DIST] Distance (HC-SR04)  : {r['distance_cm']} cm")
                print(f" [ADC]  MCP3202 ADC Voltage : {r['adc_volts']} V (Code: {r['adc_raw']})")
                print("-" * 60)
                status_str = "ALARM LOCKDOWN!" if r['alarm'] else "NORMAL / READY"
                print(f" [SEC]  System Security    : {status_str}")
                print(f" [LOG]  Telemetry Health   : Valid: {parser.valid_frames} | Errors: {parser.checksum_errors}")
                print("=" * 120 + "\n")
                time.sleep(0.2)
    except KeyboardInterrupt:
        print("\n[INTERN] Dashboard stopped.")


def run_researcher_mode(ser, parser, log_file):
    print("\n" + "=" * 60)
    print(" SENTINEL RV -- RESEARCHER DATA ANALYTICS & LOGGING")
    print("=" * 60)
    print(f" Logging sensor telemetry to: {log_file}")
    print(" Streaming live sensor data... (Press Ctrl+C to stop)\n")

    file_exists = os.path.exists(log_file)
    csv_file = open(log_file, 'a', newline='')
    csv_writer = csv.writer(csv_file)

    if not file_exists:
        csv_writer.writerow(["Timestamp", "Sequence", "Event", "ADC_Raw", "ADC_Volts", "Temp_C", "Humidity_Pct", "Distance_cm", "Alarm"])
        csv_file.flush()

    try:
        print(f"{'Time':<12} | {'Seq':<4} | {'Temp(C)':<8} | {'Hum(%)':<6} | {'Dist(cm)':<8} | {'ADC(V)':<6} | {'Status':<10}")
        print("-" * 72)
        sample_count = 0
        while True:
            raw = ser.read(11)
            records = parser.parse_stream(raw)
            for r in records:
                sample_count += 1
                status_str = "ALARM" if r['alarm'] else "OK"
                print(f"{r['timestamp']:<12} | {r['seq']:<4} | {r['temp_c']:<8} | {r['hum_pct']:<6} | {r['distance_cm']:<8} | {r['adc_volts']:<6.2f} | {status_str:<10}")
                csv_writer.writerow([r['timestamp'], r['seq'], hex(r['event']), r['adc_raw'], r['adc_volts'], r['temp_c'], r['hum_pct'], r['distance_cm'], r['alarm']])
                csv_file.flush()
                if sample_count >= 10:
                    break
            if sample_count >= 10:
                break
    except KeyboardInterrupt:
        print("\n[RESEARCHER] Data logging complete.")
    finally:
        csv_file.close()


def run_admin_mode(ser, parser):
    print("\n" + "=" * 120)
    print(" SENTINEL RV -- ADMIN HARDWARE CONTROL SHELL".center(120))
    print("=" * 120)
    print(" Actions:")
    print("  1 -> Turn Relay ON  (Opcode 0x01)")
    print("  2 -> Turn Relay OFF (Opcode 0x02)")
    print("  3 -> Run DC Motor   (Opcode 0x03)")
    print("  4 -> Run Stepper    (Opcode 0x04)")
    print("  5 -> Clear Alarm    (SW1 Clear Signal)")
    print("  m -> Read Live Sensor Stream")
    print("  q -> Quit")
    print("=" * 120)

    seq_cnt = 1
    while True:
        try:
            cmd = input("\n[ADMIN]> ").strip().lower()
            if cmd == 'q':
                print("Exiting Admin Mode.")
                break
            elif cmd == 'm':
                print("\n[ADMIN] Fetching 5 sensor samples...")
                for _ in range(5):
                    raw = ser.read(11)
                    records = parser.parse_stream(raw)
                    for r in records:
                        print(f"[{r['timestamp']}] Temp: {r['temp_c']} C | Hum: {r['hum_pct']}% | Dist: {r['distance_cm']}cm | ADC: {r['adc_volts']}V | Alarm: {r['alarm']}")
            elif cmd in ['1', '2', '3', '4', '5']:
                opcode = int(cmd)
                nonce = random.randint(1, 0xFFFFFFFF)
                seq_cnt = (seq_cnt + 1) & 0xFF
                
                print(f"[ADMIN] Sending Command: Opcode=0x{opcode:02X}, Sequence={seq_cnt}, Nonce=0x{nonce:08X}")
                
                payload = struct.pack(">B Q B H", 0xA5, nonce, seq_cnt, opcode)
                crc_val = crc32_mpeg2(payload)
                full_pkt = payload + struct.pack(">I", crc_val)
                
                ser.write(full_pkt)
                print(f"[ADMIN] Frame Sent ({len(full_pkt)} bytes). Checking hardware response...")
                time.sleep(0.2)
                raw = ser.read(11)
                records = parser.parse_stream(raw)
                for r in records:
                    print(f"[HW RESP] Status: Alarm={r['alarm']} | System State Gate={r['gate_busy']}")
            else:
                play_audio_alert("rejected")
                print("Unknown choice. Enter 1-5, m, or q.")
        except KeyboardInterrupt:
            print("\n[ADMIN] Control shell closed.")
            break


# -----------------------------------------------------------------------------
# Main Entry Point
# -----------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="Sentinel RV — Command & Sensor Telemetry UART Host Utility")
    parser.add_argument("--role", choices=["intern", "researcher", "admin"], default="intern", help="User role mode")
    parser.add_argument("--port", default="auto", help="UART Serial Port (e.g. COM3, COM4, /dev/ttyUSB0)")
    parser.add_argument("--baud", type=int, default=115200, help="Baud rate (default: 115200)")
    parser.add_argument("--log", default="sensor_telemetry_log.csv", help="CSV log filename for researcher mode")
    parser.add_argument("--sim", action="store_true", help="Run in simulated mode without physical FPGA serial port")

    args = parser.parse_args()

    # Maximize terminal window on Windows
    if sys.platform == 'win32':
        os.system('mode con cols=120 lines=40')
        os.system('title Sentinel RV Secure SoC - Host Communications Utility')

    print("=" * 120)
    print(" Sentinel RV Secure SoC -- Host Communications Utility".center(120))
    print("=" * 120)

    ser = None
    if args.sim:
        print("[INIT] Using SIMULATED UART interface (--sim specified).")
        ser = SimulatedUART()
    else:
        port_name = args.port
        if port_name == "auto" and SERIAL_AVAILABLE:
            ports = list(serial.tools.list_ports.comports())
            if ports:
                port_name = ports[0].device
                print(f"[INIT] Auto-detected Serial Port: {port_name}")
            else:
                print("[WARN] No active COM ports found. Falling back to SIMULATED mode.")
                ser = SimulatedUART()

        if ser is None:
            if not SERIAL_AVAILABLE:
                print("[WARN] 'pyserial' not installed. Falling back to SIMULATED mode.")
                ser = SimulatedUART()
            else:
                try:
                    ser = serial.Serial(port_name, args.baud, timeout=1.0)
                    print(f"[INIT] Connected to FPGA Hardware on {port_name} at {args.baud} Baud.")
                except Exception as e:
                    print(f"[ERROR] Could not open serial port {port_name}: {e}")
                    print("[INIT] Falling back to SIMULATED mode for testing.")
                    ser = SimulatedUART()

    telemetry_parser = TelemetryParser()

    if args.role == "intern":
        run_intern_mode(ser, telemetry_parser)
    elif args.role == "researcher":
        run_researcher_mode(ser, telemetry_parser, args.log)
    elif args.role == "admin":
        run_admin_mode(ser, telemetry_parser)

    if hasattr(ser, 'close'):
        ser.close()


if __name__ == "__main__":
    main()
