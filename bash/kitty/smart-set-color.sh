#!/usr/bin/env bash
set -euo pipefail

# Smartly set a single kitty color key based on its current brightness.
# If current value is light, replace with your light color; if dark, replace with your dark color.
#
# Usage: smart-set-color.sh <kitty_color_key>
# Examples:
#   smart-set-color.sh foreground
#   smart-set-color.sh selection_foreground
#   smart-set-color.sh color6
#
# Overrides (optional):
#   LIGHT_HEX  - hex for light replacement (default: #e6e6f0)
#   DARK_HEX   - hex for dark replacement  (default: #0d0b1a)
#   THRESHOLD  - brightness threshold 0-255 (default: 186)

KEY=${1:-}
if [[ -z "${KEY}" ]]; then
  echo "Usage: $0 <kitty_color_key>" >&2
  exit 2
fi

LIGHT_HEX=${LIGHT_HEX:-#e6e6f0}  # Waybar text
DARK_HEX=${DARK_HEX:-#0d0b1a}    # Waybar base
THRESHOLD=${THRESHOLD:-186}

# Ensure kitty is reachable
if ! kitty @ get-colors >/dev/null 2>&1; then
  echo "kitty remote control not available (is kitty running with allow_remote_control?)" >&2
  exit 1
fi

# Fetch current colors and extract the hex for the requested key
current_line=$(kitty @ get-colors | awk -v k="${KEY}" '$1==k {print; exit}')
if [[ -z "${current_line}" ]]; then
  echo "Key '${KEY}' not found in kitty @ get-colors output" >&2
  exit 3
fi

current_hex=$(awk '{print $2}' <<<"${current_line}")

# Normalize hex like #RRGGBB
if [[ ! "${current_hex}" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
  echo "Unexpected color format for ${KEY}: ${current_hex}" >&2
  exit 4
fi

hex=${current_hex#'#'}
R=$((16#${hex:0:2}))
G=$((16#${hex:2:2}))
B=$((16#${hex:4:2}))

# Perceived luminance (Rec. 709)
# L = 0.2126*R + 0.7152*G + 0.0722*B
L=$(awk -v r="${R}" -v g="${G}" -v b="${B}" 'BEGIN { printf("%d", 0.2126*r + 0.7152*g + 0.0722*b) }')

replacement="${DARK_HEX}"
if (( L >= THRESHOLD )); then
  replacement="${LIGHT_HEX}"
fi

echo "${KEY} ${current_hex} -> ${replacement} (L=${L}, threshold=${THRESHOLD})"
kitty @ set-colors "${KEY}=${replacement}"

