# ExeBridge

> Run Windows `.exe` and `.msi` applications on Fedora, Ubuntu, and Arch Linux with Proton/UMU or Wine, including legacy Windows-game compatibility helpers.

**Current stable version: 0.5.1**

ExeBridge is a PyQt6 desktop front-end for launching Windows applications with isolated prefixes, selectable runners, legacy-game compatibility controls, saved Known Good configurations, desktop shortcuts, and user-local updates.

## 0.5.1 highlights

- **Mark Known Good** saves a working executable path together with its prefix, runner, compatibility preset, Japanese-locale setting, ASCII path bridge, and WineD3D setting.
- **Known Good manager** can restore, launch, remove, or create a shortcut from a saved working setup.
- **Desktop icons are back** and launch the exact saved Known Good profile through `--profile-id` / `--launch-now`.
- Attempts to migrate recognizable **0.2–0.4 Known Good** entries without deleting legacy keys.
- Reuses preserved extracted Windows icons when available; otherwise uses the ExeBridge icon.
- Keeps the 0.5 legacy-game stack: expanded Proton/Wine runners, Japanese/CP932 handling, ASCII path bridging, and WineD3D/OpenGL fallback.
- Built-in stable updater can check GitHub Releases or install a downloaded ExeBridge update ZIP.

## Runner support

ExeBridge detects UMU/GE-Proton, Steam Proton (including older installed versions), custom Proton/Proton-TKG, Lutris Wine/Wine-GE, and system Wine/Wine64.

Older games can use **Legacy Auto** or **Japanese / CP932 legacy** presets, WineD3D/OpenGL fallback, and conservative Esync/Fsync settings.

## Distribution support

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

## Updating an existing 0.5.x installation

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

The canonical application sources are stored as verified gzip/Base64 shards under `src/source/`. `assemble-source.sh` reconstructs both `exebridge.py` and `updater.py` and verifies their SHA-256 hashes. Release ZIPs include the reconstructed app payload plus a stable `update-manifest.json` with SHA-256 hashes.

## License

ExeBridge is released under the **MIT License**. See [`LICENSE`](LICENSE).

## Disclaimer

ExeBridge is an independent compatibility utility. Windows, Steam, Proton, Wine, UMU Launcher, Fedora, Ubuntu, Arch Linux, Lutris, and other referenced projects or trademarks belong to their respective owners.
