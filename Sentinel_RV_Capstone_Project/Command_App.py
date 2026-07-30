import time
import threading
import serial
import customtkinter as ctk
import serial.tools.list_ports

# ==========================================
# FPGA UART Logic
# ==========================================
def xor_checksum(data):
    value = 0
    for byte in data:
        value ^= byte
    return value

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
        with serial.Serial(port, 115200, timeout=0.1) as ser:
            time.sleep(0.2)
            ser.reset_input_buffer()
            ser.reset_output_buffer()
            ser.write(command)
            ser.flush()
            
            buffer = bytearray()
            deadline = time.monotonic() + 2.0
            
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
                    if event == 0x01:
                        return "Telemetry Received"
                    elif event == 0x10:
                        return "COMMAND ACCEPTED - Secure Actuation"
                    elif event == 0x02:
                        return "COMMAND REJECTED - Access Denied"
                    elif event == 0xEE:
                        return "ALARM TRIGGERED"
            return "No valid response from FPGA"
    except Exception as e:
        return f"Error opening {port}: {str(e)}"

# ==========================================
# GUI Application
# ==========================================
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class SecureCommandApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("Sentinel RV - Secure Command Center")
        self.geometry("800x600")
        self.resizable(False, False)
        
        self.users = {
            "intern": {"pass": "1234", "role": "INTERN"},
            "researcher": {"pass": "1234", "role": "RESEARCHER"},
            "admin": {"pass": "admin", "role": "ADMIN"}
        }
        self.failed_attempts = 0
        self.current_user = None
        self.current_role = None
        
        # Frames
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
        title = ctk.CTkLabel(self.login_frame, text="Secure Login", font=ctk.CTkFont(size=32, weight="bold"))
        title.pack(pady=(150, 40))
        
        self.username_entry = ctk.CTkEntry(self.login_frame, placeholder_text="Username", width=250, height=40)
        self.username_entry.pack(pady=10)
        
        self.password_entry = ctk.CTkEntry(self.login_frame, placeholder_text="Password", show="*", width=250, height=40)
        self.password_entry.pack(pady=10)
        
        self.login_error_label = ctk.CTkLabel(self.login_frame, text="", text_color="red")
        self.login_error_label.pack(pady=5)
        
        login_btn = ctk.CTkButton(self.login_frame, text="Login", width=250, height=40, font=ctk.CTkFont(weight="bold"), command=self.attempt_login)
        login_btn.pack(pady=20)
        
    def attempt_login(self):
        user = self.username_entry.get().lower().strip()
        pwd = self.password_entry.get()
        
        if user in self.users and self.users[user]["pass"] == pwd:
            self.failed_attempts = 0
            self.current_user = user
            self.current_role = self.users[user]["role"]
            self.apply_rbac()
            self.show_frame(self.dashboard_frame)
            self.log(f"Login successful. Welcome {self.current_user} ({self.current_role})")
        else:
            self.failed_attempts += 1
            if self.failed_attempts >= 3:
                self.login_error_label.configure(text="BRUTE FORCE DETECTED. TRIGGERING HARDWARE ALARM.")
                self.trigger_hardware_alarm()
            else:
                self.login_error_label.configure(text=f"Invalid credentials. Attempt {self.failed_attempts}/3")

    def trigger_hardware_alarm(self):
        # Sends opcode 0x99 which is invalid and will trigger the FPGA Buzzer
        port = self.com_port_var.get()
        threading.Thread(target=self._send_cmd_thread, args=(port, 0x99, 0, "TRIGGERING HARDWARE ALARM"), daemon=True).start()

    def setup_dashboard_frame(self):
        header = ctk.CTkFrame(self.dashboard_frame, fg_color="transparent")
        header.pack(fill="x", pady=20, padx=20)
        
        self.welcome_label = ctk.CTkLabel(header, text="Welcome", font=ctk.CTkFont(size=24, weight="bold"))
        self.welcome_label.pack(side="left")
        
        logout_btn = ctk.CTkButton(header, text="Logout", width=100, fg_color="#c93434", hover_color="#9e2828", command=self.logout)
        logout_btn.pack(side="right")
        
        # COM Port Selector
        controls = ctk.CTkFrame(self.dashboard_frame)
        controls.pack(fill="x", pady=10, padx=20)
        
        ctk.CTkLabel(controls, text="Select COM Port:").pack(side="left", padx=10)
        available_ports = [p.device for p in serial.tools.list_ports.comports()]
        if not available_ports:
            available_ports = ["COM3", "COM4", "COM5"]
            
        self.com_port_var = ctk.StringVar(value=available_ports[0])
        self.com_menu = ctk.CTkOptionMenu(controls, variable=self.com_port_var, values=available_ports)
        self.com_menu.pack(side="left", padx=10, pady=10)
        
        # Actions
        actions_frame = ctk.CTkFrame(self.dashboard_frame, fg_color="transparent")
        actions_frame.pack(fill="x", pady=20, padx=20)
        
        self.btn_relay_on = ctk.CTkButton(actions_frame, text="Turn Relay ON", height=50, command=lambda: self.send_cmd(0x01, 0, "Relay ON"))
        self.btn_relay_on.pack(side="left", expand=True, padx=10)
        
        self.btn_relay_off = ctk.CTkButton(actions_frame, text="Turn Relay OFF", height=50, command=lambda: self.send_cmd(0x02, 0, "Relay OFF"))
        self.btn_relay_off.pack(side="left", expand=True, padx=10)

        # Log Textbox
        self.log_box = ctk.CTkTextbox(self.dashboard_frame, width=760, height=250, font=ctk.CTkFont(family="Consolas", size=13))
        self.log_box.pack(pady=20)
        self.log_box.configure(state="disabled")

    def apply_rbac(self):
        self.welcome_label.configure(text=f"Dashboard - {self.current_user.capitalize()} ({self.current_role})")
        
        # Reset all to disabled
        self.btn_relay_on.configure(state="disabled", fg_color="gray")
        self.btn_relay_off.configure(state="disabled", fg_color="gray")
        
        if self.current_role == "INTERN":
            # Interns can't click anything, view only
            self.log("RBAC: Intern has read-only access. Actuation disabled.")
        elif self.current_role == "RESEARCHER":
            # Researchers can use Relays
            self.btn_relay_on.configure(state="normal", fg_color="#1f6aa5")
            self.btn_relay_off.configure(state="normal", fg_color="#1f6aa5")
            self.log("RBAC: Researcher granted Relay access.")
        elif self.current_role == "ADMIN":
            # Admins can do everything
            self.btn_relay_on.configure(state="normal", fg_color="#1f6aa5")
            self.btn_relay_off.configure(state="normal", fg_color="#1f6aa5")
            self.log("RBAC: Admin granted full access to all systems.")

    def log(self, text):
        self.log_box.configure(state="normal")
        self.log_box.insert("end", "> " + text + "\n")
        self.log_box.see("end")
        self.log_box.configure(state="disabled")

    def logout(self):
        self.current_user = None
        self.current_role = None
        self.username_entry.delete(0, 'end')
        self.password_entry.delete(0, 'end')
        self.login_error_label.configure(text="")
        self.show_frame(self.login_frame)

    def send_cmd(self, opcode, arg, name):
        port = self.com_port_var.get()
        self.log(f"Sending [{name}] over {port}...")
        threading.Thread(target=self._send_cmd_thread, args=(port, opcode, arg, name), daemon=True).start()

    def _send_cmd_thread(self, port, opcode, arg, name):
        result = send_uart_command(port, opcode, arg)
        self.log(f"[{name}] Response: {result}")

if __name__ == "__main__":
    app = SecureCommandApp()
    app.mainloop()
