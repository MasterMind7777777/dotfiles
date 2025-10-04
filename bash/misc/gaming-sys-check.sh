bash <<'SH'
set -euo pipefail
GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; NC='\033[0m'
ok(){ echo -e "${GREEN}✅ $*${NC}"; }
warn(){ echo -e "${YELLOW}⚠️  $*${NC}"; }
fail(){ echo -e "${RED}❌ $*${NC}"; }

echo "=== Arch Gaming Stack Check (Hybrid NVIDIA + Intel) ==="
echo "User: $USER  Host: $(hostname)  Kernel: $(uname -r)"

# 0) Packages & tools presence
have(){ command -v "$1" >/dev/null 2>&1; }
pkgq(){ pacman -Q "$1" 2>/dev/null || true; }

for c in steam gamescope gamemoderun gamemoded vulkaninfo nvidia-smi prime-run; do
  if have "$c"; then ok "$c found"; else warn "$c NOT found in PATH"; fi
done

# 1) NVIDIA userspace vs kernel module
echo "--- NVIDIA driver state ---"
pkg_nv=$(pkgq nvidia | awk '{print $2}')
pkg_nvu=$(pkgq nvidia-utils | awk '{print $2}')
pkg_dkms=$(pkgq nvidia-dkms | awk '{print $2}')
headers=$(pkgq linux-headers | awk '{print $2}')
echo "pkg: nvidia=${pkg_nv:-none}  nvidia-utils=${pkg_nvu:-none}  nvidia-dkms=${pkg_dkms:-none}  linux-headers=${headers:-none}"

if modinfo -F version nvidia >/dev/null 2>&1; then
  modver=$(modinfo -F version nvidia)
  ok "Kernel module loaded: nvidia $modver"
else
  warn "Kernel module 'nvidia' NOT loaded (or not installed for this kernel)"
fi

# DKMS status (if installed)
if have dkms; then
  dkms status || true
fi

# 2) KMS / modeset & boot cmdline
echo "--- KMS / modeset ---"
if grep -q 'nvidia_drm.modeset=1' /proc/cmdline; then ok "cmdline has nvidia_drm.modeset=1"; else warn "cmdline missing nvidia_drm.modeset=1"; fi
if sudo cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null | grep -qE 'Y|1'; then
  ok "nvidia_drm KMS modeset is ENABLED"
else
  warn "nvidia_drm KMS modeset appears DISABLED"
fi

# 3) Power Profiles + GameMode
echo "--- Power & GameMode ---"
if systemctl is-active --quiet power-profiles-daemon; then
  cur=$(powerprofilesctl get || echo "?")
  ok "power-profiles-daemon running (current: $cur)"
else
  warn "power-profiles-daemon NOT active"
fi
if systemctl --user is-active --quiet gamemoded.service; then
  gamemoded --version | sed 's/^/   /'
  ok "GameMode daemon active"
else
  warn "gamemoded (user) not active"
fi

# 4) Vulkan ICDs & enumeration (iGPU path)
echo "--- Vulkan loader / ICDs ---"
ls -1 /usr/share/vulkan/icd.d 2>/dev/null | sed 's/^/   /' || warn "No /usr/share/vulkan/icd.d"
if [ -n "${VK_ICD_FILENAMES:-}" ]; then warn "VK_ICD_FILENAMES is set: $VK_ICD_FILENAMES (may limit devices)"; else ok "VK_ICD_FILENAMES not set"; fi

if vulkaninfo >/dev/null 2>&1; then
  vulkaninfo | grep -E 'GPU id|deviceName' | sed -n '1,6p' || true
  ok "Vulkan enumerates (iGPU context)"
else
  fail "vulkaninfo failed; Vulkan loader not working"
fi

# 5) PRIME offload (dGPU path)
echo "--- PRIME offload (NVIDIA dGPU visibility) ---"
if have prime-run; then
  if prime-run vulkaninfo >/dev/null 2>&1; then
    prime-run vulkaninfo | grep -E 'GPU id|deviceName' | sed -n '1,10p'
    ok "Vulkan enumerates under prime-run (dGPU visible)"
  else
    warn "prime-run vulkaninfo failed (dGPU not visible in Vulkan). Check nvidia module/ICD."
  fi
else
  warn "prime-run not found (install nvidia-prime)"
fi

# 6) Gamescope version & quick run sanity
echo "--- Gamescope ---"
if gamescope --version >/dev/null 2>&1; then
  gamescope --version | sed 's/^/   /'
  ok "Gamescope present"
else
  warn "Gamescope not found"
fi

# 7) Steam/Proton helpers
echo "--- Steam / Proton helpers ---"
if have protontricks; then protontricks --version | sed 's/^/   /'; ok "protontricks present"; else warn "protontricks not found"; fi

found_ge="no"
for d in "$HOME/.steam/root/compatibilitytools.d" "$HOME/.local/share/Steam/compatibilitytools.d" "/usr/share/steam/compatibilitytools.d"; do
  [ -d "$d" ] || continue
  if ls -1 "$d" | grep -qiE 'GE[-_]Proton'; then
    echo "   Proton compat tools in $d:"
    ls -1 "$d" | sed 's/^/     /'
    found_ge="yes"
  fi
done
[ "$found_ge" = "yes" ] && ok "Proton-GE detected" || warn "Proton-GE not found in standard paths"

# 8) GameMode → Performance auto-toggle test (requires your hook script, if set)
echo "--- GameMode Performance auto-toggle smoke test ---"
HOOK="$HOME/.local/bin/gamemode-ppd.sh"
if [ -x "$HOOK" ]; then
  before=$(powerprofilesctl get || echo "?")
  gamemoderun bash -c 'sleep 2' &
  pid=$!; sleep 1
  mid=$(powerprofilesctl get || echo "?")
  wait "$pid"
  after=$(powerprofilesctl get || echo "?")
  echo "   Profile before: $before"
  echo "   Profile during: $mid"
  echo "   Profile after : $after"
  if [ "$mid" = "performance" ] && [ "$after" = "$before" ]; then
    ok "Auto-toggle via GameMode hook works"
  else
    warn "Auto-toggle didn’t behave as expected (check ~/.config/gamemode.ini hook path)"
  fi
else
  warn "No PPD hook at $HOOK; skipping toggle test (optional feature)"
fi

# 9) nvidia-smi check (post-DKMS/reboot)
echo "--- nvidia-smi ---"
if nvidia-smi >/dev/null 2>&1; then
  nvidia-smi | sed -n '1,5p'
  ok "nvidia-smi OK"
else
  warn "nvidia-smi failed (expected if module mismatch / not loaded yet)."
fi

echo "=== Summary hints ==="
if ! modinfo -F version nvidia >/dev/null 2>&1; then
  echo " • NVIDIA module missing for current kernel. On stock kernel:"
  echo "     sudo pacman -S --needed linux-headers nvidia nvidia-utils lib32-nvidia-utils"
  echo "   On zen/lts/custom: prefer DKMS:"
  echo "     sudo pacman -S --needed linux-headers nvidia-dkms nvidia-utils lib32-nvidia-utils"
fi
if ! systemctl --user is-active --quiet gamemoded.service; then
  echo " • Enable GameMode: systemctl --user enable --now gamemoded.service"
fi
if ! systemctl is-active --quiet power-profiles-daemon; then
  echo " • Enable PPD: sudo systemctl enable --now power-profiles-daemon"
fi
if [ "$found_ge" != "yes" ]; then
  echo " • Install Proton-GE via ProtonUp-Qt or AUR (proton-ge-custom)"
fi
echo "=== Done. ==="
SH
