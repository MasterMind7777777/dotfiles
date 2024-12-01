#!/bin/bash

# Run the Python worker to track window positions
/home/mastermind/bash/notes/venv/bin/python3 /home/mastermind/bash/notes/listen_for_window_move.py &

i3-msg '[title="^NOTE_"] scratchpad show'


# Kill any existing i3-nagbar instances
killall i3-nagbar

# Display the new i3-nagbar for active notes mode
i3-nagbar -t warning -m 'Notes Active Mode: [Mod+s] Save Layout, [Mod+Esc] Exit Notes Active Mode' &

# Enter the i3 mode for editing
i3-msg 'mode "note_active_mode"'
