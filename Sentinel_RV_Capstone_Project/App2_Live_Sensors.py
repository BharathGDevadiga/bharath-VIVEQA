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
                pass  # Tick disabled per user request
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

ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

def xor_checksum(data: bytes) -> int:
    chk = 0
    for b in data:
        chk ^= b
    return chk

class LiveSensorsApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("Sentinel RV - Live Multi-Sensor Telemetry Dashboard")
        self.geometry("900x720")
        self.minsize(500, 500)
        self.resizable(True, True)
        
        self.users = {
            "intern": {"pass": "1234", "role": "INTERN"},
            "researcher": {"pass": "1234", "role": "RESEARCHER"},
            "admin": {"pass": "admin", "role": "ADMIN"}
        }
        self.current_user = None
        self.current_role = None
        
        self.is_running = True
        self.sample_count = 0
        self.valid_frames = 0
        self.checksum_errors = 0
        self.hardware_connected = False
        
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
        card.place(relx=0.5, rely=0.5, anchor="center", relwidth=0.5, relheight=0.65)
        
        ctk.CTkLabel(card, text="📡 Live Sensor Telemetry", font=ctk.CTkFont(size=26, weight="bold")).pack(pady=(35, 5))
        ctk.CTkLabel(card, text="Authorized Telemetry Monitoring Login", font=ctk.CTkFont(size=14), text_color="gray").pack(pady=(0, 25))
        
        self.user_entry = ctk.CTkEntry(card, placeholder_text="Username", height=42, width=280)
        self.user_entry.pack(pady=10)
        
        self.pass_entry = ctk.CTkEntry(card, placeholder_text="Password", show="*", height=42, width=280)
        self.pass_entry.pack(pady=10)
        
        # Bind ENTER key to trigger attempt_login and return 'break' to suppress default OS ding
        self.user_entry.bind("<Return>", self.attempt_login)
        self.pass_entry.bind("<Return>", self.attempt_login)
        
        self.login_err = ctk.CTkLabel(card, text="", text_color="#ff4d4d", font=ctk.CTkFont(size=12))
        self.login_err.pack(pady=5)
        
        ctk.CTkButton(card, text="ACCESS LIVE TELEMETRY", height=45, width=280, font=ctk.CTkFont(weight="bold"), command=self.attempt_login).pack(pady=20)

    def attempt_login(self, event=None):
        user = self.user_entry.get().lower().strip()
        pwd = self.pass_entry.get()
        
        if user in self.users and self.users[user]["pass"] == pwd:
            play_sound("success")
            self.current_user = user
            self.current_role = self.users[user]["role"]
            self.user_hdr_lbl.configure(text=f"User: {self.current_user.capitalize()} ({self.current_role})")
            self.show_frame(self.dashboard_frame)
            
            # Start background hardware polling thread upon login
            self.poll_thread = threading.Thread(target=self.real_hardware_polling_loop, daemon=True)
            self.poll_thread.start()
        else:
            play_sound("error")
            self.login_err.configure(text="Invalid credentials. Try intern / researcher / admin")
        return "break"

    def setup_dashboard_frame(self):
        header = ctk.CTkFrame(self.dashboard_frame, height=60, fg_color="#1e1e24", corner_radius=0)
        header.pack(fill="x", side="top")
        
        ctk.CTkLabel(header, text="📡 Sentinel RV -- Live Multi-Sensor Telemetry", font=ctk.CTkFont(size=18, weight="bold")).pack(side="left", padx=15)
        
        self.user_hdr_lbl = ctk.CTkLabel(header, text="User: Admin", font=ctk.CTkFont(size=13), text_color="#a4b0be")
        self.user_hdr_lbl.pack(side="left", padx=15)
        
        ctk.CTkButton(header, text="LOGOUT", width=80, fg_color="#c93434", hover_color="#9e2828", command=self.logout).pack(side="right", padx=15)

        port_bar = ctk.CTkFrame(self.dashboard_frame, height=50)
        port_bar.pack(fill="x", padx=15, pady=10)
        
        ctk.CTkLabel(port_bar, text="FPGA UART Port:", font=ctk.CTkFont(weight="bold")).pack(side="left", padx=10)
        
        ports = [p.device for p in serial.tools.list_ports.comports()]
        if not ports:
            ports = ["COM3", "COM4", "COM5"]
            
        self.port_var = ctk.StringVar(value=ports[0])
        ctk.CTkOptionMenu(port_bar, variable=self.port_var, values=ports, width=200).pack(side="left", padx=10)
        
        self.status_pill = ctk.CTkLabel(port_bar, text="● WAITING FOR HARDWARE...", text_color="#e67e22", font=ctk.CTkFont(weight="bold"))
        self.status_pill.pack(side="right", padx=15)

        grid_frame = ctk.CTkFrame(self.dashboard_frame, fg_color="transparent")
        grid_frame.pack(fill="x", padx=15, pady=10)
        
        card_temp = ctk.CTkFrame(grid_frame, corner_radius=12, fg_color="#2b2b36")
        card_temp.grid(row=0, column=0, padx=8, pady=8, sticky="nsew")
        ctk.CTkLabel(card_temp, text="🌡️ Temperature (DHT11)", font=ctk.CTkFont(size=13, weight="bold"), text_color="#ff7675").pack(pady=(12, 4))
        self.lbl_temp = ctk.CTkLabel(card_temp, text="-- °C", font=ctk.CTkFont(size=32, weight="bold"))
        self.lbl_temp.pack(pady=(0, 12))

        card_hum = ctk.CTkFrame(grid_frame, corner_radius=12, fg_color="#2b2b36")
        card_hum.grid(row=0, column=1, padx=8, pady=8, sticky="nsew")
        ctk.CTkLabel(card_hum, text="💧 Humidity (DHT11)", font=ctk.CTkFont(size=13, weight="bold"), text_color="#74b9ff").pack(pady=(12, 4))
        self.lbl_hum = ctk.CTkLabel(card_hum, text="-- %", font=ctk.CTkFont(size=32, weight="bold"))
        self.lbl_hum.pack(pady=(0, 12))

        card_dist = ctk.CTkFrame(grid_frame, corner_radius=12, fg_color="#2b2b36")
        card_dist.grid(row=1, column=0, padx=8, pady=8, sticky="nsew")
        ctk.CTkLabel(card_dist, text="📏 Distance (HC-SR04)", font=ctk.CTkFont(size=13, weight="bold"), text_color="#55efc4").pack(pady=(12, 4))
        self.lbl_dist = ctk.CTkLabel(card_dist, text="-- cm", font=ctk.CTkFont(size=32, weight="bold"))
        self.lbl_dist.pack(pady=(0, 12))

        card_adc = ctk.CTkFrame(grid_frame, corner_radius=12, fg_color="#2b2b36")
        card_adc.grid(row=1, column=1, padx=8, pady=8, sticky="nsew")
        ctk.CTkLabel(card_adc, text="⚡ Voltage (MCP3202 ADC)", font=ctk.CTkFont(size=13, weight="bold"), text_color="#ffeaa7").pack(pady=(12, 4))
        self.lbl_adc = ctk.CTkLabel(card_adc, text="-- V", font=ctk.CTkFont(size=32, weight="bold"))
        self.lbl_adc.pack(pady=(0, 12))

        grid_frame.columnconfigure(0, weight=1)
        grid_frame.columnconfigure(1, weight=1)

        sec_card = ctk.CTkFrame(self.dashboard_frame, fg_color="#1e272e", corner_radius=12)
        sec_card.pack(fill="x", padx=15, pady=8)
        
        self.lbl_sec_status = ctk.CTkLabel(sec_card, text="🛡️ HARDWARE STATUS: CONNECT FPGA BOARD VIA USB", font=ctk.CTkFont(size=13, weight="bold"), text_color="#e67e22")
        self.lbl_sec_status.pack(pady=10)

        ctk.CTkLabel(self.dashboard_frame, text="REAL-TIME TELEMETRY LOG STREAM", font=ctk.CTkFont(size=11, weight="bold")).pack(anchor="w", padx=15, pady=(5, 2))
        
        self.log_box = ctk.CTkTextbox(self.dashboard_frame, font=ctk.CTkFont(family="Consolas", size=11))
        self.log_box.pack(fill="both", expand=True, padx=15, pady=(0, 15))
        self.log_box.configure(state="disabled")

    def real_hardware_polling_loop(self):
        buffer = bytearray()
        
        while self.is_running and self.current_user is not None:
            port_name = self.port_var.get().split()[0]
            try:
                with serial.Serial(port_name, 115200, timeout=1.0) as ser:
                    self.after(0, self.set_hardware_connected_ui, True, port_name)
                    
                    while self.is_running and self.current_user is not None:
                        chunk = ser.read(11)
                        if not chunk:
                            continue
                        buffer.extend(chunk)
                        
                        while len(buffer) >= 11:
                            start = buffer.find(b"\xA6")
                            if start < 0:
                                buffer.clear()
                                break
                            if start > 0:
                                del buffer[:start]
                            if len(buffer) < 11:
                                break
                                
                            frame = bytes(buffer[:11])
                            if xor_checksum(frame[:10]) != frame[10]:
                                self.checksum_errors += 1
                                del buffer[0]
                                continue
                            
                            del buffer[:11]
                            
                            seq = frame[1]
                            event = frame[2]
                            adc_raw = ((frame[3] & 0x0F) << 8) | frame[4]
                            adc_volts = round(adc_raw * 3.3 / 4095.0, 2)
                            temp = frame[5]
                            hum = frame[6]
                            dist = (frame[7] << 8) | frame[8]
                            status_val = frame[9]
                            alarm = (status_val & 0x04) != 0
                            
                            self.valid_frames += 1
                            
                            if alarm:
                                play_sound("alarm")
                                
                            self.after(0, self.update_gui_values, temp, hum, dist, adc_volts, seq, alarm)
                            time.sleep(2.0)  # Refresh every 2 seconds
                            
            except Exception:
                self.after(0, self.set_hardware_connected_ui, False, port_name)
                time.sleep(2.0)

    def set_hardware_connected_ui(self, connected, port_name):
        if not self.is_running:
            return
        if connected:
            self.status_pill.configure(text=f"● STREAMING FROM {port_name} (2s)", text_color="#2ecc71")
            self.lbl_sec_status.configure(text="🛡️ HARDWARE CONNECTED & STREAMING LIVE TELEMETRY", text_color="#2ecc71")
        else:
            self.status_pill.configure(text="● NO HARDWARE CONNECTED", text_color="#e67e22")
            self.lbl_sec_status.configure(text=f"⚠️ DISCONNECTED: Plug FPGA USB cable into {port_name}", text_color="#e67e22")
            self.lbl_temp.configure(text="-- °C")
            self.lbl_hum.configure(text="-- %")
            self.lbl_dist.configure(text="-- cm")
            self.lbl_adc.configure(text="-- V")

    def update_gui_values(self, temp, hum, dist, adc_val, seq, alarm):
        if not self.is_running:
            return
            
        # Clean formatting: Handle 0x65535 timeout / 0 temperature values cleanly
        temp_str = f"{temp} °C" if temp > 0 else "-- °C"
        hum_str = f"{hum} %" if hum > 0 else "-- %"
        dist_str = f"{dist} cm" if (dist > 0 and dist < 65000) else "-- cm"

        self.lbl_temp.configure(text=temp_str)
        self.lbl_hum.configure(text=hum_str)
        self.lbl_dist.configure(text=dist_str)
        self.lbl_adc.configure(text=f"{adc_val} V")
        
        status_txt = "ALARM LOCKDOWN!" if alarm else "NORMAL / OPERATIONAL"
        status_clr = "#e74c3c" if alarm else "#2ecc71"
        self.lbl_sec_status.configure(text=f"🛡️ HARDWARE STATUS: {status_txt}", text_color=status_clr)
        
        self.log_box.configure(state="normal")
        ts = time.strftime("%H:%M:%S")
        log_line = f"[{ts}] Telemetry #{seq:03d} | Temp: {temp_str} | Hum: {hum_str} | Dist: {dist_str} | ADC: {adc_val}V | Alarm: {alarm}\n"
        self.log_box.insert("end", log_line)
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
    app = LiveSensorsApp()
    app.mainloop()
