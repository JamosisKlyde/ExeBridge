# ExeBridge

> Run Windows `.exe` and `.msi` applications on Fedora, Ubuntu, and Arch Linux through Proton/UMU without hand-managing Wine prefixes.

**Current source version: 0.4.0**

ExeBridge is a PyQt6 desktop front-end that gives Windows programs isolated compatibility environments, per-app launch settings, logs, desktop integration, repair tools, snapshots, and multiple Proton/UMU runner options.

## Distribution support

ExeBridge 0.4.0 adds three first-class Linux distribution modes:

| Mode | Package manager | Notes |
|---|---|---|
| **Fedora — default** | `dnf` | Default/fallback profile and the original ExeBridge target |
| **Ubuntu** | `apt` | Enables `i386` packages on x86-64 for 32-bit Vulkan compatibility |
| **Arch Linux** | `pacman` | Uses Arch packages; `[multilib]` is needed for 32-bit Vulkan/GameMode packages |

The installer auto-detects the host when it recognizes one of these families. If detection is inconclusive, ExeBridge falls back to **Fedora mode**.

The application also has a persistent **Distribution mode** selector, so you can switch the package/diagnostic profile manually without changing your Windows-app settings.

## Highlights

- **Fedora, Ubuntu, and Arch Linux modes**
- Launch `.exe` and `.msi` files from ExeBridge or through desktop file-manager integration
- Isolated Proton/Wine prefix per application, with managed-prefix reuse
- **App Library** with saved programs, quick load/launch, and automatic registration after successful launches
- **Standard**, **Gaming**, **Legacy / OpenGL**, **Managed / .NET**, and **Debug** compatibility modes
- **Runner Manager** for rolling UMU/GE and installed `compatibilitytools.d` runners
- Per-app WineD3D, GameMode, Esync, Fsync, Protonfixes, runner, and isolation controls
- **Fix & Retry** compatibility recipes with executable-fingerprint memory
- Prefix snapshots and restore, including automatic pre-change snapshots before Winetricks changes
- Post-installer executable discovery for MSI/setup-style installers
- Built-in PE icon extraction and Windows-icon desktop shortcuts
- Optional **Restricted filesystem mode** using Bubblewrap, with optional network isolation
- Distro-aware 32-bit graphics dependency diagnostics
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

Or download the latest release ZIP, extract it, open a terminal in that directory, and run:

```bash
chmod +x install.sh
./install.sh
```

### Force a distribution mode

Normally you do not need this because the installer auto-detects supported systems. To override detection:

```bash
./install.sh --distro fedora
./install.sh --distro ubuntu
./install.sh --distro arch
```

Administrator authentication is used only to install system dependencies. ExeBridge itself is installed into your user account.

### Arch multilib note

On Arch, 32-bit Windows applications and games generally need the `[multilib]` repository enabled so `lib32-*` Vulkan/GameMode packages can be installed. You also need the 32-bit Vulkan driver matching your GPU.

## Start ExeBridge

Open **ExeBridge** from your desktop application menu, or run:

```bash
~/.local/bin/exebridge
```

Supported Windows executable MIME types are registered with the desktop. On KDE you can use **Open With → ExeBridge** from Dolphin.

## Distribution mode inside ExeBridge

At the top of the ExeBridge window, choose:

- **Fedora — default**
- **Ubuntu**
- **Arch Linux**

The selection is saved globally in:

```text
~/.local/share/exebridge/config.json
```

Distribution mode controls distro-specific dependency checks and support guidance. Proton/UMU launch behavior remains compatible across all three modes.

You can also start ExeBridge with an explicit mode:

```bash
~/.local/bin/exebridge --distro Ubuntu
```

Valid CLI values are `Fedora`, `Ubuntu`, and `Arch`.

## First launch

The first Windows-program launch may take several minutes because UMU can download the Steam Linux Runtime and the selected Proton/GE-Proton build.

ExeBridge's bundled UMU bootstrap pins **UMU Launcher 1.4.4** and verifies the upstream archive before installation.

## Compatibility modes

| Mode | Purpose |
|---|---|
| **Standard** | Default UMU/Proton configuration for most programs |
| **Gaming** | Gaming-oriented profile with GE-Proton/UMU and GameMode support |
| **Legacy / OpenGL** | Uses WineD3D (`PROTON_USE_WINED3D=1`) for programs that have trouble with Vulkan/DXVK |
| **Managed / .NET** | UMU-Proton plus ExeBridge's tested compatibility pack |
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

After pulling a newer repository version, update the user-local application with:

```bash
bash update.sh
```

This preserves existing prefixes, distro selection, and ExeBridge configuration.

## Uninstall

```bash
bash uninstall.sh
```

The uninstaller intentionally preserves managed prefixes so it cannot silently delete installed Windows applications or their data. If you want to remove those later, inspect `~/.local/share/exebridge/prefixes/` first.

## Known limitations

No compatibility front-end can make every Windows executable work. Kernel drivers, some anti-cheat systems, DRM, low-level hardware utilities, and software tied to unsupported Windows services may still require a Windows VM or native Windows installation.

Arch users must manage the GPU-specific 32-bit Vulkan driver appropriate for their hardware. Ubuntu users with proprietary NVIDIA drivers may likewise need the matching NVIDIA `:i386` libraries supplied for their installed driver branch.

## Source integrity

The canonical 0.4.0 application source is reconstructed by:

```bash
bash assemble-source.sh
```

Expected SHA-256:

```text
003140c03e5a2aa4203c42547c18a3a62545b6ee7560606d27cb932d8b88a389
```

Details are in [`src/source/README.md`](src/source/README.md).

GitHub Actions verifies source reconstruction, the expected SHA-256, Python compilation, shell-script syntax, and the presence of all three distro modes on pushes and pull requests.

## Project structure

See [`docs/PROJECT_STRUCTURE.md`](docs/PROJECT_STRUCTURE.md).

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md).

## License

ExeBridge is released under the **MIT License**. See [`LICENSE`](LICENSE).

## Disclaimer

ExeBridge is an independent compatibility utility. Windows, Steam, Proton, Wine, UMU Launcher, Fedora, Ubuntu, Arch Linux, and other referenced projects or trademarks belong to their respective owners.
