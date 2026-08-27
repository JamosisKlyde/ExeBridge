#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VERSION="0.4.0"
REQUESTED_DISTRO=""

usage() {
    cat <<USAGE
Usage: ./install.sh [--distro fedora|ubuntu|arch]

ExeBridge auto-detects Fedora, Ubuntu, and Arch-family systems.
Fedora is the fallback/default when detection is inconclusive.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --distro)
            [[ $# -ge 2 ]] || { echo "ERROR: --distro needs a value." >&2; exit 2; }
            REQUESTED_DISTRO="${2,,}"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "ERROR: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

normalize_distro() {
    case "${1,,}" in
        fedora) echo "Fedora" ;;
        ubuntu) echo "Ubuntu" ;;
        arch) echo "Arch" ;;
        *) return 1 ;;
    esac
}

detect_distro() {
    local id="" like=""
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        id="${ID:-}"
        like="${ID_LIKE:-}"
    fi
    case " ${id,,} ${like,,} " in
        *" ubuntu "*) echo "Ubuntu" ;;
        *" arch "*) echo "Arch" ;;
        *" fedora "*) echo "Fedora" ;;
        *) echo "Fedora" ;;
    esac
}

if [[ -n "$REQUESTED_DISTRO" ]]; then
    DISTRO="$(normalize_distro "$REQUESTED_DISTRO")" || {
        echo "ERROR: supported modes are fedora, ubuntu, and arch." >&2
        exit 2
    }
else
    DISTRO="$(detect_distro)"
fi

HOST_ARCH="$(uname -m)"

echo "========================================"
echo " ExeBridge ${VERSION} installer / upgrader"
echo "========================================"
echo
echo "Distribution mode: $DISTRO"
echo "Fedora is ExeBridge's fallback/default mode; Ubuntu and Arch are fully selectable modes."
echo "Administrator authentication is used only for system dependencies."
echo "Normal ExeBridge launches do not use sudo or pkexec."
echo

install_fedora() {
    command -v dnf >/dev/null || { echo "ERROR: Fedora mode requires dnf." >&2; exit 1; }
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

    sudo dnf install -y bubblewrap || echo "WARNING: bubblewrap unavailable; Restricted mode will be disabled."

    if [[ "$HOST_ARCH" == "x86_64" ]]; then
        sudo dnf install -y \
            mesa-vulkan-drivers.i686 \
            mesa-dri-drivers.i686 \
            vulkan-loader.i686 \
            || echo "WARNING: one or more Fedora 32-bit graphics packages were unavailable."
    fi
}

install_ubuntu() {
    command -v apt-get >/dev/null || { echo "ERROR: Ubuntu mode requires apt-get." >&2; exit 1; }

    if [[ "$HOST_ARCH" == "x86_64" ]] && command -v dpkg >/dev/null; then
        if ! dpkg --print-foreign-architectures | grep -qx i386; then
            echo "Enabling Ubuntu i386 multiarch for 32-bit Windows applications…"
            sudo dpkg --add-architecture i386
        fi
    fi

    sudo apt-get update
    sudo apt-get install -y \
        python3-pyqt6 \
        gamemode \
        curl \
        tar \
        gzip \
        xdg-utils \
        desktop-file-utils \
        winetricks \
        binutils \
        bubblewrap

    if [[ "$HOST_ARCH" == "x86_64" ]]; then
        sudo apt-get install -y \
            mesa-vulkan-drivers:i386 \
            libvulkan1:i386 \
            libgl1-mesa-dri:i386 \
            || echo "WARNING: one or more Ubuntu 32-bit graphics packages were unavailable. Proprietary GPU drivers can require vendor-specific i386 libraries."
    fi
}

install_arch() {
    command -v pacman >/dev/null || { echo "ERROR: Arch mode requires pacman." >&2; exit 1; }
    sudo pacman -S --needed --noconfirm \
        python-pyqt6 \
        gamemode \
        curl \
        tar \
        gzip \
        xdg-utils \
        desktop-file-utils \
        winetricks \
        binutils \
        bubblewrap

    if [[ "$HOST_ARCH" == "x86_64" ]]; then
        if pacman -Sl multilib >/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm lib32-mesa lib32-vulkan-icd-loader \
                || echo "WARNING: one or more Arch 32-bit graphics packages were unavailable."

            # Match common installed 64-bit Vulkan drivers with their 32-bit counterparts.
            declare -A drivers=(
                [vulkan-radeon]=lib32-vulkan-radeon
                [vulkan-intel]=lib32-vulkan-intel
                [vulkan-nouveau]=lib32-vulkan-nouveau
                [vulkan-swrast]=lib32-vulkan-swrast
                [nvidia-utils]=lib32-nvidia-utils
            )
            for native in "${!drivers[@]}"; do
                if pacman -Q "$native" >/dev/null 2>&1; then
                    sudo pacman -S --needed --noconfirm "${drivers[$native]}" \
                        || echo "WARNING: could not install ${drivers[$native]}; install the matching 32-bit GPU driver manually if needed."
                fi
            done
        else
            echo "WARNING: Arch multilib is not enabled. ExeBridge will install, but 32-bit Windows apps may need multilib plus lib32 graphics packages."
        fi
    fi
}

case "$DISTRO" in
    Fedora) install_fedora ;;
    Ubuntu) install_ubuntu ;;
    Arch) install_arch ;;
esac

echo
echo "Installing ExeBridge user-local files…"
bash "$HERE/update.sh"

# Persist the selected/detected distribution mode without disturbing per-app settings.
DISTRO_MODE="$DISTRO" python3 - <<'PY'
import json
import os
from pathlib import Path

path = Path.home() / ".local" / "share" / "exebridge" / "config.json"
try:
    cfg = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(cfg, dict):
        cfg = {}
except Exception:
    cfg = {}
cfg.setdefault("apps", {})
cfg["distribution_mode"] = os.environ["DISTRO_MODE"]
path.parent.mkdir(parents=True, exist_ok=True)
tmp = path.with_suffix(".tmp")
tmp.write_text(json.dumps(cfg, indent=2), encoding="utf-8")
tmp.replace(path)
PY

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
echo " ExeBridge ${VERSION} is ready — $DISTRO mode"
echo "========================================"
echo
echo "Existing prefixes, settings, and desktop shortcuts were preserved."
echo "Open ExeBridge from your application menu or run: $HOME/.local/bin/exebridge"
