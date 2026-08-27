# ExeBridge

> Run Windows `.exe` and `.msi` applications on Fedora KDE through Proton/UMU without hand-managing Wine prefixes.

**Current release source: 0.3.0**

ExeBridge is a PyQt6 desktop front-end that gives Windows programs isolated compatibility environments, per-app launch settings, logs, desktop integration, repair tools, snapshots, and multiple Proton/UMU runner options.

## Highlights

- Launch `.exe` and `.msi` files from ExeBridge or **Dolphin → Open With → ExeBridge**
- Isolated Proton/Wine prefix per application, with managed-prefix reuse
- **App Library** with saved programs, quick load/launch, and automatic registration after successful launches
- **Standard**, **Gaming**, **Legacy / OpenGL**, and **Debug** launch modes
- **Runner Manager** for rolling UMU/GE and installed `compatibilitytools.d` runners
- Per-app WineD3D, GameMode, Esync, Fsync, Protonfixes, runner, and isolation controls
- **Fix & Retry** compatibility recipes with executable-fingerprint memory
- Prefix snapshots and restore, including automatic pre-change snapshots before Winetricks changes
- Post-installer executable discovery for MSI/setup-style installers
- Built-in PE icon extraction and Windows-icon desktop shortcuts
- Optional **Restricted filesystem mode** using Bubblewrap, with optional network isolation
- User-local UMU bootstrap/repair
- No `sudo` or `pkexec` during ordinary application launches

## Install on Fedora / Fedora KDE

Clone the repository:

```bash
git clone https://github.com/JamosisKlyde/ExeBridge.git
cd ExeBridge
chmod +x install.sh
./install.sh
```

Or download the repository ZIP from GitHub, extract it, open Konsole in that directory, and run:

```bash
chmod +x install.sh
./install.sh
```

The installer requests administrator authentication only for Fedora packages such as PyQt6, GameMode, Winetricks, Bubblewrap, and graphics/runtime dependencies. ExeBridge itself is then installed into your user account.

The repository preserves the exact tested ExeBridge 0.3.0 Python source as verified compressed text shards. `install.sh` reconstructs it automatically and refuses to install it unless its SHA-256 is:

```text
1ea9474b55f5c569caa62bf3b3e4294a7cc2d82d824f6885fcdf782a62c0c26a
```

## Start ExeBridge

Open **ExeBridge** from KDE's application menu, or run:

```bash
~/.local/bin/exebridge
```

Supported Windows executable MIME types are registered with the desktop, so you can also right-click a compatible file in Dolphin and choose **Open With → ExeBridge**.

## First launch

The first Windows-program launch may take several minutes because UMU can download the Steam Linux Runtime and the selected Proton/GE-Proton build.

ExeBridge's bundled UMU bootstrap pins **UMU Launcher 1.4.4** and verifies the upstream archive before installation.

## Compatibility modes

| Mode | Purpose |
|---|---|
| **Standard** | Default UMU/Proton configuration for most programs |
| **Gaming** | Gaming-oriented profile with GE-Proton/UMU and GameMode support |
| **Legacy / OpenGL** | Uses WineD3D (`PROTON_USE_WINED3D=1`) for programs that have trouble with Vulkan/DXVK |
| **Debug** | Enables extra UMU/Proton logging for troubleshooting |

## Prefixes and application data

Managed prefixes live under:

```text
~/.local/share/exebridge/prefixes/
```

If you run an installer, ExeBridge can search the resulting prefix for installed executables. Selecting an executable that already lives inside an ExeBridge-managed prefix reuses the same prefix rather than creating a second one.

ExeBridge also keeps user-local logs, snapshots, extracted icons, configuration, and application state under:

```text
~/.local/share/exebridge/
```

## Restricted mode

When Bubblewrap is available, ExeBridge can run an application with a more restricted view of the Linux filesystem and can optionally isolate networking.

**This is defense-in-depth, not a security guarantee.** Proton/Wine is not a security sandbox, and Windows software running through it may still be able to access resources available to your Linux user depending on the selected mode and configuration. Only run software you trust.

## Updating from a repository checkout

After pulling a newer repository version, reinstall/update the user-local application with:

```bash
bash update.sh
```

This preserves existing prefixes and ExeBridge configuration.

## Uninstall

```bash
bash uninstall.sh
```

The uninstaller intentionally preserves managed prefixes so it cannot silently delete installed Windows applications or their data. If you want to remove those later, inspect `~/.local/share/exebridge/prefixes/` first.

## Known limitations

No compatibility front-end can make every Windows executable work. Kernel drivers, some anti-cheat systems, DRM, low-level hardware utilities, and software tied to unsupported Windows services may still require a Windows VM or native Windows installation.

## Source integrity

The exact 0.3.0 application source is reconstructed by:

```bash
bash assemble-source.sh
```

Details are in [`src/source/README.md`](src/source/README.md). The archived original 0.3.0 release manifest is in [`docs/releases/0.3.0-manifest.json`](docs/releases/0.3.0-manifest.json).

GitHub Actions verifies source reconstruction, the expected SHA-256, Python compilation, and shell-script syntax on pushes and pull requests.

## Project structure

See [`docs/PROJECT_STRUCTURE.md`](docs/PROJECT_STRUCTURE.md).

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md).

## License

ExeBridge is released under the **MIT License**. See [`LICENSE`](LICENSE).

## Disclaimer

ExeBridge is an independent compatibility utility. Windows, Steam, Proton, Wine, UMU Launcher, and other referenced projects or trademarks belong to their respective owners.
