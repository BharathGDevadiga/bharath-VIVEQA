import sys
import os
import ctypes
import ctypes.wintypes
import string
import time
import threading
import customtkinter as ctk

# Windows Laptop Speaker Audio (Burglar Alarm Siren + Silent Normal Operation)
try:
    import winsound
    def play_sound(sound_type="chime"):
        try:
            if sound_type == "alarm":
                # LOUD BURGLAR ALARM SIREN ON LAPTOP SPEAKER
                winsound.PlaySound("SystemExclamation", winsound.SND_ALIAS | winsound.SND_ASYNC)
            elif sound_type == "error":
                winsound.PlaySound("SystemHand", winsound.SND_ALIAS | winsound.SND_ASYNC)
            elif sound_type == "success":
                pass  # Completely silent during normal live telemetry (NO TAK SOUND!)
            else:
                pass
        except Exception:
            pass
except Exception:
    def play_sound(sound_type="chime"):
        pass

# Suppress console window in frozen GUI mode
if getattr(sys, 'frozen', False):
    sys.stdout = open(os.devnull, 'w')
    sys.stderr = open(os.devnull, 'w')

ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

SECTOR_SIZE = 512
FIRST_SECTOR = 2048
NUM_SECTORS = 8

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception:
        return False

def find_removable_drives():
    drives = []
    if sys.platform == 'win32':
        try:
            kernel32 = ctypes.windll.kernel32
            for letter in string.ascii_uppercase:
                path = f"{letter}:\\"
                if kernel32.GetDriveTypeW(path) == 2:  # DRIVE_REMOVABLE
                    drives.append(letter)
        except Exception:
            pass
    return drives

def get_physical_drive_number(drive_letter):
    GENERIC_READ = 0x80000000
    FILE_SHARE_READ = 0x00000001
    FILE_SHARE_WRITE = 0x00000002
    OPEN_EXISTING = 3
    IOCTL_VOLUME_GET_VOLUME_DISK_EXTENTS = 0x00560000

    volume_path = f"\\\\.\\{drive_letter}:"
    try:
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
    except Exception:
        pass
    return None

def open_disk_handle(drive_letter):
    GENERIC_READ = 0x80000000
    FILE_SHARE_READ = 0x00000001
    FILE_SHARE_WRITE = 0x00000002
    OPEN_EXISTING = 3

    disk_num = get_physical_drive_number(drive_letter)
    if disk_num is not None:
        target_path = f"\\\\.\\PhysicalDrive{disk_num}"
    else:
        target_path = f"\\\\.\\{drive_letter}:"

    try:
        handle = ctypes.windll.kernel32.CreateFileW(
            target_path,
            GENERIC_READ,
            FILE_SHARE_READ | FILE_SHARE_WRITE,
            None,
            OPEN_EXISTING,
            0,
            None,
        )
        if handle != -1 and handle != 0xFFFFFFFFFFFFFFFF:
            return handle
    except Exception:
        pass
    return None

def read_sector(disk_handle, sector_number):
    offset = sector_number * SECTOR_SIZE
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

def parse_sector_payload(data):
    record = data[:32]
    if all(b == 0 for b in record) or all(b == 0xFF for b in record):
        return None

    metadata = record[:16]
    digest = record[16:32]

    fmt_byte = metadata[0]
    source_id = metadata[1]
    opcode = metadata[2]
    argument = (metadata[3] << 8) | metadata[4]
    sequence = metadata[5]
    status = metadata[6]
    adc_val = round((((metadata[7] & 0x0F) << 8) | metadata[8]) * 3.3 / 4095.0, 2)
    dht_temp = metadata[9]
    dht_hum = metadata[10]
    distance = (metadata[11] << 8) | metadata[12]

    return {
        "fmt": fmt_byte,
        "source": source_id,
        "opcode": opcode,
        "arg": argument,
        "seq": sequence,
        "status": status,
        "adc": adc_val,
        "temp": dht_temp,
        "hum": dht_hum,
        "dist": distance,
        "meta_hex": metadata.hex(' ').upper(),
        "hash_hex": digest.hex(' ').upper()
    }

def decode_sector_record(sector_num, data):
    info = parse_sector_payload(data)
    if not info:
        return f"  [SECTOR {sector_num}] Unwritten / Empty Log Sector"

    source_names = {0x01: "PMOD UART", 0x02: "ESP32 UART", 0x03: "CPU"}
    opcode_names = {0x01: "Relay SET (ON)", 0x02: "Relay RESET (OFF)", 0x03: "Motor", 0x04: "Stepper"}

    accepted = bool(info["status"] & 0x01)
    alarm = bool(info["status"] & 0x02)

    lines = []
    lines.append(f"════════════════════════════════════════════════════════════════════════════")
    lines.append(f"  SECTOR {sector_num} AUDIT RECORD")
    lines.append(f"────────────────────────────────────────────────────────────────────────────")
    lines.append(f"  Format Code  : 0x{info['fmt']:02X}")
    lines.append(f"  Source       : 0x{info['source']:02X} ({source_names.get(info['source'], 'Unknown')})")
    lines.append(f"  Command Opcode: 0x{info['opcode']:02X} ({opcode_names.get(info['opcode'], 'Custom Action')})")
    lines.append(f"  Sequence #   : 0x{info['seq']:02X} | Argument: 0x{info['arg']:04X}")
    lines.append(f"  Status       : Accepted={accepted} | Security Alarm={alarm}")
    lines.append(f"  LOGGED SENSORS: Temp={info['temp']}°C | Hum={info['hum']}% | Dist={info['dist']}cm | ADC={info['adc']}V")
    lines.append(f"  Metadata Hex : {info['meta_hex']}")
    lines.append(f"  128-bit Hash : {info['hash_hex']}")
    lines.append(f"════════════════════════════════════════════════════════════════════════════")

    return "\n".join(lines)


class SDInspectorApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("Sentinel RV - MicroSD Security Audit Log Inspector")
        self.geometry("1180x750")
        self.minsize(800, 550)
        self.resizable(True, True)
        
        self.users = {
            "researcher": {"pass": "1234", "role": "RESEARCHER"},
            "admin": {"pass": "admin", "role": "ADMIN"}
        }
        self.current_user = None
        self.current_role = None
        self.is_running = True
        
        self.login_frame = ctk.CTkFrame(self)
        self.dashboard_frame = ctk.CTkFrame(self)
        
        self.setup_login_frame()
        self.setup_dashboard_frame()
        
        self.show_frame(self.login_frame)
        self.protocol("WM_DELETE_WINDOW", self.on_close)

    def show_frame(self, frame):
        self.login_frame.pack_forget()
        self.dashboard_frame.pack_forget()
        frame.pack(fill="both", expand=True)

    def setup_login_frame(self):
        card = ctk.CTkFrame(self.login_frame, corner_radius=15)
        card.place(relx=0.5, rely=0.5, anchor="center", relwidth=0.45, relheight=0.65)
        
        ctk.CTkLabel(card, text="💾 MicroSD Audit Log Inspector", font=ctk.CTkFont(size=24, weight="bold")).pack(pady=(35, 5))
        ctk.CTkLabel(card, text="Authorized Security Audit Login", font=ctk.CTkFont(size=14), text_color="gray").pack(pady=(0, 25))
        
        self.user_entry = ctk.CTkEntry(card, placeholder_text="Username", width=280, height=42)
        self.user_entry.pack(pady=10)
        
        self.pass_entry = ctk.CTkEntry(card, placeholder_text="Password", show="*", width=280, height=42)
        self.pass_entry.pack(pady=10)
        
        # Bind ENTER key to trigger attempt_login and return 'break' to suppress default OS ding
        self.user_entry.bind("<Return>", self.attempt_login)
        self.pass_entry.bind("<Return>", self.attempt_login)
        
        self.login_err = ctk.CTkLabel(card, text="", text_color="#ff4d4d", font=ctk.CTkFont(size=12))
        self.login_err.pack(pady=5)
        
        ctk.CTkButton(card, text="ACCESS AUDIT LOGS", width=280, height=45, font=ctk.CTkFont(weight="bold"), command=self.attempt_login).pack(pady=20)

    def attempt_login(self, event=None):
        user = self.user_entry.get().lower().strip()
        pwd = self.pass_entry.get()
        
        if user in self.users and self.users[user]["pass"] == pwd:
            play_sound("success")
            self.current_user = user
            self.current_role = self.users[user]["role"]
            self.show_frame(self.dashboard_frame)
            self.user_hdr_lbl.configure(text=f"User: {self.current_user.capitalize()} ({self.current_role})")
            
            drives = find_removable_drives()
            if not drives:
                self.log("NO MICROSD CARD DETECTED. Please insert the FPGA MicroSD card into your laptop card reader.")
            else:
                self.log(f"Removable MicroSD drive(s) detected: {', '.join(drives)}. Click SCAN & DECODE SECTORS.")
        else:
            play_sound("error")
            self.login_err.configure(text="Invalid login. Use researcher / admin")
        return "break"

    def setup_dashboard_frame(self):
        header = ctk.CTkFrame(self.dashboard_frame, height=55, fg_color="#1e1e24", corner_radius=0)
        header.pack(fill="x", side="top")
        
        ctk.CTkLabel(header, text="💾 MicroSD Security Audit Log Reader", font=ctk.CTkFont(size=18, weight="bold")).pack(side="left", padx=20)
        self.user_hdr_lbl = ctk.CTkLabel(header, text="User: Admin", font=ctk.CTkFont(size=13), text_color="#a4b0be")
        self.user_hdr_lbl.pack(side="left", padx=20)
        
        ctk.CTkButton(header, text="LOGOUT", width=80, fg_color="#c93434", hover_color="#9e2828", command=self.logout).pack(side="right", padx=20)

        main_layout = ctk.CTkFrame(self.dashboard_frame, fg_color="transparent")
        main_layout.pack(fill="both", expand=True, padx=15, pady=10)
        
        left_panel = ctk.CTkFrame(main_layout)
        left_panel.pack(side="left", fill="both", expand=True, padx=(0, 10))
        
        sd_ctrl = ctk.CTkFrame(left_panel, height=50)
        sd_ctrl.pack(fill="x", padx=15, pady=15)
        
        ctk.CTkLabel(sd_ctrl, text="Select SD Drive:", font=ctk.CTkFont(weight="bold")).pack(side="left", padx=10)
        
        drives = find_removable_drives()
        if not drives:
            drives = ["No Removable Drive"]
            
        self.drive_var = ctk.StringVar(value=drives[0])
        self.drive_dropdown = ctk.CTkOptionMenu(sd_ctrl, variable=self.drive_var, values=drives, width=180)
        self.drive_dropdown.pack(side="left", padx=10)
        
        ctk.CTkButton(sd_ctrl, text="🔄 REFRESH DRIVES", width=130, fg_color="#2c3e50", command=self.refresh_drives).pack(side="left", padx=5)
        ctk.CTkButton(sd_ctrl, text="🔍 SCAN & DECODE SECTORS", font=ctk.CTkFont(weight="bold"), fg_color="#00b894", hover_color="#009475", command=self.scan_sd_card).pack(side="right", padx=10)

        ctk.CTkLabel(left_panel, text="RAW HARDWARE SECTOR AUDIT RECORDS (Sectors 2048 - 2055)", font=ctk.CTkFont(size=12, weight="bold")).pack(anchor="w", padx=15, pady=(5, 2))
        
        self.log_box = ctk.CTkTextbox(left_panel, font=ctk.CTkFont(family="Consolas", size=11))
        self.log_box.pack(fill="both", expand=True, padx=15, pady=(0, 15))
        self.log_box.configure(state="disabled")

        # Right Sidebar: Sector-by-Sector Sensor Difference Table (Down by Down)
        right_sidebar = ctk.CTkFrame(main_layout, width=440, fg_color="#1e1e24", corner_radius=12)
        right_sidebar.pack(side="right", fill="both", expand=False, padx=(5, 0))
        
        ctk.CTkLabel(right_sidebar, text="📊 SECTOR SENSOR LOG TABLE", font=ctk.CTkFont(size=15, weight="bold"), text_color="#74b9ff").pack(pady=(15, 5))
        ctk.CTkLabel(right_sidebar, text="Row-by-Row Sensor Differences Down Sector 2048-2055", font=ctk.CTkFont(size=11), text_color="gray").pack(pady=(0, 10))

        # Table Container
        table_container = ctk.CTkFrame(right_sidebar, fg_color="#2b2b36", corner_radius=8)
        table_container.pack(fill="both", expand=True, padx=10, pady=(0, 10))

        # Table Header Row
        hdr_row = ctk.CTkFrame(table_container, fg_color="#1f242d", height=32, corner_radius=4)
        hdr_row.pack(fill="x", padx=4, pady=(4, 2))
        
        ctk.CTkLabel(hdr_row, text="Sector", font=ctk.CTkFont(size=11, weight="bold"), width=55, text_color="#a4b0be").pack(side="left", padx=2)
        ctk.CTkLabel(hdr_row, text="Temp", font=ctk.CTkFont(size=11, weight="bold"), width=55, text_color="#ff7675").pack(side="left", padx=2)
        ctk.CTkLabel(hdr_row, text="Hum", font=ctk.CTkFont(size=11, weight="bold"), width=55, text_color="#74b9ff").pack(side="left", padx=2)
        ctk.CTkLabel(hdr_row, text="Dist", font=ctk.CTkFont(size=11, weight="bold"), width=55, text_color="#55efc4").pack(side="left", padx=2)
        ctk.CTkLabel(hdr_row, text="ADC", font=ctk.CTkFont(size=11, weight="bold"), width=55, text_color="#ffeaa7").pack(side="left", padx=2)
        ctk.CTkLabel(hdr_row, text="Event", font=ctk.CTkFont(size=11, weight="bold"), width=90, text_color="#fd79a8").pack(side="left", padx=2)

        # Scrollable Frame for Table Rows (Down by Down)
        self.table_scroll = ctk.CTkScrollableFrame(table_container, fg_color="transparent")
        self.table_scroll.pack(fill="both", expand=True, padx=2, pady=2)
        
        self.row_labels = []
        self.init_empty_table()

        self.lbl_side_sec = ctk.CTkLabel(right_sidebar, text="● READY TO SCAN MICROSD", font=ctk.CTkFont(size=12, weight="bold"), text_color="#e67e22")
        self.lbl_side_sec.pack(pady=10)

    def init_empty_table(self):
        for widget in self.table_scroll.winfo_children():
            widget.destroy()
        self.row_labels.clear()

        for s in range(FIRST_SECTOR, FIRST_SECTOR + NUM_SECTORS):
            row_frame = ctk.CTkFrame(self.table_scroll, fg_color="#343542", height=28, corner_radius=3)
            row_frame.pack(fill="x", pady=2)

            l_sec = ctk.CTkLabel(row_frame, text=f"S-{s}", font=ctk.CTkFont(size=11, weight="bold"), width=55)
            l_sec.pack(side="left", padx=2)

            l_temp = ctk.CTkLabel(row_frame, text="-- °C", font=ctk.CTkFont(size=11), width=55)
            l_temp.pack(side="left", padx=2)

            l_hum = ctk.CTkLabel(row_frame, text="-- %", font=ctk.CTkFont(size=11), width=55)
            l_hum.pack(side="left", padx=2)

            l_dist = ctk.CTkLabel(row_frame, text="-- cm", font=ctk.CTkFont(size=11), width=55)
            l_dist.pack(side="left", padx=2)

            l_adc = ctk.CTkLabel(row_frame, text="-- V", font=ctk.CTkFont(size=11), width=55)
            l_adc.pack(side="left", padx=2)

            l_event = ctk.CTkLabel(row_frame, text="Empty", font=ctk.CTkFont(size=10), width=90, text_color="gray")
            l_event.pack(side="left", padx=2)

            self.row_labels.append({
                "sec": l_sec,
                "temp": l_temp,
                "hum": l_hum,
                "dist": l_dist,
                "adc": l_adc,
                "event": l_event,
                "frame": row_frame
            })

    def refresh_drives(self):
        drives = find_removable_drives()
        if not drives:
            drives = ["No Removable Drive"]
        self.drive_dropdown.configure(values=drives)
        self.drive_var.set(drives[0])
        self.log(f"Drive list refreshed. Active drive: {drives[0]}")

    def scan_sd_card(self):
        drive_str = self.drive_var.get().split()[0]
        if drive_str == "No":
            play_sound("error")
            self.log("NO MICROSD CARD DETECTED. Please insert the FPGA MicroSD card into your card reader.")
            return

        play_sound("success")
        self.log(f"Scanning sector log from MicroSD drive {drive_str}:\\ ...")
        
        handle = open_disk_handle(drive_str)
        if handle is None:
            play_sound("error")
            self.log_box.configure(state="normal")
            self.log_box.delete("1.0", "end")
            self.log_box.insert("end", f"⚠️ DRIVE ACCESS DENIED on {drive_str}:\\\n\n")
            self.log_box.insert("end", "Reading raw physical disk sectors requires Administrator privileges on Windows.\n")
            self.log_box.insert("end", "To fix: Right-click SD_Log_Inspector_App.exe -> 'Run as Administrator'.\n")
            self.log_box.see("end")
            self.log_box.configure(state="disabled")
            return

        decoded_output = []
        records_found = 0
        opcode_names = {0x01: "Relay ON", 0x02: "Relay OFF", 0x03: "Motor", 0x04: "Stepper"}
        
        try:
            for idx, s in enumerate(range(FIRST_SECTOR, FIRST_SECTOR + NUM_SECTORS)):
                sec_data = read_sector(handle, s)
                if sec_data:
                    info = parse_sector_payload(sec_data)
                    record_str = decode_sector_record(s, sec_data)
                    decoded_output.append(record_str)
                    
                    if info and idx < len(self.row_labels):
                        records_found += 1
                        row = self.row_labels[idx]
                        row["temp"].configure(text=f"{info['temp']}°C", text_color="#ff7675")
                        row["hum"].configure(text=f"{info['hum']}%", text_color="#74b9ff")
                        row["dist"].configure(text=f"{info['dist']}cm", text_color="#55efc4")
                        row["adc"].configure(text=f"{info['adc']}V", text_color="#ffeaa7")
                        
                        evt_name = opcode_names.get(info['opcode'], "Log Frame")
                        if info['status'] & 0x02:
                            evt_name = "ALARM!"
                            row["frame"].configure(fg_color="#4d1f24")
                        else:
                            row["frame"].configure(fg_color="#1e3799")
                            
                        row["event"].configure(text=evt_name, text_color="#ffffff")
                else:
                    decoded_output.append(f"  [SECTOR {s}] Read Error / Unreadable Sector")
            
            ctypes.windll.kernel32.CloseHandle(handle)
            play_sound("success")
            
            self.log_box.configure(state="normal")
            self.log_box.delete("1.0", "end")
            self.log_box.insert("end", f"MicroSD Raw Sector Scan Completed. Found {records_found} valid hardware audit records.\n\n")
            for record in decoded_output:
                self.log_box.insert("end", record + "\n\n")
            self.log_box.see("end")
            self.log_box.configure(state="disabled")
            
            if records_found > 0:
                self.lbl_side_sec.configure(text=f"● LOGGED {records_found} AUDIT SECTORS", text_color="#2ecc71")
            else:
                self.lbl_side_sec.configure(text="● SD CARD BLANK / NO LOGS", text_color="#e67e22")
            
        except Exception as e:
            if handle:
                ctypes.windll.kernel32.CloseHandle(handle)
            play_sound("error")
            self.log(f"Error reading sectors from {drive_str}: {str(e)}")

    def log(self, text):
        self.log_box.configure(state="normal")
        ts = time.strftime("%H:%M:%S")
        self.log_box.insert("end", f"[{ts}] {text}\n")
        self.log_box.see("end")
        self.log_box.configure(state="disabled")

    def logout(self):
        self.current_user = None
        self.current_role = None
        self.user_entry.delete(0, 'end')
        self.pass_entry.delete(0, 'end')
        self.login_err.configure(text="")
        self.show_frame(self.login_frame)

    def on_close(self):
        self.is_running = False
        self.destroy()

if __name__ == "__main__":
    app = SDInspectorApp()
    app.mainloop()
