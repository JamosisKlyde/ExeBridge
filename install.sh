#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " ExeBridge 0.3.0 installer / upgrader"
echo "========================================"
echo
echo "Administrator authentication is used only for Fedora system dependencies."
echo "Normal ExeBridge launches and future user-local ExeBridge package updates do not use sudo or pkexec."
echo

if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    if [[ "${ID:-}" != "fedora" ]]; then
        echo "WARNING: This installer is designed for Fedora. Detected: ${PRETTY_NAME:-unknown}"
        read -r -p "Continue anyway? [y/N] " ans
        [[ "${ans,,}" == "y" ]] || exit 1
    fi
fi

sudo dnf install -y \
    python3-pyqt6 \
    gamemode \
    curl \
    tar \
    gzip \
    xdg-utils \
    desktop-file-utils \
    winetricks \
    binutils

echo
echo "Installing optional containment + 32-bit graphics compatibility packages…"
sudo dnf install -y bubblewrap || echo "WARNING: bubblewrap unavailable; Restricted mode will be disabled."

sudo dnf install -y \
    mesa-vulkan-drivers.i686 \
    mesa-dri-drivers.i686 \
    vulkan-loader.i686 || echo "WARNING: One or more 32-bit graphics packages were unavailable; ExeBridge will still install."

bash "$HERE/update.sh"

if [[ ! -x "$HOME/.local/bin/umu-run" ]]; then
    echo
echo "UMU backend is not installed yet; installing the pinned verified backend…"
    install -m 0755 "$HERE/bootstrap_umu.sh" "$HOME/.local/share/exebridge/bootstrap_umu.sh"
    bash "$HOME/.local/share/exebridge/bootstrap_umu.sh"
else
    echo
echo "Existing UMU backend found; leaving it in place."
fi

echo
echo "========================================"
echo " ExeBridge 0.3.0 is ready"
echo "========================================"
echo
echo "Existing prefixes, settings, and desktop shortcuts were preserved."
echo "Open ExeBridge from KDE or run: $HOME/.local/bin/exebridge"
