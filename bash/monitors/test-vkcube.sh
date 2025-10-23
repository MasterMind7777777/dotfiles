bash <<'SH'
set -euo pipefail
pass(){ printf "\033[32m✅ %s\033[0m\n" "$*"; }
warn(){ printf "\033[33m⚠️  %s\033[0m\n" "$*"; }
echo "=== GameMode + Gamescope sanity ==="

# 0) Services/binaries
systemctl --user is-active --quiet gamemoded.service && pass "gamemoded is active" || warn "gamemoded NOT active"
gamemoded --version 2>/dev/null || true
gamescope --version 2>/dev/null | sed -n '1p' || warn "gamescope not found"
command -v vkcube >/dev/null || warn "vkcube (vulkan-tools) not installed"
command -v prime-run >/dev/null || warn "prime-run (nvidia-prime) not installed"

# 1) Record power profile before run
BEFORE="$(powerprofilesctl get 2>/dev/null || echo '?')"
echo "Power profile before: $BEFORE"

# 2) Launch a 6s PRIME+dGPU test under GameMode + Gamescope
#    - gamescope wraps vkcube
#    - timeout auto-closes after 6s
timeout 6s prime-run gamemoderun gamescope -f -w 1920 -h 1200 -r 60 --immediate-flips -- vkcube >/dev/null 2>&1 & PID=$!

# 3) Sample during run
sleep 1
DURING="$(powerprofilesctl get 2>/dev/null || echo '?')"
echo "Power profile during: $DURING"
if [ "$DURING" = "performance" ]; then
  pass "GameMode hook engaged (performance profile)"
else
  warn "Profile did not flip to performance (check ~/.config/gamemode.ini hook path)"
fi

# 4) See if NVIDIA shows activity (optional but nice)
if command -v nvidia-smi >/dev/null 2>&1; then
  echo "GPU sample (nvidia-smi pmon):"
  nvidia-smi pmon -c 1 2>/dev/null | sed -n '1,12p' || true
fi

# 5) Wait for the test to exit
wait $PID 2>/dev/null || true
sleep 0.5
AFTER="$(powerprofilesctl get 2>/dev/null || echo '?')"
echo "Power profile after:  $AFTER"
[ "$AFTER" = "$BEFORE" ] && pass "Profile restored after exit" || warn "Profile did not restore (hook end script?)"

echo "=== Done. Expectations: DURING=performance, AFTER=BEFORE, nvidia-smi shows gamescope/vkcube on dGPU ==="
SH
