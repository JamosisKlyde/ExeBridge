#!/usr/bin/env bash
set -euo pipefail
VERSION_RAW="${1:-}"
OUTDIR="${2:-dist}"
ROOT="${EXEBRIDGE_SOURCE_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
[[ -n "$VERSION_RAW" ]] || { echo "Usage: $0 <version|tag> [output-directory]" >&2; exit 2; }
VERSION="${VERSION_RAW#v}"
NAME="ExeBridge-${VERSION}"
OUTDIR="$(mkdir -p "$OUTDIR" && cd "$OUTDIR" && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
STAGE="$TMP/$NAME"; mkdir -p "$STAGE/app"
required=(assemble-source.sh exebridge.svg install-or-update.sh install.sh update.sh uninstall.sh bootstrap_umu.sh README.md CHANGELOG.md LICENSE)
for file in "${required[@]}"; do [[ -f "$ROOT/$file" ]] || { echo "ERROR: required release file missing: $file" >&2; exit 1; }; done
bash "$ROOT/assemble-source.sh" "$STAGE/app/exebridge.py" "$STAGE/app/updater.py"
python3 - "$STAGE/app/exebridge.py" "$VERSION" <<'PY'
import re, sys
text=open(sys.argv[1], encoding='utf-8').read(4096)
m=re.search(r'^VERSION\s*=\s*["\']([^"\']+)["\']', text, re.M)
if not m or m.group(1) != sys.argv[2]: raise SystemExit(f"ERROR: app VERSION is {m.group(1) if m else 'missing'}, release version is {sys.argv[2]}")
PY
install -m 0644 "$ROOT/exebridge.svg" "$STAGE/app/exebridge.svg"
install -m 0755 "$ROOT/install-or-update.sh" "$STAGE/install-or-update.sh"
install -m 0755 "$ROOT/install.sh" "$STAGE/install.sh"
install -m 0755 "$ROOT/update.sh" "$STAGE/update.sh"
install -m 0755 "$ROOT/uninstall.sh" "$STAGE/uninstall.sh"
install -m 0755 "$ROOT/bootstrap_umu.sh" "$STAGE/bootstrap_umu.sh"
install -m 0755 "$ROOT/assemble-source.sh" "$STAGE/assemble-source.sh"
mkdir -p "$STAGE/src/source"
cp "$ROOT/src/source/"*.gz.b64.part-* "$STAGE/src/source/"
install -m 0644 "$ROOT/README.md" "$STAGE/README.md"
install -m 0644 "$ROOT/CHANGELOG.md" "$STAGE/CHANGELOG.md"
install -m 0644 "$ROOT/LICENSE" "$STAGE/LICENSE"
[[ -f "$ROOT/SECURITY.md" ]] && install -m 0644 "$ROOT/SECURITY.md" "$STAGE/SECURITY.md"
python3 - "$STAGE" "$VERSION" <<'PY'
from pathlib import Path
import hashlib, json, sys
root=Path(sys.argv[1]); version=sys.argv[2]
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
manifest={"app_id":"exebridge","version":version,"channel":"stable","entrypoint":"app/exebridge.py","sha256":{
"app/exebridge.py":sha(root/'app/exebridge.py'),"app/updater.py":sha(root/'app/updater.py'),"app/exebridge.svg":sha(root/'app/exebridge.svg')}}
(root/'update-manifest.json').write_text(json.dumps(manifest, indent=2)+"\n", encoding='utf-8')
PY
(cd "$STAGE" && find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS)
rm -f "$OUTDIR/$NAME.zip" "$OUTDIR/$NAME.tar.gz" "$OUTDIR/$NAME-SHA256.txt"
(cd "$TMP" && tar -czf "$OUTDIR/$NAME.tar.gz" "$NAME" && zip -qr "$OUTDIR/$NAME.zip" "$NAME")
(cd "$OUTDIR" && sha256sum "$NAME.zip" "$NAME.tar.gz" > "$NAME-SHA256.txt")
echo "Built release assets:"; ls -lh "$OUTDIR/$NAME.zip" "$OUTDIR/$NAME.tar.gz" "$OUTDIR/$NAME-SHA256.txt"; cat "$OUTDIR/$NAME-SHA256.txt"
