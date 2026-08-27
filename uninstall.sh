#!/usr/bin/env bash
set -euo pipefail

echo "This removes the ExeBridge application and desktop integration."
echo "Managed Windows prefixes are NOT deleted automatically."
read -r -p "Continue? [y/N] " ans
[[ "${ans,,}" == "y" ]] || exit 0

rm -f "$HOME/.local/bin/exebridge"
rm -f "$HOME/.local/share/applications/exebridge.desktop"
rm -f "$HOME/.local/share/icons/hicolor/scalable/apps/exebridge.svg"
rm -rf "$HOME/.local/share/exebridge/app"
rm -f "$HOME/.local/share/exebridge/bootstrap_umu.sh"

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" || true
fi

echo
echo "ExeBridge removed."
echo "Your prefixes remain in:"
echo "  $HOME/.local/share/exebridge/prefixes"
echo "Delete that directory manually only if you no longer need the installed Windows programs/data."
