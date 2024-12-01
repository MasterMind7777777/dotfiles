#!/bin/bash

# Enter the i3 mode for editing
$HOME/bash/notes/note_sub_mode.sh


# killall i3-nagbar 2>/dev/null
# i3-msg "mode default"

# Prompt for note name
note_name=$(zenity --entry --title="NOTE_NewNotePrompt" --text="Enter the name of the new note:")
if [ -z "$note_name" ]; then
    exit 1
fi

# Create a new note with the date prepended
date=$(date --iso-8601)
full_note_path="$HOME/Notes/${date}_${note_name}.md"
touch $full_note_path

# Open the new note in nvim inside Alacritty
alacritty --title="NOTE_NewNote" --class notes_scratchpad,notes_scratchpad -e nvim $full_note_path &

# Wait a moment to make sure the window has time to open
sleep 0.2

# Set the new window to floating mode, move it to the center, and focus it
i3-msg '[class="notes_scratchpad"] floating enable, move position 500 px 300 px, focus'
