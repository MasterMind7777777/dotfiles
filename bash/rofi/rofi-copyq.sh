#!/bin/bash

selected=$(copyq show)

# If a valid item is selected, put it to the clipboard
if [ -n "$selected" ]; then
    copyq select "$selected"
fi
