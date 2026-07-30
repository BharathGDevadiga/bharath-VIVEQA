import sys
import os
import time
import threading
import serial
import serial.tools.list_ports
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

def xor_checksum(data: bytes) -> int:
    chk = 0
    for b in data:
        chk ^= b
    return chk

class UnifiedMasterApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("Sentinel RV - Unified FPGA Control & Telemetry Dashboard")
        self.geometry("1100x820")
        self.minsize(600, 600)
        self.resizable(True, True)
        
        self.users = {
            "intern": {"pass": "1234", "role": "INTERN"},
            "researcher": {"pass": "1234", "role": "RESEARCHER"},
            "admin": {"pass": "admin", "role": "ADMIN"}
        }
        self.current_user = None
        self.current_role = None
        
        self.is_running = True
        self.seq_counter = 1
        self.failed_attempts = 0
        self.active_ser = None
        self.ser_lock = threading.Lock()
        
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
        
        ctk.CTkLabel(card, text="🛡️ Sentinel RV Master Suite", font=ctk.CTkFont(size=26, weight="bold")).pack(pady=(35, 5))
        ctk.CTkLabel(card, text="Unified Control & Telemetry Login", font=ctk.CTkFont(size=14), text_color="gray").pack(pady=(0, 25))
        
        self.user_entry = ctk.CTkEntry(card, placeholder_text="Username", height=42, width=280)
        self.user_entry.pack(pady=10)
        
        self.pass_entry = ctk.CTkEntry(card, placeholder_text="Password", show="*", height=42, width=280)
        self.pass_entry.pack(pady=10)
        
        self.user_entry.bind("<Return>", self.attempt_login)
        self.pass_entry.bind("<Return>", self.attempt_login)
        
        self.login_err = ctk.CTkLabel(card, text="", text_color="#ff4d4d", font=ctk.CTkFont(size=12))
        self.login_err.pack(pady=5)
        
        ctk.CTkButton(card, text="LOGIN TO SYSTEM", height=45, width=280, font=ctk.CTkFont(weight="bold"), command=self.attempt_login).pack(pady=20)

    def trigger_fpga_alarm(self):
        port = self.port_var.get().split()[0]
        self.seq_counter = (self.seq_counter + 1) & 0xFF
        command = bytes([0xA5, 0xEE, self.seq_counter, 0x00, 0x00])
        command += bytes([xor_checksum(command)])
        
        def _tx_alarm():
            try:
                with serial.Serial(port, 115200, timeout=0.5) as ser:
                    ser.write(command)
                    ser.flush()
            except Exception:
                pass
        threading.Thread(target=_tx_alarm, daemon=True).start()

    def attempt_login(self, event=None):
        user = self.user_entry.get().lower().strip()
        pwd = self.pass_entry.get()
        
        if user in self.users and self.users[user]["pass"] == pwd:
            play_sound("success")
            self.failed_attempts = 0
            self.current_user = user
            self.current_role = self.users[user]["role"]
            self.user_hdr_lbl.configure(text=f"User: {self.current_user.capitalize()} ({self.current_role})")
            self.apply_rbac()
            self.show_frame(self.dashboard_frame)
            
            # Transmit Role Sync Packet to FPGA to update LCD Screen (ADMIN / RESEARCH / INTERN)
            port = self.port_var.get().split()[0]
            opcode = 0xA1 if self.current_role == "Admin" else 0xA2 if self.current_role == "Researcher" else 0xA3
            self.seq_counter = (self.seq_counter + 1) & 0xFF
            role_pkt = bytes([0xA5, opcode, self.seq_counter, 0x01, 0x00])
            role_pkt += bytes([xor_checksum(role_pkt)])
            def _send_role():
                try:
                    with serial.Serial(port, 115200, timeout=0.5) as ser:
                        ser.write(role_pkt)
                        ser.flush()
                except Exception:
                    pass
            threading.Thread(target=_send_role, daemon=True).start()

            # Start unified polling thread
            self.poll_thread = threading.Thread(target=self.unified_uart_loop, daemon=True)
            self.poll_thread.start()
        else:
            self.failed_attempts += 1
            play_sound("error")
            if self.failed_attempts >= 3:
                play_sound("alarm")
                self.trigger_fpga_alarm()
                self.login_err.configure(text=f"🚨 SECURITY LOCKOUT! ({self.failed_attempts} Failed Attempts) FPGA Buzzer Activated!")
            else:
                remaining = 3 - self.failed_attempts
                self.login_err.configure(text=f"Invalid credentials ({self.failed_attempts}/3 failed). {remaining} attempt(s) left.")
        return "break"

    def setup_dashboard_frame(self):
        header = ctk.CTkFrame(self.dashboard_frame, height=60, fg_color="#1e1e24", corner_radius=0)
        header.pack(fill="x", side="top")
        
        ctk.CTkLabel(header, text="🛡️ Sentinel RV -- Master System Control & Telemetry", font=ctk.CTkFont(size=18, weight="bold")).pack(side="left", padx=15)
        
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
        
        self.status_pill = ctk.CTkLabel(port_bar, text="● HARDWARE DISCONNECTED", text_color="#e67e22", font=ctk.CTkFont(weight="bold"))
        self.status_pill.pack(side="right", padx=15)

        grid_frame = ctk.CTkFrame(self.dashboard_frame, fg_color="transparent")
        grid_frame.pack(fill="x", padx=15, pady=5)
        
        card_temp = ctk.CTkFrame(grid_frame, corner_radius=12, fg_color="#2b2b36")
        card_temp.grid(row=0, column=0, padx=6, pady=6, sticky="nsew")
        ctk.CTkLabel(card_temp, text="🌡️ Temperature (DHT11)", font=ctk.CTkFont(size=12, weight="bold"), text_color="#ff7675").pack(pady=(10, 2))
        self.lbl_temp = ctk.CTkLabel(card_temp, text="-- °C", font=ctk.CTkFont(size=28, weight="bold"))
        self.lbl_temp.pack(pady=(0, 10))

        card_hum = ctk.CTkFrame(grid_frame, corner_radius=12, fg_color="#2b2b36")
        card_hum.grid(row=0, column=1, padx=6, pady=6, sticky="nsew")
        ctk.CTkLabel(card_hum, text="💧 Humidity (DHT11)", font=ctk.CTkFont(size=12, weight="bold"), text_color="#74b9ff").pack(pady=(10, 2))
        self.lbl_hum = ctk.CTkLabel(card_hum, text="-- %", font=ctk.CTkFont(size=28, weight="bold"))
        self.lbl_hum.pack(pady=(0, 10))

        card_dist = ctk.CTkFrame(grid_frame, corner_radius=12, fg_color="#2b2b36")
        card_dist.grid(row=0, column=2, padx=6, pady=6, sticky="nsew")
        ctk.CTkLabel(card_dist, text="📏 Distance (HC-SR04)", font=ctk.CTkFont(size=12, weight="bold"), text_color="#55efc4").pack(pady=(10, 2))
        self.lbl_dist = ctk.CTkLabel(card_dist, text="-- cm", font=ctk.CTkFont(size=28, weight="bold"))
        self.lbl_dist.pack(pady=(0, 10))

        card_adc = ctk.CTkFrame(grid_frame, corner_radius=12, fg_color="#2b2b36")
        card_adc.grid(row=0, column=3, padx=6, pady=6, sticky="nsew")
        ctk.CTkLabel(card_adc, text="⚡ Voltage (MCP3202 ADC)", font=ctk.CTkFont(size=12, weight="bold"), text_color="#ffeaa7").pack(pady=(10, 2))
        self.lbl_adc = ctk.CTkLabel(card_adc, text="-- V", font=ctk.CTkFont(size=28, weight="bold"))
        self.lbl_adc.pack(pady=(0, 10))

        grid_frame.columnconfigure(0, weight=1)
        grid_frame.columnconfigure(1, weight=1)
        grid_frame.columnconfigure(2, weight=1)
        grid_frame.columnconfigure(3, weight=1)

        btn_frame = ctk.CTkFrame(self.dashboard_frame)
        btn_frame.pack(fill="x", padx=15, pady=8)
        
        ctk.CTkLabel(btn_frame, text="HARDWARE RELAY & ALARM CONTROL", font=ctk.CTkFont(size=13, weight="bold"), text_color="#4dabf7").grid(row=0, column=0, columnspan=3, pady=6, padx=10, sticky="w")
        
        self.btn_relay_on = ctk.CTkButton(btn_frame, text="⚡ TURN RELAY ON (0x01)", height=45, font=ctk.CTkFont(weight="bold"), command=lambda: self.send_command(0x01, "RELAY ON"))
        self.btn_relay_on.grid(row=1, column=0, padx=8, pady=8, sticky="ew")
        
        self.btn_relay_off = ctk.CTkButton(btn_frame, text="🔌 TURN RELAY OFF (0x02)", height=45, font=ctk.CTkFont(weight="bold"), command=lambda: self.send_command(0x02, "RELAY OFF"))
        self.btn_relay_off.grid(row=1, column=1, padx=8, pady=8, sticky="ew")
        
        self.btn_clear_alarm = ctk.CTkButton(btn_frame, text="🔕 SILENCE ALARM (0x05)", height=45, font=ctk.CTkFont(weight="bold"), fg_color="#d97706", hover_color="#b45309", command=lambda: self.send_command(0x05, "CLEAR ALARM"))
        self.btn_clear_alarm.grid(row=1, column=2, padx=8, pady=8, sticky="ew")
        
        btn_frame.grid_columnconfigure(0, weight=1)
        btn_frame.grid_columnconfigure(1, weight=1)
        btn_frame.grid_columnconfigure(2, weight=1)

        sec_card = ctk.CTkFrame(self.dashboard_frame, fg_color="#1e272e", corner_radius=10)
        sec_card.pack(fill="x", padx=15, pady=5)
        
        self.lbl_sec_status = ctk.CTkLabel(sec_card, text="🛡️ HARDWARE STATUS: READY", font=ctk.CTkFont(size=12, weight="bold"), text_color="#2ecc71")
        self.lbl_sec_status.pack(pady=6)

        ctk.CTkLabel(self.dashboard_frame, text="SYSTEM EVENT & TELEMETRY LOG STREAM", font=ctk.CTkFont(size=11, weight="bold")).pack(anchor="w", padx=15, pady=(5, 2))
        
        self.log_box = ctk.CTkTextbox(self.dashboard_frame, font=ctk.CTkFont(family="Consolas", size=11))
        self.log_box.pack(fill="both", expand=True, padx=15, pady=(0, 15))
        self.log_box.configure(state="disabled")

    def apply_rbac(self):
        for btn in [self.btn_relay_on, self.btn_relay_off, self.btn_clear_alarm]:
            btn.configure(state="disabled", fg_color="#3a3a3a")
            
        if self.current_role == "INTERN":
            self.log("RBAC RESTRICTION: Intern is READ-ONLY.")
        elif self.current_role in ["RESEARCHER", "ADMIN"]:
            self.btn_relay_on.configure(state="normal", fg_color="#1f6aa5")
            self.btn_relay_off.configure(state="normal", fg_color="#1f6aa5")
            self.btn_clear_alarm.configure(state="normal", fg_color="#d97706")
            self.log(f"RBAC PERMISSION: {self.current_role} full control granted.")

    def send_command(self, opcode, label):
        port = self.port_var.get().split()[0]
        self.seq_counter = (self.seq_counter + 1) & 0xFF
        self.log(f"Sending [{label}] -> Opcode 0x{opcode:02X} to {port}...")
        
        command = bytes([
            0xA5,
            opcode,
            self.seq_counter,
            0x00, 0x00
        ])
        command += bytes([xor_checksum(command)])
        
        def _tx():
            with self.ser_lock:
                if self.active_ser and self.active_ser.is_open:
                    try:
                        self.active_ser.write(command)
                        self.active_ser.flush()
                        play_sound("success")
                        self.log(f"SUCCESS: Command [{label}] Dispatched to FPGA on {port}")
                        return
                    except Exception as e:
                        pass
                
                try:
                    with serial.Serial(port, 115200, timeout=0.5) as ser:
                        ser.write(command)
                        ser.flush()
                        play_sound("success")
                        self.log(f"SUCCESS: Command [{label}] Dispatched to FPGA on {port}")
                except Exception as e:
                    play_sound("error")
                    self.log(f"ERROR: Could not send to {port}: {str(e)}")

        threading.Thread(target=_tx, daemon=True).start()

    def unified_uart_loop(self):
        buffer = bytearray()
        
        while self.is_running and self.current_user is not None:
            port_name = self.port_var.get().split()[0]
            try:
                with serial.Serial(port_name, 115200, timeout=1.0) as ser:
                    self.active_ser = ser
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
                            
                            if alarm:
                                play_sound("alarm")
                                
                            self.after(0, self.update_gui_values, temp, hum, dist, adc_volts, seq, alarm)
                            time.sleep(2.0)
                            
            except Exception:
                self.active_ser = None
                self.after(0, self.set_hardware_connected_ui, False, port_name)
                time.sleep(2.0)
        self.active_ser = None

    def set_hardware_connected_ui(self, connected, port_name):
        if not self.is_running:
            return
        if connected:
            self.status_pill.configure(text=f"● STREAMING FROM {port_name} (2s)", text_color="#2ecc71")
            self.lbl_sec_status.configure(text="🛡️ HARDWARE CONNECTED & STREAMING LIVE TELEMETRY", text_color="#2ecc71")
        else:
            self.status_pill.configure(text="● HARDWARE DISCONNECTED", text_color="#e67e22")
            self.lbl_sec_status.configure(text=f"⚠️ DISCONNECTED: Plug FPGA USB cable into {port_name}", text_color="#e67e22")

    def update_gui_values(self, temp, hum, dist, adc_val, seq, alarm):
        if not self.is_running:
            return
            
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
    app = UnifiedMasterApp()
    app.mainloop()
