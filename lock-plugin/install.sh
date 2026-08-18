#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/axelfrache/omarchy-spiderverse.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd || echo "")"

if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/LockView.qml" ]; then
  # Running via curl | bash -- no local clone to read from, so grab one.
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TMP_DIR"' EXIT
  git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo" >/dev/null 2>&1
  exec bash "$TMP_DIR/repo/lock-plugin/install.sh"
fi

PLUGIN_DIR=$(find "$HOME/.config/omarchy/plugins" -maxdepth 1 -type d -name "*.lock" 2>/dev/null | head -n1)

if [ -n "$PLUGIN_DIR" ]; then
  echo "Lock plugin already cloned at $PLUGIN_DIR -- reusing it, not re-cloning."
else
  omarchy plugin clone omarchy.lock --edit
  PLUGIN_DIR=$(find "$HOME/.config/omarchy/plugins" -maxdepth 1 -type d -name "*.lock" 2>/dev/null | head -n1)
fi

if [ -z "$PLUGIN_DIR" ]; then
  echo "error: couldn't find the cloned plugin under ~/.config/omarchy/plugins/*.lock" >&2
  echo "Check the output above, then copy this folder's *.qml/*.js/*.png files" >&2
  echo "into the clone's directory by hand." >&2
  exit 1
fi

cp "$SCRIPT_DIR/LockView.qml" "$SCRIPT_DIR/LockWeb.qml" "$SCRIPT_DIR/LockTheme.js" "$SCRIPT_DIR/SpidermanLogo.png" "$PLUGIN_DIR/"

echo "Installed into $PLUGIN_DIR"
echo "(Service.qml there is Omarchy's own file -- this script never touches it.)"
echo "Run 'omarchy restart shell' to pick it up."
