import os
import shutil
import subprocess

def run_cmd(cmd):
    print(f'Running: {cmd}')
    subprocess.run(cmd, shell=True)

# 1. Remove old broken Verilog folder from git and filesystem
run_cmd('git rm -r -q Sentinel_RV_Capstone_Project/Codes/Verilog')

# 2. Recreate the Verilog folder
os.makedirs('Sentinel_RV_Capstone_Project/Codes/Verilog', exist_ok=True)

# 3. Move the working root 'src' and 'Sentinel_RV-Project' into it using git mv
run_cmd('git mv src Sentinel_RV_Capstone_Project/Codes/Verilog/src')
run_cmd('git mv Sentinel_RV-Project Sentinel_RV_Capstone_Project/Codes/Verilog/Vivado_Project')

# 4. Remove root vivado logs
for file in os.listdir('.'):
    if file.endswith('.jou') or file.endswith('.log') or file.endswith('.txt') or file.endswith('.str'):
        if file != 'README.md' and file != 'requirements.txt':
            run_cmd(f'git rm --cached {file} -q')
            try:
                os.remove(file)
            except:
                pass

# 5. Commit
run_cmd('git add .')
run_cmd('git commit -m "Consolidate project structure and remove root duplicates"')
