#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/axelfrache/omarchy-spiderverse.git"
THEME_REPO_URL="https://github.com/axelfrache/omarchy-spiderverse-theme.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd || echo "")"

if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/launcher/install.sh" ]; then
  # Running via curl | bash -- no local clone to read from, so grab one.
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TMP_DIR"' EXIT
  git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo" >/dev/null 2>&1
  exec bash "$TMP_DIR/repo/install.sh"
fi

echo "==> Theme"
omarchy theme install "$THEME_REPO_URL"

echo
echo "==> Launcher"
bash "$SCRIPT_DIR/launcher/install.sh"

echo
echo "==> Lock screen"
bash "$SCRIPT_DIR/lock-plugin/install.sh"

echo
echo "All three installed. Run 'omarchy restart shell' to pick up the lock screen,"
echo "and add the launcher keybindings from launcher/hyprland-snippets.lua yourself."
