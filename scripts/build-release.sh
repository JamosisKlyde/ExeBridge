#!/usr/bin/env bash
set -euo pipefail

VERSION_RAW="${1:-}"
OUTDIR="${2:-dist}"
ROOT="${EXEBRIDGE_SOURCE_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"

if [[ -z "$VERSION_RAW" ]]; then
    echo "Usage: $0 <version|tag> [output-directory]" >&2
    exit 2
fi

VERSION="${VERSION_RAW#v}"
NAME="ExeBridge-${VERSION}"
OUTDIR="$(mkdir -p "$OUTDIR" && cd "$OUTDIR" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
STAGE="$TMP/$NAME"
mkdir -p "$STAGE"

required=(
    assemble-source.sh
    install.sh
    update.sh
    uninstall.sh
    bootstrap_umu.sh
    exebridge.svg
    README.md
    CHANGELOG.md
    LICENSE
)

for file in "${required[@]}"; do
    if [[ ! -f "$ROOT/$file" ]]; then
        echo "ERROR: required release file missing: $file" >&2
        exit 1
    fi
done

# Reconstruct and integrity-check the canonical application source for this tag.
bash "$ROOT/assemble-source.sh" "$STAGE/exebridge.py"

install -m 0755 "$ROOT/install.sh" "$STAGE/install.sh"
install -m 0755 "$ROOT/update.sh" "$STAGE/update.sh"
install -m 0755 "$ROOT/uninstall.sh" "$STAGE/uninstall.sh"
install -m 0755 "$ROOT/bootstrap_umu.sh" "$STAGE/bootstrap_umu.sh"
install -m 0644 "$ROOT/exebridge.svg" "$STAGE/exebridge.svg"
install -m 0644 "$ROOT/README.md" "$STAGE/README.md"
install -m 0644 "$ROOT/CHANGELOG.md" "$STAGE/CHANGELOG.md"
install -m 0644 "$ROOT/LICENSE" "$STAGE/LICENSE"

if [[ -f "$ROOT/SECURITY.md" ]]; then
    install -m 0644 "$ROOT/SECURITY.md" "$STAGE/SECURITY.md"
fi
if [[ -f "$ROOT/CODE_OF_CONDUCT.md" ]]; then
    install -m 0644 "$ROOT/CODE_OF_CONDUCT.md" "$STAGE/CODE_OF_CONDUCT.md"
fi

# Include release provenance when present.
if [[ -f "$ROOT/docs/releases/${VERSION}-manifest.json" ]]; then
    mkdir -p "$STAGE/docs/releases"
    install -m 0644 "$ROOT/docs/releases/${VERSION}-manifest.json" "$STAGE/docs/releases/${VERSION}-manifest.json"
fi

# GitHub-built release packages need a root manifest for ExeBridge's verified updater.
STAGE="$STAGE" VERSION="$VERSION" python3 - <<'PY'
import hashlib
import json
import os
from pathlib import Path

stage = Path(os.environ["STAGE"])
files = {}
for path in sorted(p for p in stage.rglob("*") if p.is_file()):
    rel = path.relative_to(stage).as_posix()
    if rel in {"manifest.json", "SHA256SUMS"}:
        continue
    files[rel] = hashlib.sha256(path.read_bytes()).hexdigest()

manifest = {
    "name": "ExeBridge",
    "version": os.environ["VERSION"],
    "release_channel": "github-release",
    "files": files,
}
(stage / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY

# Record the hashes of every file actually shipped in this package.
(
    cd "$STAGE"
    find . -type f ! -name SHA256SUMS -print0 \
      | sort -z \
      | xargs -0 sha256sum > SHA256SUMS
)

rm -f "$OUTDIR/$NAME.zip" "$OUTDIR/$NAME.tar.gz" "$OUTDIR/$NAME-SHA256.txt"

(
    cd "$TMP"
    tar -czf "$OUTDIR/$NAME.tar.gz" "$NAME"
    zip -qr "$OUTDIR/$NAME.zip" "$NAME"
)

(
    cd "$OUTDIR"
    sha256sum "$NAME.zip" "$NAME.tar.gz" > "$NAME-SHA256.txt"
)

echo "Built release assets:"
ls -lh "$OUTDIR/$NAME.zip" "$OUTDIR/$NAME.tar.gz" "$OUTDIR/$NAME-SHA256.txt"
echo
cat "$OUTDIR/$NAME-SHA256.txt"
