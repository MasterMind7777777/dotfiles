#!/home/mastermind/bash/i3/venv/bin/python3
import i3ipc
import subprocess
import time
import logging
import os


# Create log directory if it does not exist
log_directory = './logs'
if not os.path.exists(log_directory):
    os.makedirs(log_directory)
# Setup logging
logging.basicConfig(filename='./logs/i3_start_up.log', level=logging.INFO, format='%(asctime)s %(levelname)s:%(message)s')

# Initialize i3 connection
i3 = i3ipc.Connection()

# Workspace assignment using window classes
ws_assignment = {
    'Google-chrome': '1:web',
    'Alacritty': '2:terminal',
    'Slack': '3:slack'
}

# Launch apps
subprocess.run(['i3-msg', 'workspace 1:web; exec google-chrome-stable --profile-directory="Profile 3"'])
subprocess.run(['i3-msg', 'workspace 2:terminal; exec alacritty --title init-terminal-1'])
subprocess.run(['i3-msg', 'workspace 3:slack; exec slack'])
logging.info('Applications launched')

# Function to check if DP-2 is active
def is_dp2_active(i3):
    for output in i3.get_outputs():
        if output.name == 'DP-2' and output.active:
            return True
    return False

# Function to launch Chrome with ChatGPT and move it to workspace 11:F1
def launch_chrome_chat_gpt(workspace):
    subprocess.Popen(['google-chrome-stable', '--profile-directory="Default"', '--new-window', 'https://chat.openai.com'])
    logging.info("Launched Google Chrome with ChatGPT")
    
    for _ in range(10):  # Retry up to 10 times
        found = False
        for window in i3.get_tree().leaves():
            if window.window_title and 'ChatGPT' in window.window_title and window.window_class and 'Google-chrome' in window.window_class:
                i3.command(f'[con_id="{window.window_class}"] move container to workspace {workspace}')
                logging.info(f'Moved Chrome with ChatGPT to workspace {workspace}')
                found = True
                break
        if found:
            break
        else:
            logging.info("Waiting for Chrome window with ChatGPT to be ready...")
            time.sleep(1)

# Function to move window based on its class
def check_and_move_windows(i3, ws_assignment):
    tree = i3.get_tree()
    for window in tree.leaves():
        window_class = window.window_class
        if window_class in ws_assignment:
            target_workspace = ws_assignment[window_class]
            i3.command(f'[con_id="{window.id}"] move container to workspace {target_workspace}')
            logging.info(f"Moved {window_class} to {target_workspace}")

# Function to check if all expected windows are open
def all_windows_open(i3, ws_assignment):
    open_windows_classes = {window.window_class for window in i3.get_tree().leaves()}
    for class_ in ws_assignment:
        if class_ not in open_windows_classes:
            logging.info(f"Waiting for {class_} to open...")
            return False
    return True

# Wait until all standard windows are open
while not all_windows_open(i3, ws_assignment):
    time.sleep(1)

# Move the standard windows once they're all open
check_and_move_windows(i3, ws_assignment)

# Check if DP-2 is active before launching ChatGPT
if is_dp2_active(i3):
    launch_chrome_chat_gpt('11:F1')
else:
    logging.info("DP-2 is not active. Skipping ChatGPT launch.")

logging.info("All windows moved to their assigned workspaces.")

