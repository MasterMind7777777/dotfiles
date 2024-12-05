#!/bin/bash

SCRATCHPAD_CLASS="scratchpad"

# Find the window address for the scratchpad
WIN_ID=$(hyprctl clients | grep -B 4 "class: $SCRATCHPAD_CLASS" | grep "address" | awk '{print $2}')

if [ -z "$WIN_ID" ]; then
    # Launch the terminal with the scratchpad class if it doesn't exist
    kitty --class $SCRATCHPAD_CLASS &
else
    # Check if the scratchpad is currently focused
    FOCUSED_WIN=$(hyprctl activewindow -j | jq -r '.address')

    if [ "$FOCUSED_WIN" = "$WIN_ID" ]; then
        # Minimize (hide) the scratchpad if it is focused
        hyprctl dispatch movetoworkspace silent,-1 address:$WIN_ID
    else
        # Bring the scratchpad to focus and raise it
        hyprctl dispatch focuswindow address:$WIN_ID
    fi
fi
