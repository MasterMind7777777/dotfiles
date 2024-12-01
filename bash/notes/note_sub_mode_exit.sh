#!/bin/bash

# Kill any existing i3-nagbar instances
killall i3-nagbar

# Display the new i3-nagbar for edit mode
i3-nagbar -t warning -m 'Notes Mode: [n] New Note, [a] Active Notes, [s] Search Notes, [Esc] Exit' &

# Enter the i3 mode for editing
i3-msg 'mode "notes_mode"'
