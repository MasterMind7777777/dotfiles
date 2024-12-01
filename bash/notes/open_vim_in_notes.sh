#!/bin/bash


# Enter the i3 mode for editing
$HOME/bash/notes/note_sub_mode.sh

# Unique title for the notes window
unique_title="NOTE_NotesDir"

# Attempt to pull the window with the unique title out of the scratchpad
i3-msg "[title=\"$unique_title\"] scratchpad show"

# Check if the window is already open
window_exists=$(wmctrl -l | grep -c "$unique_title")

# If the window doesn't exist, create it
if [ "$window_exists" -eq 0 ]; then
    # Open Vim in the Notes directory
    alacritty --title "$unique_title" --class notes_scratchpad,notes_scratchpad -e nvim -c ":cd $HOME/Notes | :e ." &

    # Wait a moment to make sure the window has time to open
    sleep 0.2

    # Set floating mode, set position, and focus
    i3-msg "[title=\"$unique_title\"] floating enable, move position 500 300, focus"
fi
