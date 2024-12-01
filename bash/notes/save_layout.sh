#!/bin/bash
set -e

# Prompt for layout name using Zenity
layout_name=$(zenity --entry --title="Save Layout" --text="Enter layout name:")

# Exit if the user cancels the dialog or enters an empty string
[ -z "$layout_name" ] && exit 1

# Create the layouts directory if it doesn't exist
mkdir -p /home/mastermind/bash/notes/layouts

# Define the full path where the layout will be saved
layout_file="/home/mastermind/bash/notes/layouts/${layout_name}.txt"

# Clear any previous file with the same name
rm -f "$layout_file"
touch "$layout_file"

# Search for windows with title matching our notes
windows=$(wmctrl -l | awk '/NOTE_/ {for (i=4; i<=NF; ++i) printf "%s ",$i; print ""}')

for title in $windows; do
    # Get window ID for the title
    win=$(wmctrl -l | awk -v t="$title" '$0 ~ t {print $1}')

    # Continue to next iteration if no window ID is found
    [ -z "$win" ] && continue

    # Get window position and size
    geometry=$(xdotool getwindowgeometry "$win")
    x=$(echo "$geometry" | awk '/Position/ {print $2}' | awk -F"," '{print $1}')
    y=$(echo "$geometry" | awk '/Position/ {print $2}' | awk -F"," '{print $2}')
    width=$(echo "$geometry" | awk '/Geometry/ {print $2}' | awk -Fx '{print $1}')
    height=$(echo "$geometry" | awk '/Geometry/ {print $2}' | awk -Fx '{print $2}')
    
    # Continue to next iteration if any value is missing
    [ -z "$x" -o -z "$y" -o -z "$width" -o -z "$height" ] && continue

    # Save title, position, and dimensions to the layout file
    echo "$title $x $y $width $height" >> "$layout_file"
done
