#!/bin/sh
# install_me_dedup.sh - install the me_dedup executable for the current user.
#
# Usage:
#   sh install_me_dedup.sh            # installs to ~/.local/bin
#   ME_DEDUP_BINDIR=/some/dir sh install_me_dedup.sh
#
# What it does:
#   1. Checks for zsh and awk (required at runtime).
#   2. Copies the me_dedup executable to the bin directory.
#   3. Adds the bin directory to PATH in ~/.zshrc if it isn't there already.
#   4. Prints next steps.
set -eu

SRC_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC="$SRC_DIR/me_dedup"
DEST_DIR="${ME_DEDUP_BINDIR:-$HOME/.local/bin}"
DEST="$DEST_DIR/me_dedup"

command -v zsh >/dev/null 2>&1 || { echo "error: zsh is required but was not found." >&2; exit 1; }
command -v awk >/dev/null 2>&1 || { echo "error: awk is required but was not found." >&2; exit 1; }
[ -f "$SRC" ] || { echo "error: $SRC not found - run this script from the directory containing me_dedup." >&2; exit 1; }

mkdir -p "$DEST_DIR"
cp "$SRC" "$DEST"
chmod +x "$DEST"
echo "Installed: $DEST"

# Make sure DEST_DIR is on PATH (via ~/.zshrc) so me_dedup resolves in new shells
case ":$PATH:" in
  *":$DEST_DIR:"*) on_path=yes ;;
  *)               on_path=no  ;;
esac
if [ "$on_path" = no ]; then
  ZRC="$HOME/.zshrc"
  if grep -qF "$DEST_DIR" "$ZRC" 2>/dev/null; then
    echo "$DEST_DIR is referenced in $ZRC but not on this PATH - open a new terminal."
  else
    { echo ""; echo "# Added by me_dedup installer"; echo "export PATH=\"$DEST_DIR:\$PATH\""; } >> "$ZRC"
    echo "Added $DEST_DIR to PATH in $ZRC"
  fi
fi

echo
echo "Next steps:"
echo "  1. Open a new terminal (or run: exec zsh)"
echo "  2. me_dedup --build    # create your first mission profile (guided)"
echo "  3. me_dedup --help     # quick reference"
echo
echo "Notes:"
echo "  - ssh access to the mission host is required; password auth works,"
echo "    ssh keys just skip the prompt."
echo "  - Profiles are stored per-user in ~/.me_dedup/profiles/"
echo "  - Uninstall: rm \"$DEST\""
