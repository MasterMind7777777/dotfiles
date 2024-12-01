#!/bin/bash

# Read saved window titles, positions, and dimensions
while read -r line; do
    title=$(echo $line | awk '{print $1}')
    x=$(echo $line | awk '{print $2}')
    y=$(echo $line | awk '{print $3}')
    width=$(echo $line | awk '{print $4}')
    height=$(echo $line | awk '{print $5}')

    # Get current window ID for the title
    current_win=$(wmctrl -l | grep "$title" | awk '{print $1}')

    if [ -n "$current_win" ]; then
        # Move and resize the window to its saved position and dimensions
        wmctrl -i -r $current_win -e 0,$x,$y,$width,$height
    fi
done < /tmp/active_notes_positions
