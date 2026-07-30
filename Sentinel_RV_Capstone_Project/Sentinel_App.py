import os
import sys
import ctypes
import string
import time
import threading
import customtkinter as ctk

# ==========================================
# Administrator Elevation Check
# ==========================================
def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

if not is_admin():
    print("Elevating to Administrator...")
    ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, " ".join(sys.argv), None, 1)
    sys.exit()

# ==========================================
# SD Card Reading Logic
# ==========================================
SECTOR_SIZE = 512
FIRST_SECTOR = 2048
NUM_SECTORS = 8

def find_removable_drives():
    drives = []
    kernel32 = ctypes.windll.kernel32
    for letter in string.ascii_uppercase:
        path = f"{letter}:\\"
        if kernel32.GetDriveTypeW(path) == 2:  # DRIVE_REMOVABLE
            drives.append(letter)
    return drives

def get_physical_drive_number(drive_letter):
    GENERIC_READ = 0x80000000
    OPEN_EXISTING = 3
    IOCTL_VOLUME_GET_VOLUME_DISK_EXTENTS = 0x00560000

    volume_path = f"\\\\.\\{drive_letter}:"
    handle = ctypes.windll.kernel32.CreateFileW(
        volume_path, GENERIC_READ, 3, None, OPEN_EXISTING, 0, None
    )
    if handle == -1 or handle == 0xFFFFFFFFFFFFFFFF:
        return None

    class DISK_EXTENT(ctypes.Structure):
        _fields_ = [("DiskNumber", ctypes.wintypes.DWORD),
                    ("StartingOffset", ctypes.c_longlong),
                    ("ExtentLength", ctypes.c_longlong)]
    class VOLUME_DISK_EXTENTS(ctypes.Structure):
        _fields_ = [("NumberOfDiskExtents", ctypes.wintypes.DWORD),
                    ("Extents", DISK_EXTENT * 1)]

    extents = VOLUME_DISK_EXTENTS()
    bytes_returned = ctypes.wintypes.DWORD()

    result = ctypes.windll.kernel32.DeviceIoControl(
        handle, IOCTL_VOLUME_GET_VOLUME_DISK_EXTENTS,
        None, 0,
        ctypes.byref(extents), ctypes.sizeof(extents),
        ctypes.byref(bytes_returned), None
    )
    ctypes.windll.kernel32.CloseHandle(handle)
    if result:
        return extents.Extents[0].DiskNumber
    return None

def read_sector(handle, sector_index):
    offset = sector_index * SECTOR_SIZE
    # SetFilePointerEx
    ctypes.windll.kernel32.SetFilePointerEx(handle, ctypes.c_longlong(offset), None, 0)
    buffer = ctypes.create_string_buffer(SECTOR_SIZE)
    bytes_read = ctypes.wintypes.DWORD()
    result = ctypes.windll.kernel32.ReadFile(
        handle, buffer, SECTOR_SIZE, ctypes.byref(bytes_read), None
    )
    if result and bytes_read.value == SECTOR_SIZE:
        return buffer.raw
    return None

# ==========================================
# GUI Application
# ==========================================
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class SentinelDashboard(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("Sentinel RV - Secure Telemetry Dashboard")
        self.geometry("900x600")
        self.resizable(False, False)

        # Title
        self.title_label = ctk.CTkLabel(self, text="Sentinel RV Dashboard", font=ctk.CTkFont(size=28, weight="bold"))
        self.title_label.pack(pady=(20, 5))

        self.subtitle = ctk.CTkLabel(self, text="Secure Hardware Audit Log Reader", font=ctk.CTkFont(size=14), text_color="gray")
        self.subtitle.pack(pady=(0, 20))

        # Metrics Frame
        self.metrics_frame = ctk.CTkFrame(self, fg_color="transparent")
        self.metrics_frame.pack(pady=10, padx=20, fill="x")
        self.metrics_frame.grid_columnconfigure((0,1,2,3), weight=1)

        # Sensor Cards
        self.temp_var = ctk.StringVar(value="-- °C")
        self.hum_var = ctk.StringVar(value="-- %")
        self.dist_var = ctk.StringVar(value="-- cm")
        self.status_var = ctk.StringVar(value="WAITING")
        self.status_color = "gray"

        self.create_metric_card(self.metrics_frame, "Temperature", self.temp_var, 0)
        self.create_metric_card(self.metrics_frame, "Humidity", self.hum_var, 1)
        self.create_metric_card(self.metrics_frame, "Distance", self.dist_var, 2)
        
        self.status_card = ctk.CTkFrame(self.metrics_frame, corner_radius=15, fg_color="#2b2b2b")
        self.status_card.grid(row=0, column=3, padx=10, sticky="nsew")
        ctk.CTkLabel(self.status_card, text="Security Status", font=ctk.CTkFont(size=14)).pack(pady=(15,0))
        self.status_label = ctk.CTkLabel(self.status_card, textvariable=self.status_var, font=ctk.CTkFont(size=24, weight="bold"), text_color=self.status_color)
        self.status_label.pack(pady=(5,15))

        # Action Button
        self.scan_btn = ctk.CTkButton(self, text="SCAN SD CARD", font=ctk.CTkFont(size=16, weight="bold"), height=40, command=self.scan_sd_card)
        self.scan_btn.pack(pady=20)

        # Log Textbox
        self.log_box = ctk.CTkTextbox(self, width=800, height=250, font=ctk.CTkFont(family="Consolas", size=12))
        self.log_box.pack(pady=(0, 20))
        self.log_box.insert("0.0", "Waiting for SD Card scan...\n")
        self.log_box.configure(state="disabled")

    def create_metric_card(self, parent, title, variable, col):
        card = ctk.CTkFrame(parent, corner_radius=15)
        card.grid(row=0, column=col, padx=10, sticky="nsew")
        ctk.CTkLabel(card, text=title, font=ctk.CTkFont(size=14)).pack(pady=(15,0))
        ctk.CTkLabel(card, textvariable=variable, font=ctk.CTkFont(size=28, weight="bold"), text_color="#1f6aa5").pack(pady=(5,15))

    def log(self, text):
        self.log_box.configure(state="normal")
        self.log_box.insert("end", text + "\n")
        self.log_box.see("end")
        self.log_box.configure(state="disabled")

    def scan_sd_card(self):
        self.log_box.configure(state="normal")
        self.log_box.delete("0.0", "end")
        self.log_box.configure(state="disabled")
        self.log("Starting secure SD Card scan...")
        
        # Run in thread so GUI doesn't freeze
        threading.Thread(target=self._scan_thread, daemon=True).start()

    def _scan_thread(self):
        drives = find_removable_drives()
        if not drives:
            self.log("ERROR: No removable drives found. Please insert SD Card.")
            return

        chosen = drives[0]
        self.log(f"Found SD Card on drive {chosen}:\\")

        phys_num = get_physical_drive_number(chosen)
        if phys_num is None:
            self.log("ERROR: Could not get physical drive number.")
            return
        
        self.log(f"Reading from PhysicalDrive{phys_num}, Sector 2048...")
        
        disk_path = f"\\\\.\\PhysicalDrive{phys_num}"
        handle = ctypes.windll.kernel32.CreateFileW(
            disk_path, 0x80000000, 3, None, 3, 0, None
        )
        
        if handle == -1 or handle == 0xFFFFFFFFFFFFFFFF:
            self.log("ERROR: Failed to open raw physical drive. Are you running as Administrator?")
            return

        found = False
        latest_temp, latest_hum, latest_dist, latest_status = None, None, None, None
        alarm_triggered = False

        for i in range(NUM_SECTORS):
            sector = FIRST_SECTOR + i
            data = read_sector(handle, sector)
            if data and any(b != 0 for b in data[:32]):
                record = data[:32]
                metadata = record[:16]
                
                # Check format byte
                if metadata[0] == 0x01:
                    found = True
                    opcode = metadata[2]
                    status = metadata[6]
                    temp = metadata[9]
                    hum = metadata[10]
                    dist = (metadata[11] << 8) | metadata[12]
                    
                    accepted = bool(status & 0x01)
                    alarm = bool(status & 0x02)
                    
                    latest_temp = temp
                    latest_hum = hum
                    latest_dist = dist
                    
                    if alarm:
                        alarm_triggered = True
                        latest_status = "ALARM"
                    elif accepted:
                        latest_status = "SECURE"
                    else:
                        latest_status = "REJECTED"

                    op_names = {1:"Relay SET", 2:"Relay RESET", 3:"Motor", 4:"Stepper"}
                    op_str = op_names.get(opcode, f"CMD 0x{opcode:02X}")
                    
                    self.log(f"[Sector {sector}] CMD: {op_str} | Temp: {temp}C | Hum: {hum}% | Dist: {dist}cm | Status: {latest_status}")

        ctypes.windll.kernel32.CloseHandle(handle)

        if not found:
            self.log("Scan complete. No secure audit logs found.")
        else:
            self.log("Scan complete.")
            # Update GUI
            self.temp_var.set(f"{latest_temp} °C")
            self.hum_var.set(f"{latest_hum} %")
            self.dist_var.set(f"{latest_dist} cm")
            self.status_var.set(latest_status)
            
            if alarm_triggered:
                self.status_label.configure(text_color="#ff4a4a")
            elif latest_status == "SECURE":
                self.status_label.configure(text_color="#2fa52f")
            else:
                self.status_label.configure(text_color="#ffa500")

if __name__ == "__main__":
    app = SentinelDashboard()
    app.mainloop()
