#!/bin/bash

# Function to kill existing note windows
kill_existing_notes() {
    i3-msg '[title="^NOTE_"] kill'
}

# Function to check if a window with the given title exists
window_exists() {
    local title=$1
    i3-msg -t get_tree | jq -e "recurse(.nodes[]) | select(.window_properties? and .window_properties.title==\"$title\")" > /dev/null
}

# Function to open a note in a floating window
open_note() {
    local note=$1
    local title="NOTE_$(basename $note)"
    
    if ! window_exists "$title"; then
        i3-msg "exec --no-startup-id alacritty --title $title -e nvim $note"
        sleep 0.2
    fi

    i3-msg "[title=\"$title\"] floating enable"
}

# Function to move note to scratchpad
move_to_scratchpad() {
    local note=$1
    local title="NOTE_$(basename $note)"
    i3-msg "[title=\"$title\"] move scratchpad"
}

# Main program starts here

# Check if any active notes exist
if [ ! "$(ls -A ~/Notes/active)" ]; then
    echo "No active notes found."
    exit 1
fi

# Kill existing note windows
kill_existing_notes

# Iterate over all active notes
for note in ~/Notes/active/*.{txt,md}; do
    # Skip if it's not a file
    [ -f "$note" ] || continue
    open_note "$note"
done

# Wait for the terminal to open
sleep 0.2

# Restore positions (Assuming this script is well-defined)
~/path/to/your/restore_positions.sh

# Move notes to scratchpad
for note in ~/Notes/active/*.{txt,md}; do
    # Skip if it's not a file
    [ -f "$note" ] || continue
    move_to_scratchpad "$note"
done
