# ExeBridge

> Run Windows `.exe` and `.msi` applications on Fedora, Ubuntu, and Arch Linux with Proton/UMU or Wine, including legacy Windows-game compatibility helpers.

**Current stable version: 0.6.0**\n\n> **Fedora 45 compatibility work (unreleased):** See the `feature/fedora45-compatibility` branch. These changes are for validation and have not been published as a stable release.

ExeBridge is a PyQt6 desktop front-end for launching Windows applications with isolated prefixes, selectable runners, legacy-game compatibility controls, saved Known Good configurations, desktop shortcuts, dependency helpers, and user-local updates.

## 0.6.0 highlights

- **Microsoft Edge WebView2 support** is now built into ExeBridge as a per-application compatibility component.
- Three WebView2 modes: **Auto-detect**, **Required / ensure installed**, and **Disabled**.
- **Check WebView2** inspects the selected application's exact Wine/Proton prefix for an installed runtime.
- **Install / Repair WebView2** downloads Microsoft's Evergreen bootstrapper and runs it inside the selected prefix.
- Automatic pre-launch provisioning can install WebView2 and retry the Windows app when the dependency is required.
- Silent installation is attempted first, with a visible-installer fallback when verification fails.
- WebView2 mode is included in **Known Good** profiles and restored by their desktop shortcuts.
- All 0.5.1 legacy compatibility, Japanese/CP932 handling, runner discovery, Known Good management, and updater functionality remain available.

## Runner support

ExeBridge detects UMU/GE-Proton, Steam Proton (including older installed versions), custom Proton/Proton-TKG, Lutris Wine/Wine-GE, and system Wine/Wine64.

Older games can use **Legacy Auto** or **Japanese / CP932 legacy** presets, WineD3D/OpenGL fallback, conservative Esync/Fsync settings, and the ASCII path bridge for applications that cannot safely consume non-ASCII paths.

## WebView2 component support

For Windows applications that embed Microsoft Edge WebView2:

1. Select the Windows executable and its ExeBridge prefix.
2. Leave **WebView2 Runtime** on **Auto-detect**, or choose **Required / ensure installed** when the application is known to need it.
3. Use **Check WebView2** to inspect the prefix.
4. Use **Install / Repair WebView2** to provision the Evergreen runtime in that prefix.
5. Launch normally after ExeBridge verifies the runtime.

WebView2 is a modern Windows component. ExeBridge can automate detection, download, prefix-targeted installation, verification, and retry handling, but Wine/Proton compatibility still varies by application.

## Fedora 45 validation (development branch)\n\nFor existing installs, use the **read-only** diagnostic before attempting to update:\n\n```bash\nbash scripts/fedora45-doctor.sh\n```\n\nThe diagnostic checks the Fedora version, system PyQt6, installed Wine/UMU, helper commands, and 32-bit Mesa/Vulkan components. It also syntax-checks an existing ExeBridge installation without modifying prefixes. Missing Wine is a warning rather than an error because UMU/Proton can be used independently.\n\nThe development branch adds a Fedora 45 GitHub Actions smoke test covering script syntax, verified source reconstruction, Python compilation, and the host diagnostic. **Passing CI does not guarantee a Windows executable will run.** Real Fedora 45 KDE Wayland sessions, Wine/UMU/Proton, GUI launch, games, WebView2 and per-app prefixes still need end-to-end testing. Do not install the branch over a working setup until validated.\n\n## Distribution support

The installer supports Fedora (`dnf`), Ubuntu (`apt`), and Arch (`pacman`). Fedora remains the default/fallback installer profile. Ubuntu enables i386 on x86-64, and Arch requires `[multilib]` for 32-bit compatibility packages.

## Install

```bash
git clone https://github.com/JamosisKlyde/ExeBridge.git
cd ExeBridge
chmod +x install.sh install-or-update.sh
./install.sh
```

Or download the latest release ZIP, extract it, and run `./install.sh` from the extracted folder.

To force an installer family:

```bash
./install.sh --distro fedora
./install.sh --distro ubuntu
./install.sh --distro arch
```

## Updating an existing installation

Inside ExeBridge, click **Updates…** and either **Check GitHub** or **Install Update ZIP…**. The updater verifies the stable update manifest and SHA-256 hashes, backs up the previous app files, then preserves prefixes and settings.

From a repository checkout, `bash update.sh` updates only the user-local application files.

## Known Good and desktop shortcuts

After a game or application works, click **Mark Known Good**. Use **Known Good…** to restore or launch the exact saved runner/prefix/compatibility setup later. **Create Desktop Icon** creates a desktop and application-menu shortcut that launches that saved profile directly.

## Data location

Prefixes, configuration, logs, Known Good profiles, and prior app-version backups live under:

```text
~/.local/share/exebridge/
```

## Uninstall

```bash
bash uninstall.sh
```

The uninstaller removes ExeBridge application files and launchers but intentionally preserves prefixes, settings, logs, Known Good profiles, and version backups.

## Source integrity

The canonical application sources are stored as verified gzip/Base64 shards under `src/source/`. `assemble-source.sh` reconstructs `exebridge.py`, `updater.py`, and `webview2_helper.py` and verifies their SHA-256 hashes. Release ZIPs include the reconstructed app payload plus a stable `update-manifest.json` with SHA-256 hashes.

## License

ExeBridge is released under the **MIT License**. See [`LICENSE`](LICENSE).

## Disclaimer

ExeBridge is an independent compatibility utility. Windows, Microsoft Edge WebView2, Steam, Proton, Wine, UMU Launcher, Fedora, Ubuntu, Arch Linux, Lutris, and other referenced projects or trademarks belong to their respective owners.
