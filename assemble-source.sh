#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PART_DIR="$HERE/src/source"
EXPECTED_SHA256="003140c03e5a2aa4203c42547c18a3a62545b6ee7560606d27cb932d8b88a389"
OUTPUT="${1:-$HERE/exebridge.py}"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

parts=("$PART_DIR"/exebridge.py.gz.b64.part-*)
if [[ ! -e "${parts[0]}" ]]; then
    echo "ERROR: ExeBridge source shards were not found in: $PART_DIR" >&2
    exit 1
fi

cat "${parts[@]}" | base64 --decode | gzip -dc > "$TMP"
actual="$(sha256sum "$TMP" | awk '{print $1}')"
if [[ "$actual" != "$EXPECTED_SHA256" ]]; then
    echo "ERROR: Reconstructed ExeBridge source failed SHA-256 verification." >&2
    echo "Expected: $EXPECTED_SHA256" >&2
    echo "Actual:   $actual" >&2
    exit 1
fi

mkdir -p "$(dirname -- "$OUTPUT")"
install -m 0755 "$TMP" "$OUTPUT"
echo "Reconstructed ExeBridge 0.4.0 source: $OUTPUT"
echo "SHA-256: $actual"
