#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PART_DIR="$HERE/src/source"
EXPECTED_APP_SHA256="129ecf05ddd13c7414b0a9a51c739702a96c691e403db963844837dcd8cef8dd"
EXPECTED_UPDATER_SHA256="64932bb59413e59b4cf9a4db7b5bde420cd9d4a692f7272934ae4558c07b360c"
APP_OUTPUT="${1:-$HERE/exebridge.py}"
UPDATER_OUTPUT="${2:-$(dirname -- "$APP_OUTPUT")/updater.py}"
TMP_APP="$(mktemp)"
TMP_UPDATER="$(mktemp)"
trap 'rm -f "$TMP_APP" "$TMP_UPDATER"' EXIT
app_parts=("$PART_DIR"/exebridge.py.gz.b64.part-*)
updater_parts=("$PART_DIR"/updater.py.gz.b64.part-*)
[[ -e "${app_parts[0]}" ]] || { echo "ERROR: ExeBridge source shards not found." >&2; exit 1; }
[[ -e "${updater_parts[0]}" ]] || { echo "ERROR: ExeBridge updater shards not found." >&2; exit 1; }
cat "${app_parts[@]}" | base64 --decode | gzip -dc > "$TMP_APP"
cat "${updater_parts[@]}" | base64 --decode | gzip -dc > "$TMP_UPDATER"
app_actual="$(sha256sum "$TMP_APP" | awk '{print $1}')"
updater_actual="$(sha256sum "$TMP_UPDATER" | awk '{print $1}')"
[[ "$app_actual" == "$EXPECTED_APP_SHA256" ]] || { echo "ERROR: main source SHA-256 mismatch." >&2; echo "Expected: $EXPECTED_APP_SHA256" >&2; echo "Actual:   $app_actual" >&2; exit 1; }
[[ "$updater_actual" == "$EXPECTED_UPDATER_SHA256" ]] || { echo "ERROR: updater source SHA-256 mismatch." >&2; echo "Expected: $EXPECTED_UPDATER_SHA256" >&2; echo "Actual:   $updater_actual" >&2; exit 1; }
mkdir -p "$(dirname -- "$APP_OUTPUT")" "$(dirname -- "$UPDATER_OUTPUT")"
install -m 0755 "$TMP_APP" "$APP_OUTPUT"
install -m 0755 "$TMP_UPDATER" "$UPDATER_OUTPUT"
echo "Reconstructed ExeBridge 0.5.1 sources."
echo "Main SHA-256:    $app_actual"
echo "Updater SHA-256: $updater_actual"
