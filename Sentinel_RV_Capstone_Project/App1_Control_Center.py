import sys
import os
import time
import threading
import serial
import serial.tools.list_ports
import customtkinter as ctk

# Windows Master Laptop Speaker Audio (Native Windows Event Sound)
try:
    import winsound
    def play_sound(sound_type="chime"):
        try:
            if sound_type == "error":
                winsound.PlaySound("SystemHand", winsound.SND_ALIAS | winsound.SND_ASYNC)
            elif sound_type == "success":
                winsound.PlaySound("SystemNotification", winsound.SND_ALIAS | winsound.SND_ASYNC)
            elif sound_type == "alarm":
                winsound.PlaySound("SystemExclamation", winsound.SND_ALIAS | winsound.SND_ASYNC)
            elif sound_type == "tick":
                pass  # Tick disabled
            else:
                winsound.PlaySound("SystemQuestion", winsound.SND_ALIAS | winsound.SND_ASYNC)
        except Exception:
            pass
except Exception:
    def play_sound(sound_type="chime"):
        pass

# Suppress console window in frozen GUI mode
if getattr(sys, 'frozen', False):
    sys.stdout = open(os.devnull, 'w')
    sys.stderr = open(os.devnull, 'w')

# Set GUI Theme
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

def xor_checksum(data: bytes) -> int:
    chk = 0
    for b in data:
        chk ^= b
    return chk

def send_uart_command(port, opcode, argument=0x0000, sequence=0x01):
    command = bytes([
        0xA5,
        opcode,
        sequence,
        (argument >> 8) & 0xFF,
        argument & 0xFF
    ])
    command += bytes([xor_checksum(command)])
    
    try:
        with serial.Serial(port, 115200, timeout=0.3) as ser:
            time.sleep(0.1)
            ser.reset_input_buffer()
            ser.reset_output_buffer()
            ser.write(command)
            ser.flush()
            
            buffer = bytearray()
            deadline = time.monotonic() + 1.5
            
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
                    
                    event = frame[2]
                    if event == 0x10:
                        play_sound("success")
                        return "SUCCESS: Command Accepted & Executed by FPGA"
                    elif event == 0x02:
                        play_sound("error")
                        return "REJECTED: Security Core Denied Request"
                    elif event == 0xEE:
                        play_sound("alarm")
                        return "ALARM: Hardware Security Alarm Active"
                    else:
                        play_sound("chime")
                        return f"SUCCESS: Transmitted (Event 0x{event:02X})"
            play_sound("success")
            return "SUCCESS: Command Frame Dispatched to FPGA"
    except Exception as e:
        play_sound("error")
        return f"HARDWARE DISCONNECTED: Cannot reach FPGA on {port}. Please plug in USB serial board."

class ControlApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("Sentinel RV - Hardware Control Center")
        self.geometry("900x700")
        self.minsize(500, 500)
        self.resizable(True, True)
        
        self.users = {
            "intern": {"pass": "1234", "role": "INTERN"},
            "researcher": {"pass": "1234", "role": "RESEARCHER"},
            "admin": {"pass": "admin", "role": "ADMIN"}
        }
        self.failed_attempts = 0
        self.current_user = None
        self.current_role = None
        self.seq_counter = 1
        
        self.login_frame = ctk.CTkFrame(self)
        self.dashboard_frame = ctk.CTkFrame(self)
        
        self.setup_login_frame()
        self.setup_dashboard_frame()
        
        self.show_frame(self.login_frame)

    def show_frame(self, frame):
        self.login_frame.pack_forget()
        self.dashboard_frame.pack_forget()
        frame.pack(fill="both", expand=True)

    def setup_login_frame(self):
        card = ctk.CTkFrame(self.login_frame, corner_radius=15)
        card.place(relx=0.5, rely=0.5, anchor="center", relwidth=0.6, relheight=0.7)
        
        ctk.CTkLabel(card, text="🛡️ Sentinel RV", font=ctk.CTkFont(size=28, weight="bold")).pack(pady=(35, 5))
        ctk.CTkLabel(card, text="Hardware Control Login", font=ctk.CTkFont(size=16), text_color="gray").pack(pady=(0, 25))
        
        self.user_entry = ctk.CTkEntry(card, placeholder_text="Username", height=42)
        self.user_entry.pack(pady=10, fill="x", padx=40)
        
        self.pass_entry = ctk.CTkEntry(card, placeholder_text="Password", show="*", height=42)
        self.pass_entry.pack(pady=10, fill="x", padx=40)
        
        # Bind ENTER key to trigger attempt_login and return 'break' to suppress default OS ding
        self.user_entry.bind("<Return>", self.attempt_login)
        self.pass_entry.bind("<Return>", self.attempt_login)
        
        self.login_err = ctk.CTkLabel(card, text="", text_color="#ff4d4d", font=ctk.CTkFont(size=12))
        self.login_err.pack(pady=5)
        
        ctk.CTkButton(card, text="LOGIN TO SYSTEM", height=45, font=ctk.CTkFont(weight="bold"), command=self.attempt_login).pack(pady=20, fill="x", padx=40)

    def attempt_login(self, event=None):
        user = self.user_entry.get().lower().strip()
        pwd = self.pass_entry.get()
        
        if user in self.users and self.users[user]["pass"] == pwd:
            play_sound("success")
            self.failed_attempts = 0
            self.current_user = user
            self.current_role = self.users[user]["role"]
            self.apply_rbac()
            self.show_frame(self.dashboard_frame)
            self.log(f"Session started for {self.current_user.upper()} [{self.current_role}]")
        else:
            play_sound("error")
            self.failed_attempts += 1
            if self.failed_attempts >= 3:
                play_sound("alarm")
                self.login_err.configure(text="⚠️ FAILED ATTEMPTS DETECTED! HARDWARE LOCKOUT.")
            else:
                self.login_err.configure(text=f"Invalid credentials. Attempt {self.failed_attempts}/3")
        return "break"

    def setup_dashboard_frame(self):
        header = ctk.CTkFrame(self.dashboard_frame, height=60, fg_color="#1e1e24", corner_radius=0)
        header.pack(fill="x", side="top")
        
        self.user_lbl = ctk.CTkLabel(header, text="Control Dashboard", font=ctk.CTkFont(size=18, weight="bold"))
        self.user_lbl.pack(side="left", padx=15)
        
        ctk.CTkButton(header, text="LOGOUT", width=80, fg_color="#c93434", hover_color="#9e2828", command=self.logout).pack(side="right", padx=15)
        
        port_bar = ctk.CTkFrame(self.dashboard_frame, height=50)
        port_bar.pack(fill="x", padx=15, pady=10)
        
        ctk.CTkLabel(port_bar, text="Target Port:", font=ctk.CTkFont(weight="bold")).pack(side="left", padx=10)
        
        ports = [p.device for p in serial.tools.list_ports.comports()]
        if not ports:
            ports = ["COM3", "COM4", "COM5"]
            
        self.port_var = ctk.StringVar(value=ports[0])
        ctk.CTkOptionMenu(port_bar, variable=self.port_var, values=ports, width=180).pack(side="left", padx=10)
        
        btn_frame = ctk.CTkFrame(self.dashboard_frame)
        btn_frame.pack(fill="x", padx=15, pady=10)
        
        ctk.CTkLabel(btn_frame, text="RELAY & ALARM CONTROL ACTIONS", font=ctk.CTkFont(size=14, weight="bold"), text_color="#4dabf7").grid(row=0, column=0, columnspan=2, pady=10, padx=15, sticky="w")
        
        self.btn_relay_on = ctk.CTkButton(btn_frame, text="⚡ TURN RELAY ON (0x01)", height=50, font=ctk.CTkFont(weight="bold"), command=lambda: self.send_command(0x01, "RELAY ON"))
        self.btn_relay_on.grid(row=1, column=0, padx=10, pady=10, sticky="ew")
        
        self.btn_relay_off = ctk.CTkButton(btn_frame, text="🔌 TURN RELAY OFF (0x02)", height=50, font=ctk.CTkFont(weight="bold"), command=lambda: self.send_command(0x02, "RELAY OFF"))
        self.btn_relay_off.grid(row=1, column=1, padx=10, pady=10, sticky="ew")
        
        self.btn_clear_alarm = ctk.CTkButton(btn_frame, text="🔕 SILENCE / CLEAR ALARM (0x05)", height=50, font=ctk.CTkFont(weight="bold"), fg_color="#d97706", hover_color="#b45309", command=lambda: self.send_command(0x05, "CLEAR ALARM"))
        self.btn_clear_alarm.grid(row=2, column=0, columnspan=2, padx=10, pady=10, sticky="ew")
        
        btn_frame.grid_columnconfigure(0, weight=1)
        btn_frame.grid_columnconfigure(1, weight=1)
        
        ctk.CTkLabel(self.dashboard_frame, text="SYSTEM RESPONSE LOG", font=ctk.CTkFont(size=12, weight="bold")).pack(anchor="w", padx=15, pady=(10, 2))
        
        self.log_box = ctk.CTkTextbox(self.dashboard_frame, font=ctk.CTkFont(family="Consolas", size=11))
        self.log_box.pack(fill="both", expand=True, padx=15, pady=(0, 15))
        self.log_box.configure(state="disabled")

    def apply_rbac(self):
        self.user_lbl.configure(text=f"Control — User: {self.current_user.capitalize()} ({self.current_role})")
        
        for btn in [self.btn_relay_on, self.btn_relay_off, self.btn_clear_alarm]:
            btn.configure(state="disabled", fg_color="#3a3a3a")
            
        if self.current_role == "INTERN":
            self.log("RBAC RESTRICTION: Intern is READ-ONLY.")
        elif self.current_role == "RESEARCHER":
            self.btn_relay_on.configure(state="normal", fg_color="#1f6aa5")
            self.btn_relay_off.configure(state="normal", fg_color="#1f6aa5")
            self.btn_clear_alarm.configure(state="normal", fg_color="#d97706")
            self.log("RBAC PERMISSION: Researcher access active.")
        elif self.current_role == "ADMIN":
            self.btn_relay_on.configure(state="normal", fg_color="#1f6aa5")
            self.btn_relay_off.configure(state="normal", fg_color="#1f6aa5")
            self.btn_clear_alarm.configure(state="normal", fg_color="#d97706")
            self.log("RBAC PERMISSION: Admin access active.")

    def send_command(self, opcode, label):
        port = self.port_var.get().split()[0]
        self.seq_counter = (self.seq_counter + 1) & 0xFF
        self.log(f"Sending [{label}] -> Opcode 0x{opcode:02X} to {port}...")
        threading.Thread(target=self._send_thread, args=(port, opcode, label), daemon=True).start()

    def _send_thread(self, port, opcode, label):
        res = send_uart_command(port, opcode, sequence=self.seq_counter)
        self.log(f"Response: {res}")

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

if __name__ == "__main__":
    app = ControlApp()
    app.mainloop()
