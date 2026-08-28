# ExeBridge Project Structure

The repository is organized around ExeBridge 0.5.1.

```text
ExeBridge/
├── .github/workflows/
│   ├── ci.yml
│   └── release-packages.yml
├── docs/
├── scripts/
│   └── build-release.sh
├── src/source/
│   ├── README.md
│   ├── exebridge.py.gz.b64.part-*
│   └── updater.py.gz.b64.part-*
├── assemble-source.sh
├── bootstrap_umu.sh
├── install-or-update.sh
├── install.sh
├── update.sh
├── uninstall.sh
├── exebridge.svg
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Canonical source

`assemble-source.sh` reconstructs and SHA-256 verifies both the main PyQt6 application and the updater from the text shards under `src/source/`.

Expected hashes for 0.5.1:

```text
exebridge.py  129ecf05ddd13c7414b0a9a51c739702a96c691e403db963844837dcd8cef8dd
updater.py    64932bb59413e59b4cf9a4db7b5bde420cd9d4a692f7272934ae4558c07b360c
```

## Installation

`install.sh` handles Fedora/Ubuntu/Arch system dependencies and then calls `install-or-update.sh`. The latter performs the user-local app replacement, version backup, launcher installation, and safe configuration migration. `update.sh` is the no-system-dependency repository update path.

Installed application files live under `~/.local/share/exebridge/app/`, while prefixes, Known Good data, logs, and version backups remain outside that replaceable app directory.

## Release packaging

`scripts/build-release.sh` reconstructs the verified Python sources into an updater-compatible `app/` payload, generates `update-manifest.json`, and creates `.zip`, `.tar.gz`, and SHA-256 assets. The release workflow publishes those assets for the prepared version tag.

## CI

CI reconstructs and compile-checks both Python sources, checks the restored Known Good/desktop-shortcut functionality, syntax-checks shell scripts, builds the release ZIP, and verifies the update manifest against the exact packaged bytes.
