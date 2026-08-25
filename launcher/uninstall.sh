#!/bin/bash
set -euo pipefail

# Removes the launcher and leaves Omarchy's menu as the only one.
#
# Keybindings are not touched: they were never installed automatically, so
# whatever you added from hyprland-snippets.lua is yours to remove. Until you
# do, SUPER+SPACE will point at a command that no longer exists.

CONFIG_NAME="spiderverse-launcher"

if command -v omarchy-spiderverse-launcher >/dev/null 2>&1; then
  omarchy-spiderverse-launcher stop >/dev/null 2>&1 || true
fi

rm -f "$HOME/.local/bin/omarchy-spiderverse-launcher"
rm -rf "$HOME/.config/quickshell/$CONFIG_NAME"

cat <<MSG
Removed the launcher.

Restore the stock keybindings in ~/.config/hypr/bindings.lua by dropping the
lines you copied from launcher/hyprland-snippets.lua — Omarchy's defaults are:

  SUPER + SPACE        omarchy-menu toggle
  SUPER + ALT + SPACE  omarchy-menu toggle apps
MSG
