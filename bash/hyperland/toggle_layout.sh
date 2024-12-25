#!/usr/bin/env bash

# Query the current keyboard layout for the main keyboard
current_layout=$(
  hyprctl devices | awk '
    # Whenever a new Keyboard at ... line appears, clear any previously stored layout
    /Keyboard at/ {
      layout = ""
    }

    # When we see a "rules:" line, look for the token "l" and take the next field
    /rules:/ {
      for (i = 1; i <= NF; i++) {
        if ($i == "l") {
          layout = $(i + 1)
        }
      }
    }

    # If we see "main: yes", that means the current device is the main keyboard
    /main: yes/ {
      if (layout != "") {
        print layout
        exit
      }
    }
  ' | tr -d '",'
)

# Toggle between layouts
if [ "$current_layout" = "us" ]; then
    hyprctl keyword input:kb_layout ru
else
    hyprctl keyword input:kb_layout us
fi
# #!/bin/bash
# current_layout=$(setxkbmap -query | awk '/layout/ {print $2}')
# if [ "$current_layout" = "us" ]; then
#     setxkbmap -layout ru
# else
#     setxkbmap -layout us
# fi
#
