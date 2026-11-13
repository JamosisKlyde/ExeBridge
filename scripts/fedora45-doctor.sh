#!/usr/bin/env bash
# Read-only Linux host diagnostics for ExeBridge; no prefix changes.
set -uo pipefail
fail=0
warn=0
report() { printf '%-9s %s\n' "$1" "$2"; }
ok() { report OK "$1"; }
warning() { report WARNING "$1"; warn=$((warn + 1)); }
error() { report ERROR "$1"; fail=$((fail + 1)); }
id=unknown; ver=unknown
if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  id="${ID:-unknown}"; ver="${VERSION_ID:-unknown}"
fi
report HOST "Linux distribution: $id $ver; architecture: $(uname -m)"
if [[ "$id" == "fedora" ]]; then
  if [[ "$ver" == "45" ]]; then ok "Fedora 45 detected"; else warning "Fedora $ver: Fedora 45 is the targeted validation platform"; fi
else
  warning "This report targets Fedora 45; other supported distros use their own packages"
fi
python_bin=/usr/bin/python3
if [[ -x "$python_bin" ]]; then
  report INFO "Python: $("$python_bin" --version 2>&1)"
  if "$python_bin" -c 'from PyQt6.QtWidgets import QApplication; from PyQt6.QtCore import QT_VERSION_STR, PYQT_VERSION_STR; print("Qt", QT_VERSION_STR, "PyQt", PYQT_VERSION_STR)' 2>/dev/null; then
    ok "System Python imports PyQt6"
  else
    error "PyQt6 missing/broken for /usr/bin/python3 (Fedora: sudo dnf install python3-pyqt6)"
  fi
else error "/usr/bin/python3 not found"; fi
for cmd in wine winetricks; do
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd at $(command -v "$cmd")"
  else warning "$cmd not installed (Wine runner may be unavailable)"; fi
done
if [[ -x "$HOME/.local/bin/umu-run" ]]; then
  ok "ExeBridge local UMU executable present"
elif command -v umu-run >/dev/null 2>&1; then
  ok "System UMU executable present"
else
  warning "UMU not installed; Proton/UMU launch mode will need a working UMU backend"
fi
for cmd in curl tar gzip unzip; do
  if command -v "$cmd" >/dev/null 2>&1; then ok "$cmd available"; else error "$cmd missing"; fi
done
if [[ "$(uname -m)" == "x86_64" && "$id" == "fedora" ]] && command -v rpm >/dev/null 2>&1; then
  for pkg in mesa-vulkan-drivers.i686 mesa-dri-drivers.i686 vulkan-loader.i686; do
    if rpm -q "$pkg" >/dev/null 2>&1; then ok "$pkg installed"; else warning "$pkg missing (may affect 32-bit Windows games)"; fi
  done
fi
app="$HOME/.local/share/exebridge/app/exebridge.py"
if [[ -f "$app" ]]; then
  if "$python_bin" -c 'import ast, pathlib, sys; ast.parse(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))' "$app"; then ok "Installed ExeBridge Python syntax parses"; else error "Installed ExeBridge Python syntax is invalid"; fi
else warning "ExeBridge application has not been installed in the usual user-local location"; fi
if [[ -n "${XDG_SESSION_TYPE:-}" ]]; then report INFO "Desktop session: $XDG_SESSION_TYPE"; fi
report RESULT "$fail error(s), $warn warning(s)"
(( fail == 0 ))
