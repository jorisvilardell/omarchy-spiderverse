#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Clone Omarchy's real lock service fresh from *your* current Omarchy
# install, instead of shipping a copy of Service.qml in this repo. That file
# is the real PAM auth + ext-session-lock-v1 logic -- a copy committed here
# would freeze at today's version and silently miss any future Omarchy
# security fixes. This way you always get your own, current Service.qml.
omarchy plugin clone omarchy.lock --edit

PLUGIN_DIR=$(find "$HOME/.config/omarchy/plugins" -maxdepth 1 -type d -name "*.lock" 2>/dev/null | head -n1)

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
