#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Lock screen"
bash "$SCRIPT_DIR/lock-plugin/uninstall.sh"

echo
echo "==> Launcher"
bash "$SCRIPT_DIR/launcher/uninstall.sh"
