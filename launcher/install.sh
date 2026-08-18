#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/axelfrache/omarchy-spiderverse.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd || echo "")"

if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/quickshell/shell.qml" ]; then
  # Running via curl | bash -- no local clone to read from, so grab one.
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TMP_DIR"' EXIT
  git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo" >/dev/null 2>&1
  exec bash "$TMP_DIR/repo/launcher/install.sh"
fi

mkdir -p "$HOME/.config/quickshell/spiderverse-launcher"
cp -r "$SCRIPT_DIR/quickshell/." "$HOME/.config/quickshell/spiderverse-launcher/"

mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/bin/omarchy-spiderverse-launcher" "$HOME/.local/bin/omarchy-spiderverse-launcher"
chmod +x "$HOME/.local/bin/omarchy-spiderverse-launcher"

echo "Installed to ~/.config/quickshell/spiderverse-launcher and ~/.local/bin."
echo
echo "Not applied automatically (they might collide with your own binds) --"
echo "add the keybindings from hyprland-snippets.lua yourself:"
echo "  ~/.config/hypr/bindings.lua"
echo "  ~/.config/hypr/autostart.lua  (optional: pre-warm on login)"
echo "  ~/.config/hypr/hyprland.lua   (optional: kill compositor fade lag)"
