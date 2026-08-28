#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APP="$HOME/.local/share/exebridge"
APPDIR="$APP/app"
BIN="$HOME/.local/bin"
DESKTOP="$HOME/.local/share/applications"
ICONDIR="$HOME/.local/share/icons/hicolor/scalable/apps"
VERSIONS="$APP/versions"
VERSION="0.5.1"

if ! /usr/bin/python3 - <<'PY' >/dev/null 2>&1
from PyQt6.QtWidgets import QApplication
PY
then
  echo "PyQt6 is required."
  echo "Fedora: sudo dnf install python3-pyqt6"
  echo "Ubuntu: sudo apt install python3-pyqt6"
  echo "Arch: sudo pacman -S python-pyqt6"
  exit 1
fi

mkdir -p "$APP" "$BIN" "$DESKTOP" "$ICONDIR" "$VERSIONS" "$APP/prefixes" "$APP/logs" "$APP/legacy-links"

old_version="unknown"
if [[ -f "$APPDIR/version.json" ]]; then
  old_version="$(/usr/bin/python3 - "$APPDIR/version.json" <<'PY' 2>/dev/null || true
import json, sys
try:
    print(json.load(open(sys.argv[1])).get('version','unknown'))
except Exception:
    pass
PY
)"
fi
if [[ -z "$old_version" || "$old_version" == "unknown" ]] && [[ -f "$APPDIR/exebridge.py" ]]; then
  old_version="$(/usr/bin/python3 - "$APPDIR/exebridge.py" <<'PY' 2>/dev/null || true
import re, sys
try:
    text = open(sys.argv[1], encoding='utf-8').read(4096)
    m = re.search(r'^VERSION\s*=\s*["\']([^"\']+)["\']', text, re.M)
    if m:
        print(m.group(1))
except Exception:
    pass
PY
)"
fi
old_version="${old_version:-unknown}"

if [[ -d "$APPDIR" ]]; then
  stamp="$(date +%Y%m%d-%H%M%S)"
  safe_old="$(printf '%s' "$old_version" | tr -c 'A-Za-z0-9._-' '-')"
  backup="$VERSIONS/${safe_old}-${stamp}"
  cp -a "$APPDIR" "$backup"
  echo "Backed up ExeBridge $old_version app files to: $backup"
fi

rm -rf "$APPDIR.new"
mkdir -p "$APPDIR.new"

if [[ -f "$HERE/app/exebridge.py" && -f "$HERE/app/updater.py" && -f "$HERE/app/exebridge.svg" ]]; then
  cp -a "$HERE/app/." "$APPDIR.new/"
elif [[ -x "$HERE/assemble-source.sh" && -f "$HERE/exebridge.svg" ]]; then
  echo "Repository checkout detected; reconstructing verified application sources…"
  bash "$HERE/assemble-source.sh" "$APPDIR.new/exebridge.py" "$APPDIR.new/updater.py"
  install -m 0644 "$HERE/exebridge.svg" "$APPDIR.new/exebridge.svg"
else
  echo "ERROR: ExeBridge application payload is missing." >&2
  exit 1
fi
printf '{\n  "app_id": "exebridge",\n  "version": "%s"\n}\n' "$VERSION" > "$APPDIR.new/version.json"
rm -rf "$APPDIR"
mv "$APPDIR.new" "$APPDIR"
chmod 0755 "$APPDIR/exebridge.py" "$APPDIR/updater.py"

# Preserve the stable 0.4 configuration, then adopt the settings/current prefix
# from the tested 0.5 preview when it exists.
/usr/bin/python3 - <<'PY'
import json
import shutil
from pathlib import Path

home = Path.home()
stable = home / '.local/share/exebridge'
preview = home / '.local/share/exebridge-preview'
stable_cfg_path = stable / 'config.json'
preview_cfg_path = preview / 'config.json'

def load(path):
    try:
        obj = json.loads(path.read_text())
        return obj if isinstance(obj, dict) else {}
    except Exception:
        return {}

stable_cfg = load(stable_cfg_path)
preview_cfg = load(preview_cfg_path)
if preview_cfg:
    for key in ('exe','mode','jp','ascii_bridge','wined3d','runner'):
        if key in preview_cfg:
            stable_cfg[key] = preview_cfg[key]

    ptext = preview_cfg.get('prefix')
    if ptext:
        src = Path(ptext).expanduser()
        preview_root = preview / 'prefixes'
        try:
            src.resolve().relative_to(preview_root.resolve())
            if src.exists():
                dest = stable / 'prefixes' / src.name
                if not dest.exists():
                    shutil.copytree(src, dest, symlinks=True)
                stable_cfg['prefix'] = str(dest)
        except Exception:
            # If the preview used a user-selected external prefix, preserve the
            # path rather than copying or deleting anything.
            stable_cfg['prefix'] = str(src)

stable_cfg_path.parent.mkdir(parents=True, exist_ok=True)
tmp = stable_cfg_path.with_suffix('.tmp')
tmp.write_text(json.dumps(stable_cfg, indent=2))
tmp.replace(stable_cfg_path)
PY

install -m 0644 "$APPDIR/exebridge.svg" "$ICONDIR/exebridge.svg"

cat > "$BIN/exebridge" <<'EOF2'
#!/usr/bin/env bash
exec /usr/bin/python3 "$HOME/.local/share/exebridge/app/exebridge.py" "$@"
EOF2
chmod 0755 "$BIN/exebridge"

cat > "$DESKTOP/exebridge.desktop" <<EOF2
[Desktop Entry]
Type=Application
Name=ExeBridge
Comment=Run Windows applications with Proton, UMU, and Wine
Exec=$BIN/exebridge %f
Icon=exebridge
Terminal=false
Categories=Utility;Game;
MimeType=application/x-ms-dos-executable;application/x-msdownload;application/vnd.microsoft.portable-executable;
StartupNotify=true
EOF2
chmod 0644 "$DESKTOP/exebridge.desktop"

if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "$DESKTOP/exebridge.desktop" || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP" >/dev/null 2>&1 || true
fi
if command -v xdg-mime >/dev/null 2>&1; then
  for mime in application/x-ms-dos-executable application/x-msdownload application/vnd.microsoft.portable-executable; do
    xdg-mime default exebridge.desktop "$mime" 2>/dev/null || true
  done
fi

echo
echo "========================================"
echo " ExeBridge 0.5.1 installed"
echo "========================================"
echo "Your existing stable prefixes/config were preserved."
if [[ -d "$HOME/.local/share/exebridge-preview" ]]; then
  echo "Your tested 0.5 preview settings were migrated where safe."
  echo "The preview install was left in place as a fallback."
fi
echo "Open ExeBridge from your application menu or run: $HOME/.local/bin/exebridge"
echo "Future stable update ZIPs can be installed from the Updates… button."
