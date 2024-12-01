#!/bin/bash

# Kill any existing i3-nagbar instances
killall i3-nagbar

# Display the new i3-nagbar
i3-nagbar -t warning -m 'Notes Mode: [n] New Note, [a] Active Notes, [s] Search Notes, [Esc] Exit' &

# Enter the i3 mode
i3-msg 'mode "notes_mode"'
