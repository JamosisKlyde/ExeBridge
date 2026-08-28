#!/usr/bin/env bash
set -euo pipefail
rm -f "$HOME/.local/bin/exebridge"
rm -f "$HOME/.local/share/applications/exebridge.desktop"
rm -f "$HOME/.local/share/icons/hicolor/scalable/apps/exebridge.svg"
rm -rf "$HOME/.local/share/exebridge/app"
echo "ExeBridge application files removed."
echo "Prefixes, settings, logs, and version backups were preserved in ~/.local/share/exebridge"
