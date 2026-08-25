#!/bin/bash
set -euo pipefail

# Puts Omarchy's own lock screen back.
#
# Deleting the clone's directory is not enough: enabling a clone pushes its
# source id into `disabledPlugins`, so `omarchy.lock` stays off and the session
# ends up with no lock screen at all. Disable, delete, then re-enable the source.

PLUGIN_DIR=$(find "$HOME/.config/omarchy/plugins" -maxdepth 1 -type d -name "*.lock" 2>/dev/null | head -n1)

if [ -z "$PLUGIN_DIR" ]; then
  echo "No lock plugin clone found — nothing to undo."
  exit 0
fi

id=$(basename "$PLUGIN_DIR")
omarchy-plugin-disable "$id" >/dev/null 2>&1 || true
rm -rf "$PLUGIN_DIR"
omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
omarchy-plugin-enable omarchy.lock >/dev/null 2>&1 || true
omarchy restart shell >/dev/null 2>&1 || true

echo "Removed $id and re-enabled omarchy.lock."
