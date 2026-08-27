#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APPDATA="$HOME/.local/share/exebridge"
APPDIR="$APPDATA/app"
BINDIR="$HOME/.local/bin"
APPS="$HOME/.local/share/applications"
ICONDIR="$HOME/.local/share/icons/hicolor/scalable/apps"

TMPDIR=""
cleanup() {
    [[ -n "$TMPDIR" ]] && rm -rf "$TMPDIR"
}
trap cleanup EXIT

SOURCE="$HERE/exebridge.py"
if [[ ! -f "$SOURCE" ]]; then
    TMPDIR="$(mktemp -d)"
    SOURCE="$TMPDIR/exebridge.py"
    bash "$HERE/assemble-source.sh" "$SOURCE"
fi

mkdir -p "$APPDIR" "$BINDIR" "$APPS" "$ICONDIR" "$APPDATA/logs" "$APPDATA/prefixes" "$APPDATA/snapshots" "$APPDATA/icons"

install -m 0755 "$SOURCE" "$APPDIR/exebridge.py"
install -m 0755 "$HERE/bootstrap_umu.sh" "$APPDATA/bootstrap_umu.sh"
install -m 0644 "$HERE/exebridge.svg" "$APPDIR/exebridge.svg"
install -m 0644 "$HERE/exebridge.svg" "$ICONDIR/exebridge.svg"

cat > "$BINDIR/exebridge" <<'LAUNCHER'
#!/usr/bin/env bash
exec /usr/bin/python3 "$HOME/.local/share/exebridge/app/exebridge.py" "$@"
LAUNCHER
chmod 0755 "$BINDIR/exebridge"

cat > "$APPS/exebridge.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=ExeBridge
Comment=Launch Windows executables with Proton/UMU
Exec=$BINDIR/exebridge %f
Icon=exebridge
Terminal=false
Categories=Utility;Game;
MimeType=application/x-ms-dos-executable;application/x-msdownload;application/vnd.microsoft.portable-executable;
StartupNotify=true
DESKTOP
chmod 0644 "$APPS/exebridge.desktop"

if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate "$APPS/exebridge.desktop" || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPS" || true
fi
for mime in application/x-ms-dos-executable application/x-msdownload application/vnd.microsoft.portable-executable; do
    xdg-mime default exebridge.desktop "$mime" 2>/dev/null || true
done

echo "ExeBridge user-local files updated successfully."
echo "Prefixes and config were preserved in: $APPDATA"
