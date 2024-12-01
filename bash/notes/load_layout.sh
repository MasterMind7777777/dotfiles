#!/bin/bash

# Function to list available layouts using Rofi
list_layouts() {
    layouts_dir="/home/mastermind/bash/notes/layouts/"
    layouts=($(ls "$layouts_dir"))

    layout_name=$(echo "${layouts[@]}" | tr ' ' '\n' | rofi -dmenu -p "Choose a layout:")
    echo "$layout_name"
}

# Get the chosen layout
layout_name=$(list_layouts)

if [ -z "$layout_name" ]; then
    echo "No layout selected. Exiting."
    exit 1
fi

# Construct the layout file path
layout_file="/home/mastermind/bash/notes/layouts/${layout_name}"

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
done < "$layout_file"

