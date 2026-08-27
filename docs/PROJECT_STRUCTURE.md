# ExeBridge Project Structure

The repository is organized around the tested ExeBridge 0.3.0 application and its Fedora/KDE installation tooling.

```text
ExeBridge/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── workflows/
│   │   └── ci.yml
│   └── pull_request_template.md
├── assets/
│   └── README.md
├── docs/
│   ├── releases/
│   │   └── 0.3.0-manifest.json
│   └── PROJECT_STRUCTURE.md
├── src/
│   ├── source/
│   │   ├── README.md
│   │   └── exebridge.py.gz.b64.part-00 ... part-03
│   └── README.md
├── tests/
│   └── README.md
├── assemble-source.sh
├── bootstrap_umu.sh
├── install.sh
├── update.sh
├── uninstall.sh
├── exebridge.svg
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
├── LICENSE
├── README.md
└── .gitignore
```

## Application source

The exact tested 0.3.0 `exebridge.py` is compressed and split into Base64 text shards under `src/source/`. This is a transport representation used to preserve the original source bytes through the GitHub text connector.

`assemble-source.sh` concatenates, decodes, decompresses, and SHA-256 verifies those shards before producing `exebridge.py`. The expected hash is:

```text
1ea9474b55f5c569caa62bf3b3e4294a7cc2d82d824f6885fcdf782a62c0c26a
```

`install.sh` and `update.sh` perform this reconstruction automatically when a root-level `exebridge.py` is not present.

## Installation path

The installed user-local application lives primarily under:

```text
~/.local/share/exebridge/
```

with its launcher at:

```text
~/.local/bin/exebridge
```

and KDE desktop integration under the user's local applications/icons directories.

## CI

`.github/workflows/ci.yml` verifies that the source shards reconstruct to the expected SHA-256, compile with Python, and that the shell scripts pass syntax validation.

## Release provenance

`docs/releases/0.3.0-manifest.json` preserves the manifest from the original 0.3.0 local release package. The current GitHub installer scripts differ from the original packaged scripts where necessary to support repository-based source reconstruction; the application source itself is preserved byte-for-byte.
