#!/usr/bin/env bash
set -euo pipefail

# Generate a complete kitty theme matching all keys reported by
# `kitty @ get-colors`, using your Cyberpunk palette. Known keys are
# set explicitly; all others are mapped by light/dark classification.
#
# Writes to: ~/.config/kitty/current-theme.conf

OUTFILE="${HOME}/.config/kitty/current-theme.conf"
LIGHT_HEX=${LIGHT_HEX:-#e6e6f0}  # text
DARK_HEX=${DARK_HEX:-#0d0b1a}    # base
THRESHOLD=${THRESHOLD:-186}

if ! kitty @ get-colors >/dev/null 2>&1; then
  echo "kitty remote control not available. Is kitty running with allow_remote_control?" >&2
  exit 1
fi

# Fixed mapping for known keys from your palette
read -r -d '' FIXED_MAP <<'EOF' || true
background #0d0b1a
foreground #e6e6f0
cursor #00f0ff
selection_background #8276c0
selection_foreground #0d0b1a
active_tab_background #3a305c
active_tab_foreground #e6e6f0
inactive_tab_background #1e1a30
inactive_tab_foreground #6b5da3
active_border_color #d12cff
inactive_border_color #54497a
bell_border_color #f8f32b
url_color #28e0f7
color0 #1e1a30
color1 #ff3a3a
color2 #3effb5
color3 #f8f32b
color4 #28e0f7
color5 #d12cff
color6 #28e0f7
color7 #c2bfe0
color8 #54497a
color9 #ff3a3a
color10 #3effb5
color11 #f8f32b
color12 #28e0f7
color13 #ff2e88
color14 #28e0f7
color15 #e6e6f0
EOF

declare -A FIXED
while read -r K V; do
  [[ -z "${K}" ]] && continue
  FIXED["${K}"]="${V}"
done <<< "${FIXED_MAP}"

tmp_remote=$(mktemp)
kitty @ get-colors | awk 'NF>=2{print $1" "$2}' >"${tmp_remote}"

tmp_out=$(mktemp)

# Do not include comments; print only key value pairs
while read -r KEY VAL; do
  if [[ -v FIXED["${KEY}"] ]]; then
    echo "${KEY} ${FIXED[${KEY}]}" >>"${tmp_out}"
    continue
  fi

  # For other color slots, classify by luminance and choose light/dark
  if [[ "${VAL}" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
    hex=${VAL#'#'}
    R=$((16#${hex:0:2}))
    G=$((16#${hex:2:2}))
    B=$((16#${hex:4:2}))
    L=$(awk -v r="${R}" -v g="${G}" -v b="${B}" 'BEGIN { printf("%d", 0.2126*r + 0.7152*g + 0.0722*b) }')
    repl="${DARK_HEX}"
    if (( L >= THRESHOLD )); then
      repl="${LIGHT_HEX}"
    fi
    echo "${KEY} ${repl}" >>"${tmp_out}"
  else
    # Non-hex values (rare in get-colors output); just echo original
    echo "${KEY} ${VAL}" >>"${tmp_out}"
  fi
done <"${tmp_remote}"

mv "${tmp_out}" "${OUTFILE}"
rm -f "${tmp_remote}"

# Apply live
kitty @ set-colors -a "${OUTFILE}" >/dev/null

echo "Wrote $(wc -l < "${OUTFILE}") keys to ${OUTFILE} and applied them."

