#!/bin/bash

# Define an array of config files with $HOME instead of ~
choices=(
  "$HOME/.config/nvim/init.lua"
  "$HOME/.config/alacritty/alacritty.toml"
  "$HOME/.config/fish/config.fish"
  "$HOME/.config/i3/config"
  "$HOME/.config/polybar/config.ini"
  "$HOME/bash/i3/edit_config.sh"
)

# Create a menu string from the array
menu_string=""
for i in "${!choices[@]}"; do
  menu_string+="$((i+1)). ${choices[$i]}\n"
done

# Use dmenu to select a choice, with a vertical layout
selection=$(echo -e "$menu_string" | rofi -dmenu -i -p 'Select config to edit:')

# Extract the selected index
index=$(echo $selection | cut -d '.' -f 1)


# Open the selected file in NeoVim
if [[ ! -z "$index" && "$index" -ge 1 && "$index" -le ${#choices[@]} ]]; then
	alacritty -e nvim "${choices[$((index-1))]}"
fi
