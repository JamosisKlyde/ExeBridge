#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PART_DIR="$HERE/src/source"
BASE_SHA256="1ea9474b55f5c569caa62bf3b3e4294a7cc2d82d824f6885fcdf782a62c0c26a"
EXPECTED_SHA256="3aed3ff04b6f43ae79757d0ca88c7a058550566be8caf5ccbfe6ca8f49cdfeae"
OUTPUT="${1:-$HERE/exebridge.py}"
TMP_BASE="$(mktemp)"
TMP_PATCHED="$(mktemp)"
trap 'rm -f "$TMP_BASE" "$TMP_PATCHED"' EXIT

parts=("$PART_DIR"/exebridge.py.gz.b64.part-*)
if [[ ! -e "${parts[0]}" ]]; then
    echo "ERROR: ExeBridge source shards were not found in: $PART_DIR" >&2
    exit 1
fi

cat "${parts[@]}" | base64 --decode | gzip -dc > "$TMP_BASE"
base_actual="$(sha256sum "$TMP_BASE" | awk '{print $1}')"
if [[ "$base_actual" != "$BASE_SHA256" ]]; then
    echo "ERROR: ExeBridge 0.3.0 base source failed SHA-256 verification." >&2
    echo "Expected: $BASE_SHA256" >&2
    echo "Actual:   $base_actual" >&2
    exit 1
fi

python3 "$HERE/scripts/patch-0.4.0.py" "$TMP_BASE" "$TMP_PATCHED"
actual="$(sha256sum "$TMP_PATCHED" | awk '{print $1}')"
if [[ "$actual" != "$EXPECTED_SHA256" ]]; then
    echo "ERROR: Reconstructed ExeBridge 0.4.0 source failed SHA-256 verification." >&2
    echo "Expected: $EXPECTED_SHA256" >&2
    echo "Actual:   $actual" >&2
    exit 1
fi

mkdir -p "$(dirname -- "$OUTPUT")"
install -m 0755 "$TMP_PATCHED" "$OUTPUT"
echo "Reconstructed ExeBridge 0.4.0 source: $OUTPUT"
echo "SHA-256: $actual"
