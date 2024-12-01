#!/bin/bash

# Check if an Alacritty instance with class 'scratchpad' is running
if ! pgrep -f "alacritty --class scratchpad,scratchpad" >/dev/null; then
    echo "Scratchpad not running. Launching scratchpad..."
    alacritty --class scratchpad,scratchpad &
else
    echo "Scratchpad is already running."
fi

