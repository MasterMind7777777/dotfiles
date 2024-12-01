#!/bin/bash

# Check if an Alacritty instance with class 'scratchpad' is running
if ! pgrep -f "alacritty --class scratchpad,scratchpad" >/dev/null; then
    echo "Scratchpad not running. Launching scratchpad..."
    alacritty --class scratchpad,scratchpad &
    sleep 1 # Allow time for the terminal to initialize
fi

# Show the scratchpad and move it to the center of the screen
echo "Showing and centering scratchpad..."
i3-msg '[instance="scratchpad"] scratchpad show; [instance="scratchpad"] move position center'

