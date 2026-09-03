#!/bin/sh
# install_missionevents.sh - install the missionevents executable for the current user.
#
# Usage:
#   sh install_missionevents.sh              # installs to ~/.local/bin
#   sh install_missionevents.sh --no-path    # install without touching ~/.zshrc
#   MISSIONEVENTS_BINDIR=/some/dir sh install_missionevents.sh
#
# What it does:
#   1. Checks for zsh and awk (required at runtime).
#   2. Copies the missionevents executable to the bin directory.
#   3. Adds the bin directory to PATH in ~/.zshrc if it isn't there already
#      (skipped with --no-path).
#   4. Prints next steps.
set -eu

NO_PATH=0
for arg in "$@"; do
  case "$arg" in
    --no-path) NO_PATH=1 ;;
    -h|--help)
      echo "usage: sh install_missionevents.sh [--no-path]"
      echo "  --no-path   install the executable without modifying ~/.zshrc"
      echo "  MISSIONEVENTS_BINDIR=dir overrides the install location (default ~/.local/bin)"
      exit 0 ;;
    *) echo "error: unknown option '$arg' (try --help)" >&2; exit 2 ;;
  esac
done

SRC_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC="$SRC_DIR/missionevents"
DEST_DIR="${MISSIONEVENTS_BINDIR:-$HOME/.local/bin}"
DEST="$DEST_DIR/missionevents"

command -v zsh >/dev/null 2>&1 || { echo "error: zsh is required but was not found." >&2; exit 1; }
command -v awk >/dev/null 2>&1 || { echo "error: awk is required but was not found." >&2; exit 1; }
[ -f "$SRC" ] || { echo "error: $SRC not found - run this script from the directory containing missionevents." >&2; exit 1; }

mkdir -p "$DEST_DIR"
cp "$SRC" "$DEST"
chmod +x "$DEST"
echo "Installed: $DEST"

# Make sure DEST_DIR is on PATH (via ~/.zshrc) so missionevents resolves in new shells
if [ "$NO_PATH" = 1 ]; then
  case ":$PATH:" in
    *":$DEST_DIR:"*) ;;
    *) echo "Skipping PATH setup (--no-path). Ensure $DEST_DIR is on your PATH,"
       echo "or invoke the tool by full path: $DEST" ;;
  esac
else
  case ":$PATH:" in
    *":$DEST_DIR:"*) on_path=yes ;;
    *)               on_path=no  ;;
  esac
  if [ "$on_path" = no ]; then
    ZRC="$HOME/.zshrc"
    if grep -qF "$DEST_DIR" "$ZRC" 2>/dev/null; then
      echo "$DEST_DIR is referenced in $ZRC but not on this PATH - open a new terminal."
    else
      { echo ""; echo "# Added by missionevents installer"; echo "export PATH=\"$DEST_DIR:\$PATH\""; } >> "$ZRC"
      echo "Added $DEST_DIR to PATH in $ZRC"
    fi
  fi
fi

echo
echo "Next steps:"
if [ "$NO_PATH" = 1 ]; then
  echo "  1. missionevents --build    # create your first mission profile (guided)"
  echo "  2. missionevents --help     # quick reference"
  echo "     (if missionevents doesn't resolve, use the full path: $DEST)"
else
  echo "  1. Open a new terminal (or run: exec zsh)"
  echo "  2. missionevents --build    # create your first mission profile (guided)"
  echo "  3. missionevents --help     # quick reference"
fi
echo
echo "Notes:"
echo "  - ssh access to the mission host is required; password auth works,"
echo "    ssh keys just skip the prompt."
echo "  - Profiles are stored per-user in ~/.missionevents/profiles/"
echo "  - Uninstall: rm \"$DEST\""
