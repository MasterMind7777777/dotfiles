#!/bin/bash

# Kill i3-nagbar
killall i3-nagbar 2>/dev/null

# Find the Python worker process and kill it
# Replace "listen_for_window_move.py" with the actual name of your Python worker script if different
python_worker_pid=$(pgrep -f "listen_for_window_move.py")

if [ ! -z "$python_worker_pid" ]; then
  kill -9 $python_worker_pid
fi

# Close all active note windows
# Assuming windows have titles starting with "NOTE_"
i3-msg '[title="^NOTE_"] move scratchpad'

# Optional: Switch back to the default i3 mode or perform other cleanup
i3-msg "mode default"
