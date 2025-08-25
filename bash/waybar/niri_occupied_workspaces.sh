#!/usr/bin/env bash
set -euo pipefail

# Outputs a compact list of non-empty Niri workspaces as Waybar custom JSON.
# Active workspaces are wrapped in brackets [ ].
#
# Example output:
# {"text":"1 [2] 3 11","tooltip":false}

get_workspaces() {
  niri msg -j workspaces 2>/dev/null || echo '[]'
}

format_ws_list() {
  jq -r '
    [ .[]
      | select(.active_window_id != null)
      | { idx: .idx,
          active: .is_active,
          name: (.name // (.idx|tostring)) }
    ]
    | sort_by(.idx)
    | map(if .active
           then ("<span foreground=\"#f8f32b\" weight=\"bold\" size=\"larger\">" + .name + "</span>")
           else ("<span foreground=\"#c2bfe0\">" + .name + "</span>")
          end)
    | join(" ")
  '
}

ws_json=$(get_workspaces)

# Optional output filter: pass output name as first arg
if [ "${1-}" != "" ]; then
  ws_json=$(printf "%s" "$ws_json" | jq --arg out "$1" '[ .[] | select(.output == $out) ]')
fi

text=$(printf "%s" "$ws_json" | format_ws_list)

# Fallback text when no workspaces are occupied
if [ -z "$text" ]; then
  text=""
fi

# Emit proper JSON with escaped text for Waybar
jq -cn --arg text "$text" '{text:$text, tooltip:false}'
