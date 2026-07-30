import os
import shutil
import subprocess

def run_cmd(cmd):
    print(f'Running: {cmd}')
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    print(res.stdout)
    if res.stderr:
        print('STDERR:', res.stderr)

# 1. Create target directories inside Capstone
verilog_dir = 'Sentinel_RV_Capstone_Project/Codes/Verilog'
os.makedirs(verilog_dir, exist_ok=True)

# 2. Copy src and Sentinel_RV-Project into Capstone/Codes/Verilog
if os.path.exists('src'):
    dest_src = os.path.join(verilog_dir, 'src')
    if os.path.exists(dest_src):
        shutil.rmtree(dest_src)
    shutil.copytree('src', dest_src)

if os.path.exists('Sentinel_RV-Project'):
    dest_proj = os.path.join(verilog_dir, 'Sentinel_RV-Project')
    if os.path.exists(dest_proj):
        shutil.rmtree(dest_proj)
    shutil.copytree('Sentinel_RV-Project', dest_proj)

# 3. Add Capstone to Git
run_cmd(f'git add {verilog_dir}')

# 4. Untrack root src and Sentinel_RV-Project from Git (keep local copy for safety)
run_cmd('git rm -r --cached src Sentinel_RV-Project -q')

# 5. Commit and push
run_cmd('git commit -m "Move Verilog code and Vivado project into Sentinel_RV_Capstone_Project/Codes/Verilog"')
run_cmd('git push')
