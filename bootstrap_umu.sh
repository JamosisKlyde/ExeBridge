#!/usr/bin/env bash
set -euo pipefail

UMU_VERSION="1.4.4"
UMU_SHA256="eb590691841f7fad3fc3ad8fd5db4ccb87849fe7948e62b28ece7a4ee48cc851"
UMU_URL="https://github.com/Open-Wine-Components/umu-launcher/releases/download/${UMU_VERSION}/umu-launcher-${UMU_VERSION}-zipapp.tar"

BASE="$HOME/.local/share/exebridge"
TARGET="$BASE/umu-${UMU_VERSION}"
BIN="$HOME/.local/bin"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$BASE" "$BIN"

echo "ExeBridge UMU bootstrap"
echo "Downloading UMU Launcher ${UMU_VERSION} from the upstream Open-Wine-Components release…"
curl --fail --location --progress-bar "$UMU_URL" -o "$TMP/umu.tar"

echo
echo "Verifying SHA-256…"
echo "${UMU_SHA256}  $TMP/umu.tar" | sha256sum -c -

echo "Extracting…"
mkdir "$TMP/extract"
tar -xf "$TMP/umu.tar" -C "$TMP/extract"

candidate="$(
    find "$TMP/extract" \( -type f -o -type l \) \
      \( -name 'umu-run' -o -name 'umu-run.pyz' -o -name 'umu.pyz' \) \
      -print -quit 2>/dev/null || true
)"

if [[ -z "$candidate" ]]; then
    candidate="$(
        find "$TMP/extract" -type f -perm /111 -print -quit 2>/dev/null || true
    )"
fi

if [[ -z "$candidate" ]]; then
    echo "ERROR: Could not locate the umu-run executable inside the verified archive." >&2
    echo "Archive contents:" >&2
    find "$TMP/extract" -maxdepth 3 -type f -print >&2
    exit 1
fi

rm -rf "$TARGET"
mkdir -p "$TARGET"
cp -a "$TMP/extract"/. "$TARGET"/

rel="${candidate#"$TMP/extract"/}"
installed_candidate="$TARGET/$rel"
chmod +x "$installed_candidate"
ln -sfn "$installed_candidate" "$BIN/umu-run"

echo
echo "Installed UMU backend:"
echo "  $BIN/umu-run -> $installed_candidate"
echo
"$BIN/umu-run" --version 2>/dev/null || true
echo
echo "UMU is ready. Proton and the Steam Runtime are downloaded automatically when needed."
