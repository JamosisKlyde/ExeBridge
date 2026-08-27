# ExeBridge Project Structure

The repository is organized around ExeBridge 0.4.0 and its Fedora/Ubuntu/Arch installation tooling.

```text
ExeBridge/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── workflows/
│   │   ├── ci.yml
│   │   └── release-packages.yml
│   └── pull_request_template.md
├── assets/
├── docs/
│   ├── releases/
│   │   └── 0.3.0-manifest.json
│   └── PROJECT_STRUCTURE.md
├── scripts/
│   ├── build-release.sh
│   └── patch-0.4.0.py
├── src/
│   ├── source/
│   │   ├── README.md
│   │   └── exebridge.py.gz.b64.part-*
│   └── README.md
├── tests/
│   ├── README.md
│   └── test_multidistro_source.py
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

## Canonical application source

The previously verified ExeBridge 0.3.0 source shards remain the immutable base. `assemble-source.sh` verifies that base, applies the deterministic `scripts/patch-0.4.0.py` update, and then verifies the final 0.4.0 source before installing or packaging it.

Verified hashes:

```text
0.3.0 base:  1ea9474b55f5c569caa62bf3b3e4294a7cc2d82d824f6885fcdf782a62c0c26a
0.4.0 final: 3aed3ff04b6f43ae79757d0ca88c7a058550566be8caf5ccbfe6ca8f49cdfeae
```

This makes the 0.4.0 change reviewable as a discrete multi-distro patch while preserving the exact tested 0.3.0 source provenance.

## Distribution layer

ExeBridge 0.4.0 supports three distribution modes:

- **Fedora** — default/fallback, using `dnf` and RPM package checks.
- **Ubuntu** — using `apt-get`/dpkg and i386 multiarch support.
- **Arch** — using `pacman`, `multilib`, and `lib32` runtime packages.

The GUI stores the selected mode in `~/.local/share/exebridge/config.json`. Distro selection changes package/runtime diagnostics; normal Proton/UMU launching and application prefixes remain portable user-local behavior.

## Installation path

The installed user-local application lives primarily under:

```text
~/.local/share/exebridge/
```

with its launcher at:

```text
~/.local/bin/exebridge
```

and desktop integration under the user's local applications/icons directories.

## CI

`.github/workflows/ci.yml` verifies:

- 0.3.0 base-source integrity
- final 0.4.0 SHA-256
- Python compilation
- multi-distro AST/source invariants
- shell-script syntax

## Release packaging

`scripts/build-release.sh` reconstructs the verified source, stages the installer files, creates a root `manifest.json`, generates per-file checksums, and builds ZIP/TAR.GZ release assets plus an external SHA-256 file.

The root manifest keeps GitHub-built release archives compatible with ExeBridge's verified local update mechanism.
