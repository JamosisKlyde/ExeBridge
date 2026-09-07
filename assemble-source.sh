#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PART_DIR="$HERE/src/source"
EXPECTED_APP_SHA256="cb4139e71d3beec9ae79d26516082124c681da7699e43e25ee821a51f8ca415a"
EXPECTED_UPDATER_SHA256="3ac90db850b164436ee621e503819e3fe0a3c694be54fa1167b6b19837f7de7b"
EXPECTED_WEBVIEW2_SHA256="3cebf6d05ea76e31ebeeab34973baeff227bd28470c05797491f9f3f93e25327"
APP_OUTPUT="${1:-$HERE/exebridge.py}"
UPDATER_OUTPUT="${2:-$(dirname -- "$APP_OUTPUT")/updater.py}"
WEBVIEW2_OUTPUT="${3:-$(dirname -- "$APP_OUTPUT")/webview2_helper.py}"
TMP_APP="$(mktemp)"
TMP_UPDATER="$(mktemp)"
TMP_WEBVIEW2="$(mktemp)"
trap 'rm -f "$TMP_APP" "$TMP_UPDATER" "$TMP_WEBVIEW2"' EXIT
app_parts=("$PART_DIR"/exebridge.py.gz.b64.part-*)
updater_parts=("$PART_DIR"/updater.py.gz.b64.part-*)
webview2_parts=("$PART_DIR"/webview2_helper.py.gz.b64.part-*)
[[ -e "${app_parts[0]}" ]] || { echo "ERROR: ExeBridge source shards not found." >&2; exit 1; }
[[ -e "${updater_parts[0]}" ]] || { echo "ERROR: ExeBridge updater shards not found." >&2; exit 1; }
[[ -e "${webview2_parts[0]}" ]] || { echo "ERROR: WebView2 helper source shards not found." >&2; exit 1; }
cat "${app_parts[@]}" | base64 --decode | gzip -dc > "$TMP_APP"
cat "${updater_parts[@]}" | base64 --decode | gzip -dc > "$TMP_UPDATER"
cat "${webview2_parts[@]}" | base64 --decode | gzip -dc > "$TMP_WEBVIEW2"
app_actual="$(sha256sum "$TMP_APP" | awk '{print $1}')"
updater_actual="$(sha256sum "$TMP_UPDATER" | awk '{print $1}')"
webview2_actual="$(sha256sum "$TMP_WEBVIEW2" | awk '{print $1}')"
[[ "$app_actual" == "$EXPECTED_APP_SHA256" ]] || { echo "ERROR: main source SHA-256 mismatch." >&2; echo "Expected: $EXPECTED_APP_SHA256" >&2; echo "Actual:   $app_actual" >&2; exit 1; }
[[ "$updater_actual" == "$EXPECTED_UPDATER_SHA256" ]] || { echo "ERROR: updater source SHA-256 mismatch." >&2; echo "Expected: $EXPECTED_UPDATER_SHA256" >&2; echo "Actual:   $updater_actual" >&2; exit 1; }
[[ "$webview2_actual" == "$EXPECTED_WEBVIEW2_SHA256" ]] || { echo "ERROR: WebView2 helper source SHA-256 mismatch." >&2; echo "Expected: $EXPECTED_WEBVIEW2_SHA256" >&2; echo "Actual:   $webview2_actual" >&2; exit 1; }
mkdir -p "$(dirname -- "$APP_OUTPUT")" "$(dirname -- "$UPDATER_OUTPUT")" "$(dirname -- "$WEBVIEW2_OUTPUT")"
install -m 0755 "$TMP_APP" "$APP_OUTPUT"
install -m 0755 "$TMP_UPDATER" "$UPDATER_OUTPUT"
install -m 0755 "$TMP_WEBVIEW2" "$WEBVIEW2_OUTPUT"
echo "Reconstructed ExeBridge 0.6.0 sources."
echo "Main SHA-256:     $app_actual"
echo "Updater SHA-256:  $updater_actual"
echo "WebView2 SHA-256: $webview2_actual"
