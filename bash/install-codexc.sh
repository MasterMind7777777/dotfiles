#!/usr/bin/env sh
# install-codexc.sh — Build local Codex CLI and install it as 'codexc'.
# Usage examples:
#   ./install-codexc.sh                            # build from default repo path
#   REPO_DIR=/path/to/codex ./install-codexc.sh    # override repo location
#   DEST=$HOME/.local/bin ./install-codexc.sh      # install to custom bin dir
#   ./install-codexc.sh --force                    # overwrite existing binary
#   ./install-codexc.sh --debug                    # build with debug profile

set -eu

REPO_DIR="${REPO_DIR:-$HOME/projects/forks/codex/codex-rs/}"
DEST="${DEST:-/usr/local/bin}"
PROFILE="${PROFILE:-release}"
NAME="${NAME:-codexc}"
FORCE=0

usage() {
  cat <<USAGE >&2
install-codexc.sh — Build a local Codex CLI and install it as '$NAME'.

Options:
  --repo PATH      Path to the codex repository (default: $REPO_DIR)
  --dest PATH      Target installation directory (default: $DEST)
  --profile NAME   Cargo profile to build (default: $PROFILE)
  --debug          Shortcut for --profile debug
  --force          Overwrite existing binary at destination
  --help           Show this message and exit

Environment overrides:
  REPO_DIR, DEST, PROFILE, NAME
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      if [ $# -lt 2 ]; then
        echo "--repo requires a path" >&2
        exit 2
      fi
      REPO_DIR="$2"
      shift
      ;;
    --dest)
      if [ $# -lt 2 ]; then
        echo "--dest requires a path" >&2
        exit 2
      fi
      DEST="$2"
      shift
      ;;
    --profile)
      if [ $# -lt 2 ]; then
        echo "--profile requires a value" >&2
        exit 2
      fi
      PROFILE="$2"
      shift
      ;;
    --debug)
      PROFILE="debug"
      ;;
    --force)
      FORCE=1
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
  esac
  shift
done

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }
need_cmd cargo
need_cmd install

sudo_if_needed() {
  if [ -w "$1" ] 2>/dev/null; then
    shift
    "$@"
  else
    if command -v sudo >/dev/null 2>&1; then
      echo "Elevating with sudo to write to $1…"
      shift
      sudo "$@"
    else
      echo "Destination $1 not writable and 'sudo' not found." >&2
      echo "Re-run with: DEST=\$HOME/.local/bin $0" >&2
      exit 1
    fi
  fi
}

if [ ! -d "$REPO_DIR" ]; then
  echo "Repository directory not found: $REPO_DIR" >&2
  exit 1
fi

case "$PROFILE" in
  release)
    build_flag="--release"
    artifact_dir="release"
    ;;
  debug)
    build_flag=""
    artifact_dir="debug"
    ;;
  *)
    build_flag="--profile $PROFILE"
    artifact_dir="$PROFILE"
    ;;
  esac

cd "$REPO_DIR"

echo "Building codex-cli with profile: $PROFILE"
if [ -n "$build_flag" ]; then
  cargo build -p codex-cli $build_flag
else
  cargo build -p codex-cli
fi

bin_path="$REPO_DIR/target/$artifact_dir/codex"
if [ ! -x "$bin_path" ]; then
  echo "Built binary not found at: $bin_path" >&2
  exit 1
fi

target="$DEST/$NAME"
if [ ! -d "$DEST" ]; then
  sudo_if_needed "$(dirname "$DEST")" install -d -m 0755 "$DEST"
fi

if [ -e "$target" ] && [ "$FORCE" -ne 1 ]; then
  echo "$NAME already exists at $target" >&2
  echo "Use --force to overwrite or set DEST=/some/dir to install elsewhere." >&2
  exit 1
fi

chmod +x "$bin_path"

echo "Installing $bin_path to $target"
sudo_if_needed "$DEST" install -m 0755 "$bin_path" "$target"

"$target" --version || true

echo "Installed custom Codex CLI to: $target"
