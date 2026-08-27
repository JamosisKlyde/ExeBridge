# ExeBridge Project Structure

The repository is organized around ExeBridge 0.4.0 with Fedora, Ubuntu, and Arch Linux support.

```text
ExeBridge/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   └── workflows/
│       ├── ci.yml
│       └── release-packages.yml
├── assets/
├── docs/
│   ├── releases/
│   ├── DISTRIBUTION_SUPPORT.md
│   └── PROJECT_STRUCTURE.md
├── scripts/
│   └── build-release.sh
├── src/
│   └── source/
│       ├── README.md
│       └── exebridge.py.gz.b64.part-*
├── tests/
├── assemble-source.sh
├── bootstrap_umu.sh
├── install.sh
├── update.sh
├── uninstall.sh
├── exebridge.svg
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── SECURITY.md
├── LICENSE
├── README.md
└── .gitignore
```

## Application source

The canonical 0.4.0 `exebridge.py` is compressed and split into Base64 text shards under `src/source/`.

`assemble-source.sh` concatenates, decodes, decompresses, and SHA-256 verifies those shards before producing `exebridge.py`.

Expected source SHA-256:

```text
003140c03e5a2aa4203c42547c18a3a62545b6ee7560606d27cb932d8b88a389
```

`install.sh` and `update.sh` reconstruct the source automatically when a root-level `exebridge.py` is not present.

## Distribution layer

The application supports `Fedora`, `Ubuntu`, and `Arch` distro modes. Fedora is the default/fallback. `install.sh` selects the appropriate package manager and writes the initial distro mode without overwriting existing ExeBridge application settings.

See `docs/DISTRIBUTION_SUPPORT.md` for the dependency matrix.

## Installation path

The installed user-local application lives primarily under:

```text
~/.local/share/exebridge/
```

with its launcher at:

```text
~/.local/bin/exebridge
```

Desktop integration is installed beneath the user's local applications and icon directories.

## CI

`.github/workflows/ci.yml` verifies source reconstruction, the source SHA-256, Python compilation, shell syntax, and presence of all three distribution modes.

## Releases

`scripts/build-release.sh` creates `.zip`, `.tar.gz`, and SHA-256 release assets from an exact version tag. `.github/workflows/release-packages.yml` attaches those assets to tagged GitHub releases.
