#!/bin/bash
# URL to test – note that if this URL redirects to sign_in, you're not downloading the intended content.
URL="https://gitlab.corp.sdgroup.ai/g.nesterenok/slack-test-runner-bot/-/jobs/737"
ITERATIONS=5
total_speed=0

echo "Testing download speed for: $URL"
echo "Performing $ITERATIONS iterations..."

for i in $(seq 1 $ITERATIONS); do
    # Use curl to fetch the URL, discard output, and capture download speed in bytes/sec.
    speed=$(curl -k -o /dev/null -s -w "%{speed_download}" "$URL")
    echo "Iteration $i: $speed bytes/sec"
    total_speed=$(echo "$total_speed + $speed" | bc)
    sleep 1  # slight delay to avoid caching effects
done

average_speed=$(echo "scale=2; $total_speed / $ITERATIONS" | bc)
kb_speed=$(echo "scale=2; $average_speed / 1024" | bc)
mb_speed=$(echo "scale=2; $kb_speed / 1024" | bc)

echo "----------------------------------------"
echo "Average download speed:"
echo "$average_speed bytes/sec"
echo "$kb_speed KB/sec"
echo "$mb_speed MB/sec"

