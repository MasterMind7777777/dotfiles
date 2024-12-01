#!/bin/bash

# Check if Alacritty with class "special" is running
if ! pgrep -f "alacritty --class special"; then
  # If not found, launch Alacritty with class "special" and move it to the special workspace
  alacritty --class special &
  sleep 1 # Wait a moment for Alacritty to launch
  hyprctl dispatch movetoworkspace special # Move Alacritty to the special workspace
fi

