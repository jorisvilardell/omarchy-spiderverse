#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
