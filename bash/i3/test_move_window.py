#!/home/mastermind/bash/i3/venv/bin/python3
import i3ipc
import subprocess
import time

# Initialize i3 connection
i3 = i3ipc.Connection()

def launch_chrome_and_move_to_workspace(url, expected_title, workspace):
    # Launch Google Chrome in a new window with the given URL
    subprocess.Popen(['google-chrome-stable', '--new-window', url])
    print("Launched Google Chrome with URL:", url)
    time.sleep(5)  # Initial wait for the browser to open and load the page

    # Try to find the new Chrome window and move it
    found = False
    while not found:
        for window in i3.get_tree().leaves():
            # Check if the window title contains the expected title
            if expected_title in window.window_title and 'Google-chrome' in window.window_class:
                i3.command(f'[con_id="{window.id}"] move container to workspace {workspace}')
                print(f'Moved Chrome with title "{expected_title}" to workspace {workspace}')
                found = True
                break
        if not found:
            print(f"Waiting for Chrome window with title \"{expected_title}\" to be ready...")
            time.sleep(1)

# URL to open, expected title, and the target workspace
url = 'https://chat.openai.com'
expected_title = 'ChatGPT'
workspace = '5'

launch_chrome_and_move_to_workspace(url, expected_title, workspace)

