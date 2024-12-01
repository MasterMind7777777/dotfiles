#!/bin/bash
# Clear the previous file
rm -f /tmp/active_notes_positions
touch /tmp/active_notes_positions

# Search for windows with title matching our notes
windows=$(wmctrl -l | grep "NOTE_" | awk '{for (i=4; i<=NF; ++i) printf "%s ",$i; print ""}')

for title in $windows; do
    # Get window ID for the title
    win=$(wmctrl -l | grep "$title" | awk '{print $1}')

    # Get window position and size
    x=$(xdotool getwindowgeometry $win | grep Position | awk '{print $2}' | awk -F"," '{print $1}')
    y=$(xdotool getwindowgeometry $win | grep Position | awk '{print $2}' | awk -F"," '{print $2}')
    width=$(xdotool getwindowgeometry $win | grep Geometry | awk '{print $2}' | awk -Fx '{print $1}')
    height=$(xdotool getwindowgeometry $win | grep Geometry | awk '{print $2}' | awk -Fx '{print $2}')
    
    # Save title, position, and dimensions to a file
    echo "$title $x $y $width $height" >> /tmp/active_notes_positions
done

