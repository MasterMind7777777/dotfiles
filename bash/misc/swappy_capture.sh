#!/bin/bash
# Ensure the standard screenshot directory exists
SCREENSHOT_DIR="${HOME}/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate a timestamped filename
timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
final_file="${SCREENSHOT_DIR}/${timestamp}.png"

# Create a temporary file to hold the annotated image
tmp_file=$(mktemp /tmp/swappy-XXXXXX.png)

# Capture a region with grim and pipe it into swappy for annotation,
# instructing swappy to write the output to the temporary file.
grim -g "$(slurp)" - | swappy -f - -o "$tmp_file"

# If swappy produced an output file, copy it to the final destination and copy to clipboard
if [ -f "$tmp_file" ]; then
    cp "$tmp_file" "$final_file"
    wl-copy < "$tmp_file"
    rm "$tmp_file"
    echo "Screenshot saved to $final_file and copied to clipboard."
else
    echo "No output file was generated by swappy."
fi

