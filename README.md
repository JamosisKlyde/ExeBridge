# ExeBridge

> Run Windows `.exe` and `.msi` applications on Fedora, Ubuntu, and Arch Linux through Proton/UMU without hand-managing Wine prefixes.

**Development version: 0.4.0**  
**Current distribution modes: Fedora (default), Ubuntu, Arch**

ExeBridge is a PyQt6 desktop front-end that gives Windows programs isolated compatibility environments, per-app launch settings, logs, desktop integration, repair tools, snapshots, and multiple Proton/UMU runner options.

## Distribution modes

ExeBridge 0.4.0 adds three first-class Linux modes:

| Mode | Package system | 32-bit graphics checks |
|---|---|---|
| **Fedora — default** | `dnf` / RPM | `.i686` Mesa + Vulkan packages |
| **Ubuntu** | `apt-get` / dpkg | `:i386` Mesa + Vulkan packages |
| **Arch** | `pacman` | `lib32-*` Mesa + Vulkan packages |

The installer reads `/etc/os-release` and selects a recognized Fedora, Ubuntu, or Arch family automatically. **Fedora is the fallback/default** if detection is inconclusive. You can switch the active mode at any time from ExeBridge's **Distribution mode** selector.

You can also force a mode during installation:

```bash
./install.sh --distro fedora
./install.sh --distro ubuntu
./install.sh --distro arch
```

or at application startup:

```bash
exebridge --distro Fedora
exebridge --distro Ubuntu
exebridge --distro Arch
```

## Highlights

- Launch `.exe` and `.msi` files from ExeBridge or your desktop file manager
- Fedora, Ubuntu, and Arch distro-aware setup
- Isolated Proton/Wine prefix per application, with managed-prefix reuse
- **App Library** with saved programs and quick launch
- **Standard**, **Gaming**, **Legacy / OpenGL**, **Managed / .NET**, and **Debug** launch profiles
- **Runner Manager** for rolling UMU/GE and installed `compatibilitytools.d` runners
- Per-app WineD3D, GameMode, Esync, Fsync, Protonfixes, runner, and isolation controls
- **Fix & Retry** compatibility recipes with executable-fingerprint memory
- Prefix snapshots and restore
- Post-installer executable discovery for MSI/setup-style installers
- Built-in PE icon extraction and Windows-icon desktop shortcuts
- Optional **Restricted filesystem mode** using Bubblewrap, with optional network isolation
- User-local UMU bootstrap/repair
- No `sudo` or `pkexec` during ordinary application launches

## Install

Clone the repository:

```bash
git clone https://github.com/JamosisKlyde/ExeBridge.git
cd ExeBridge
chmod +x install.sh
./install.sh
```

Or download the repository/release ZIP, extract it, open a terminal in that directory, and run:

```bash
chmod +x install.sh
./install.sh
```

The installer uses administrator authentication only to install system dependencies. ExeBridge itself, its settings, prefixes, and ordinary Windows-app launches live in the user's account.

### Fedora

Uses `dnf` and installs the PyQt6, GameMode, Winetricks, desktop integration, Bubblewrap, and 32-bit Mesa/Vulkan packages used by ExeBridge.

### Ubuntu

Uses `apt-get`. On x86-64, the installer enables the `i386` architecture when necessary and installs the common 32-bit Mesa/Vulkan runtime packages.

### Arch

Uses `pacman`. On x86-64, ExeBridge checks for the `multilib` repository before installing `lib32` graphics support. If a common native Vulkan driver is installed, the installer also attempts to install its corresponding 32-bit package.

> Proprietary or unusual GPU configurations may still require vendor-specific 32-bit graphics libraries. ExeBridge reports the generic runtime status but does not replace your distro's GPU-driver documentation.

## Source integrity

The repository reconstructs the canonical ExeBridge 0.4.0 Python source from the previously verified 0.3.0 source shards plus the deterministic `scripts/patch-0.4.0.py` update. The final expected SHA-256 is:

```text
3aed3ff04b6f43ae79757d0ca88c7a058550566be8caf5ccbfe6ca8f49cdfeae
```

Reconstruct manually with:

```bash
bash assemble-source.sh
```

CI verifies the source checksum, Python syntax, multi-distro structure, and shell-script syntax.

## Start ExeBridge

Open **ExeBridge** from the application menu, or run:

```bash
~/.local/bin/exebridge
```

## First launch

The first Windows-program launch may take several minutes because UMU can download the Steam Linux Runtime and the selected Proton/GE-Proton build.

ExeBridge's bundled UMU bootstrap pins **UMU Launcher 1.4.4** and verifies the upstream archive before installation.

## Compatibility profiles

| Profile | Purpose |
|---|---|
| **Standard** | Default UMU/Proton configuration for most programs |
| **Gaming** | Gaming-oriented profile with GE-Proton/UMU and GameMode support |
| **Legacy / OpenGL** | Uses WineD3D (`PROTON_USE_WINED3D=1`) for programs that have trouble with Vulkan/DXVK |
| **Managed / .NET** | Applies ExeBridge's compatibility pack for common managed/.NET dependencies |
| **Debug** | Enables extra UMU/Proton logging for troubleshooting |

## Prefixes and application data

Managed prefixes live under:

```text
~/.local/share/exebridge/prefixes/
```

ExeBridge keeps logs, snapshots, extracted icons, configuration, and application state under:

```text
~/.local/share/exebridge/
```

## Restricted mode

When Bubblewrap is available, ExeBridge can run an application with a more restricted view of the Linux filesystem and can optionally isolate networking.

**This is defense-in-depth, not a security guarantee.** Proton/Wine is not a security sandbox. Only run software you trust.

## Updating from a repository checkout

After pulling a newer repository version:

```bash
bash update.sh
```

This preserves existing prefixes and ExeBridge configuration.

## Uninstall

```bash
bash uninstall.sh
```

The uninstaller intentionally preserves managed prefixes so it cannot silently delete installed Windows applications or their data.

## Known limitations

No compatibility front-end can make every Windows executable work. Kernel drivers, some anti-cheat systems, DRM, low-level hardware utilities, and software tied to unsupported Windows services may still require a Windows VM or native Windows installation.

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md).

## License

ExeBridge is released under the **MIT License**. See [`LICENSE`](LICENSE).

## Disclaimer

ExeBridge is an independent compatibility utility. Windows, Steam, Proton, Wine, UMU Launcher, Fedora, Ubuntu, Arch Linux, and other referenced projects or trademarks belong to their respective owners.
