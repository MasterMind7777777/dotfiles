#!/usr/bin/env sh
# install-codex.sh — Fetch latest Codex CLI and install it (system-wide by default).
# Usage:
#   ./install-codex.sh                      # install to /usr/local/bin (uses sudo if needed)
#   DEST=/usr/local/bin ./install-codex.sh  # change install dir
#   ./install-codex.sh --pre                # allow latest pre-release
#   ./install-codex.sh --force              # overwrite existing binary

set -eu

REPO="openai/codex"
API_LATEST="https://api.github.com/repos/$REPO/releases/latest"
API_RELEASES="https://api.github.com/repos/$REPO/releases?per_page=5"

PRE=0
FORCE=0
DEST="${DEST:-/usr/local/bin}"

# Parse simple flags
while [ $# -gt 0 ]; do
  case "$1" in
    --pre) PRE=1 ;;
    --force) FORCE=1 ;;
    --dest) shift; DEST="${1:-$DEST}" ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
  shift || true
done

# OS triple (Linux = musl builds)
case "$(uname -s)" in
  Linux)  os_tag="unknown-linux-musl" ;;
  Darwin) os_tag="apple-darwin" ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

# Arch triple
case "$(uname -m)" in
  x86_64|amd64)  arch_tag="x86_64" ;;
  aarch64|arm64) arch_tag="aarch64" ;;
  *) echo "Unsupported CPU arch: $(uname -m)" >&2; exit 1 ;;
esac

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }
need_cmd curl
need_cmd tar
need_cmd grep
need_cmd awk
need_cmd install

sudo_if_needed() {
  if [ -w "$1" ] 2>/dev/null; then
    # Writable; no sudo
    shift
    "$@"
  else
    if command -v sudo >/dev/null 2>&1; then
      echo "Elevating with sudo to write to $1…"
      shift
      sudo "$@"
    else
      echo "Destination $1 not writable and 'sudo' not found." >&2
      echo "Re-run with: DEST=\$HOME/.local/bin ./install-codex.sh  (or run as root)" >&2
      exit 1
    fi
  fi
}

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT INT TERM

# Pull release JSON (stable by default; --pre scans a few most recent releases)
if [ "$PRE" -eq 1 ]; then
  json="$(curl -fsSL "$API_RELEASES")"
else
  json="$(curl -fsSL "$API_LATEST")"
fi

# Extract all asset URLs and pick the first match for our platform
pattern="codex-${arch_tag}-${os_tag}\\.tar\\.gz$"
url="$(printf %s "$json" \
  | awk -F'"' '/browser_download_url/ {print $4}' \
  | grep -E "$pattern" \
  | head -n1 || true)"

if [ -z "${url:-}" ]; then
  echo "Could not find an asset matching $pattern in the latest release(s)." >&2
  echo "Available assets were:" >&2
  printf %s "$json" | awk -F'"' '/browser_download_url/ {print "  - "$4}' >&2
  exit 1
fi

echo "Downloading: $url"
tarball="$tmpdir/$(basename "$url")"
curl -fL "$url" -o "$tarball"

echo "Extracting…"
tar -xzf "$tarball" -C "$tmpdir"

# Find the extracted binary
bin_path="$(find "$tmpdir" -maxdepth 1 -type f -name 'codex*' | head -n1)"
[ -n "$bin_path" ] || { echo "Failed to locate extracted codex binary." >&2; exit 1; }
chmod +x "$bin_path"

target="$DEST/codex"

# Prepare destination directory
if [ ! -d "$DEST" ]; then
  sudo_if_needed "$(dirname "$DEST")" install -d -m 0755 "$DEST"
fi

# Existing file check
if [ -e "$target" ] && [ "$FORCE" -ne 1 ]; then
  echo "codex already exists at $target"
  echo "Use --force to overwrite or set DEST=/some/dir to install elsewhere."
  exit 1
fi

# Install atomically
sudo_if_needed "$DEST" install -m 0755 "$bin_path" "$target"

echo "Installed to: $target"
("$target" --version || "$target" -V || true) 2>/dev/null

# Warn if a different codex earlier in PATH would shadow this one
if command -v codex >/dev/null 2>&1; then
  in_path="$(command -v codex || true)"
  if [ "$in_path" != "$target" ]; then
    echo "Warning: another 'codex' at $in_path may shadow $target"
  fi
fi

echo "Tip: if your shell caches PATH lookups, run 'hash -r' (bash) or 'rehash' (zsh)."
