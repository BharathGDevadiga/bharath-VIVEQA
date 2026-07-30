"""
read_sd_log.py — Read raw SD sectors written by the Sentinel RV FPGA.

MUST be run as Administrator because reading raw disk sectors requires
elevated privileges on Windows.

Usage (as Administrator):
    py read_sd_log.py

The script auto-detects removable drives. If multiple are found, it
prompts you to choose. It reads sectors 2048..2055 (the audit log area)
and displays the contents.
"""

import ctypes
import sys
import os
import string

SECTOR_SIZE = 512
FIRST_SECTOR = 2048
NUM_SECTORS = 8  # Read sectors 2048..2055


def is_admin():
    """Check if the script is running with administrator privileges."""
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception:
        return False


def find_removable_drives():
    """Find all removable drives (USB card readers, SD cards)."""
    drives = []
    kernel32 = ctypes.windll.kernel32
    for letter in string.ascii_uppercase:
        path = f"{letter}:\\"
        drive_type = kernel32.GetDriveTypeW(path)
        # 2 = DRIVE_REMOVABLE
        if drive_type == 2:
            drives.append(letter)
    return drives


def get_physical_drive_number(drive_letter):
    """Get the physical drive number for a given drive letter."""
    import ctypes.wintypes

    GENERIC_READ = 0x80000000
    FILE_SHARE_READ = 0x00000001
    FILE_SHARE_WRITE = 0x00000002
    OPEN_EXISTING = 3
    IOCTL_VOLUME_GET_VOLUME_DISK_EXTENTS = 0x00560000

    volume_path = f"\\\\.\\{drive_letter}:"
    handle = ctypes.windll.kernel32.CreateFileW(
        volume_path,
        GENERIC_READ,
        FILE_SHARE_READ | FILE_SHARE_WRITE,
        None,
        OPEN_EXISTING,
        0,
        None,
    )

    if handle == -1 or handle == 0xFFFFFFFFFFFFFFFF:
        return None

    class DISK_EXTENT(ctypes.Structure):
        _fields_ = [
            ("DiskNumber", ctypes.wintypes.DWORD),
            ("StartingOffset", ctypes.c_longlong),
            ("ExtentLength", ctypes.c_longlong),
        ]

    class VOLUME_DISK_EXTENTS(ctypes.Structure):
        _fields_ = [
            ("NumberOfDiskExtents", ctypes.wintypes.DWORD),
            ("Extents", DISK_EXTENT * 1),
        ]

    extents = VOLUME_DISK_EXTENTS()
    bytes_returned = ctypes.wintypes.DWORD(0)

    result = ctypes.windll.kernel32.DeviceIoControl(
        handle,
        IOCTL_VOLUME_GET_VOLUME_DISK_EXTENTS,
        None,
        0,
        ctypes.byref(extents),
        ctypes.sizeof(extents),
        ctypes.byref(bytes_returned),
        None,
    )

    ctypes.windll.kernel32.CloseHandle(handle)

    if result:
        return extents.Extents[0].DiskNumber
    return None


def read_sector(disk_handle, sector_number):
    """Read a single 512-byte sector from a raw disk handle."""
    offset = sector_number * SECTOR_SIZE
    # Seek to the sector
    high = ctypes.c_long(offset >> 32)
    low = ctypes.windll.kernel32.SetFilePointer(
        disk_handle, offset & 0xFFFFFFFF, ctypes.byref(high), 0
    )
    if low == 0xFFFFFFFF and ctypes.GetLastError() != 0:
        return None

    buf = ctypes.create_string_buffer(SECTOR_SIZE)
    bytes_read = ctypes.wintypes.DWORD(0)
    ok = ctypes.windll.kernel32.ReadFile(
        disk_handle, buf, SECTOR_SIZE, ctypes.byref(bytes_read), None
    )
    if not ok or bytes_read.value != SECTOR_SIZE:
        return None
    return bytes(buf)


def hexdump(data, offset=0):
    """Pretty-print a hex dump of binary data."""
    lines = []
    for i in range(0, len(data), 16):
        chunk = data[i : i + 16]
        hex_part = " ".join(f"{b:02X}" for b in chunk)
        ascii_part = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
        lines.append(f"  {offset + i:04X}  {hex_part:<48s}  {ascii_part}")
    return "\n".join(lines)


def analyze_record(sector_num, data):
    """Analyze a 32-byte audit record at the start of a sector."""
    record = data[:32]
    if all(b == 0 for b in record):
        return "  [Empty sector — no record written]"

    metadata = record[:16]
    digest = record[16:32]

    lines = []
    lines.append(f"  Metadata: {metadata.hex(' ').upper()}")
    lines.append(f"  Digest:   {digest.hex(' ').upper()}")

    fmt_byte = metadata[0]
    source_id = metadata[1]
    opcode = metadata[2]
    argument = (metadata[3] << 8) | metadata[4]
    sequence = metadata[5]
    status = metadata[6]
    adc_hi = metadata[7]
    adc_lo = metadata[8]
    adc_val = ((adc_hi & 0x0F) << 8) | adc_lo

    dht_temp = metadata[9]
    dht_hum = metadata[10]
    distance = (metadata[11] << 8) | metadata[12]

    source_names = {0x01: "PMOD UART", 0x02: "ESP32 UART", 0x03: "CPU"}
    opcode_names = {0x01: "Relay SET", 0x02: "Relay RESET", 0x03: "Motor", 0x04: "Stepper"}

    lines.append(f"  Format:    0x{fmt_byte:02X}")
    lines.append(f"  Source:    0x{source_id:02X} ({source_names.get(source_id, 'Unknown')})")
    lines.append(f"  Opcode:    0x{opcode:02X} ({opcode_names.get(opcode, 'Unknown')})")
    lines.append(f"  Argument:  0x{argument:04X}")
    lines.append(f"  Sequence:  0x{sequence:02X}")

    accepted = bool(status & 0x01)
    alarm = bool(status & 0x02)
    lines.append(f"  Status:    0x{status:02X} (Accepted={accepted}, Alarm={alarm})")
    lines.append(f"  ADC:       {adc_val} (0x{adc_val:03X})")
    lines.append(f"  Temp:      {dht_temp}C")
    lines.append(f"  Humidity:  {dht_hum}%")
    lines.append(f"  Distance:  {distance} cm")

    return "\n".join(lines)


def main():
    if not is_admin():
        print("ERROR: This script must be run as Administrator.")
        print("Right-click PowerShell -> 'Run as Administrator', then run this script.")
        sys.exit(1)

    print("=" * 60)
    print("  Sentinel RV — SD Audit Log Reader")
    print("=" * 60)

    # Find removable drives
    drives = find_removable_drives()
    if not drives:
        print("\nNo removable drives found.")
        print("Make sure the SD card is inserted in a card reader.")
        sys.exit(1)

    print(f"\nFound removable drive(s): {', '.join(d + ':' for d in drives)}")

    if len(drives) == 1:
        chosen = drives[0]
    else:
        chosen = input("Enter drive letter to read: ").strip().upper()
        if chosen not in drives:
            print(f"Drive {chosen}: is not a removable drive.")
            sys.exit(1)

    # Get physical drive number
    phys_num = get_physical_drive_number(chosen)
    if phys_num is None:
        print(f"Could not determine physical drive for {chosen}:")
        sys.exit(1)

    print(f"Drive {chosen}: is physical disk {phys_num}")

    # Open physical drive for raw reading
    GENERIC_READ = 0x80000000
    FILE_SHARE_READ = 0x00000001
    FILE_SHARE_WRITE = 0x00000002
    OPEN_EXISTING = 3

    disk_path = f"\\\\.\\PhysicalDrive{phys_num}"
    handle = ctypes.windll.kernel32.CreateFileW(
        disk_path,
        GENERIC_READ,
        FILE_SHARE_READ | FILE_SHARE_WRITE,
        None,
        OPEN_EXISTING,
        0,
        None,
    )

    if handle == -1 or handle == 0xFFFFFFFFFFFFFFFF:
        err = ctypes.GetLastError()
        print(f"Failed to open {disk_path} (error {err}).")
        print("Make sure you are running as Administrator.")
        sys.exit(1)

    print(f"\nReading sectors {FIRST_SECTOR}..{FIRST_SECTOR + NUM_SECTORS - 1}:")
    print("-" * 60)

    found_data = False
    for i in range(NUM_SECTORS):
        sector_num = FIRST_SECTOR + i
        data = read_sector(handle, sector_num)

        if data is None:
            print(f"\nSector {sector_num}: READ FAILED")
            continue

        has_data = any(b != 0 for b in data[:32])

        if has_data:
            found_data = True
            print(f"\nSector {sector_num}: DATA FOUND")
            print(hexdump(data[:64], 0))
            print()
            print(analyze_record(sector_num, data))
        else:
            print(f"\nSector {sector_num}: Empty")

    ctypes.windll.kernel32.CloseHandle(handle)

    print("-" * 60)
    if not found_data:
        print("\nNo audit records found in sectors 2048..2055.")
        print("Possible causes:")
        print("  1. SD card init failed (check L4/L8 LEDs)")
        print("  2. No audit event was triggered")
        print("  3. Wrong SD card inserted")
    else:
        print("\nDone. Audit records shown above.")

    print()


if __name__ == "__main__":
    main()
