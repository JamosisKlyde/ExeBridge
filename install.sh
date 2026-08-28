#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VERSION="0.5.1"
DISTRO_MODE=""
MODE_EXPLICIT=0

usage() {
    cat <<USAGE
ExeBridge ${VERSION} installer / upgrader

Usage:
  ./install.sh [--distro fedora|ubuntu|arch]

If --distro is omitted, ExeBridge auto-detects Fedora, Ubuntu, or Arch.
Fedora remains the fallback/default mode when detection is inconclusive.
Existing prefixes, settings, Known Good profiles, and shortcuts are preserved.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --distro)
            [[ $# -ge 2 ]] || { echo "ERROR: --distro requires a value." >&2; exit 2; }
            case "${2,,}" in
                fedora) DISTRO_MODE="Fedora" ;;
                ubuntu) DISTRO_MODE="Ubuntu" ;;
                arch|archlinux|arch-linux) DISTRO_MODE="Arch" ;;
                *) echo "ERROR: unsupported distro mode '$2'. Use fedora, ubuntu, or arch." >&2; exit 2 ;;
            esac
            MODE_EXPLICIT=1
            shift 2
            ;;
        -h|--help) usage; exit 0 ;;
        *) echo "ERROR: unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

OS_ID=""; OS_LIKE=""; OS_PRETTY="Unknown Linux"
if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-}"; OS_LIKE="${ID_LIKE:-}"; OS_PRETTY="${PRETTY_NAME:-${NAME:-Unknown Linux}}"
fi

if [[ -z "$DISTRO_MODE" ]]; then
    id_lower="${OS_ID,,}"; like_lower=" ${OS_LIKE,,} "
    if [[ "$id_lower" == "ubuntu" || "$like_lower" == *" ubuntu "* || "$like_lower" == *" debian "* ]]; then
        DISTRO_MODE="Ubuntu"
    elif [[ "$id_lower" == "arch" || "$id_lower" == "manjaro" || "$id_lower" == "endeavouros" || "$like_lower" == *" arch "* ]]; then
        DISTRO_MODE="Arch"
    elif [[ "$id_lower" == "fedora" || "$like_lower" == *" fedora "* || "$like_lower" == *" rhel "* ]]; then
        DISTRO_MODE="Fedora"
    else
        DISTRO_MODE="Fedora"
        echo "WARNING: ${OS_PRETTY} is not one of ExeBridge's three supported distro families."
        echo "Fedora mode will be used as the fallback. Override with --distro ubuntu or --distro arch if appropriate."
        echo
    fi
fi

echo "========================================"
echo " ExeBridge ${VERSION} installer / upgrader"
echo "========================================"
echo "Host: ${OS_PRETTY}"
echo "Distribution mode: ${DISTRO_MODE}"
echo
echo "Administrator authentication is used only for system dependencies."
echo "Normal ExeBridge launches and user-local updates do not use sudo or pkexec."
echo

install_fedora() {
    command -v dnf >/dev/null 2>&1 || { echo "ERROR: Fedora mode requires dnf." >&2; exit 1; }
    sudo dnf install -y python3-pyqt6 gamemode curl tar gzip unzip xdg-utils desktop-file-utils winetricks binutils
    sudo dnf install -y bubblewrap || echo "WARNING: bubblewrap unavailable."
    sudo dnf install -y glibc-langpack-ja || echo "WARNING: Japanese locale pack could not be installed automatically."
    if [[ "$(uname -m)" == "x86_64" ]]; then
        sudo dnf install -y mesa-vulkan-drivers.i686 mesa-dri-drivers.i686 vulkan-loader.i686 \
            || echo "WARNING: One or more Fedora 32-bit graphics packages were unavailable."
    fi
}

install_ubuntu() {
    command -v apt-get >/dev/null 2>&1 || { echo "ERROR: Ubuntu mode requires apt-get." >&2; exit 1; }
    if [[ "$(uname -m)" == "x86_64" ]] && command -v dpkg >/dev/null 2>&1; then
        if ! dpkg --print-foreign-architectures | grep -qx i386; then sudo dpkg --add-architecture i386; fi
    fi
    sudo apt-get update
    sudo apt-get install -y python3-pyqt6 gamemode curl tar gzip unzip xdg-utils desktop-file-utils winetricks binutils bubblewrap locales
    command -v locale-gen >/dev/null 2>&1 && sudo locale-gen ja_JP.UTF-8 || true
    if [[ "$(uname -m)" == "x86_64" ]]; then
        sudo apt-get install -y libvulkan1:i386 mesa-vulkan-drivers:i386 \
            || echo "WARNING: Ubuntu 32-bit Vulkan packages were unavailable."
    fi
}

install_arch() {
    command -v pacman >/dev/null 2>&1 || { echo "ERROR: Arch mode requires pacman." >&2; exit 1; }
    sudo pacman -Syu --needed --noconfirm python-pyqt6 gamemode curl tar gzip unzip xdg-utils desktop-file-utils winetricks binutils bubblewrap vulkan-icd-loader
    if [[ "$(uname -m)" == "x86_64" ]]; then
        sudo pacman -S --needed --noconfirm lib32-vulkan-icd-loader lib32-gamemode \
            || echo "WARNING: Arch multilib packages could not be installed. Enable [multilib] for 32-bit games."
    fi
}

case "$DISTRO_MODE" in
    Fedora) install_fedora ;;
    Ubuntu) install_ubuntu ;;
    Arch) install_arch ;;
    *) echo "ERROR: internal unsupported distro mode: $DISTRO_MODE" >&2; exit 1 ;;
esac

bash "$HERE/install-or-update.sh"

EXEBRIDGE_DISTRO_MODE="$DISTRO_MODE" EXEBRIDGE_DISTRO_EXPLICIT="$MODE_EXPLICIT" /usr/bin/python3 - <<'PYCFG'
import json, os
from pathlib import Path
path = Path.home() / ".local" / "share" / "exebridge" / "config.json"
try:
    cfg = json.loads(path.read_text())
    if not isinstance(cfg, dict): cfg = {}
except Exception:
    cfg = {}
mode = os.environ.get("EXEBRIDGE_DISTRO_MODE", "Fedora")
explicit = os.environ.get("EXEBRIDGE_DISTRO_EXPLICIT") == "1"
if explicit or "distro_mode" not in cfg:
    cfg["distro_mode"] = mode
cfg.setdefault("apps", {})
path.parent.mkdir(parents=True, exist_ok=True)
tmp = path.with_suffix(".tmp")
tmp.write_text(json.dumps(cfg, indent=2))
tmp.replace(path)
PYCFG

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
echo " ExeBridge ${VERSION} is ready"
echo "========================================"
echo "Distribution mode: ${DISTRO_MODE}"
echo "Existing prefixes, settings, Known Good profiles, and shortcuts were preserved."
echo "Open ExeBridge from your application menu or run: $HOME/.local/bin/exebridge"
