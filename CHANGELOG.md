# Changelog

## 0.5.1 — Known Good + desktop shortcuts restored

- Restored **Mark Known Good** for saving working executable paths and compatibility profiles.
- Restored the **Known Good manager** with load, direct launch, remove, and desktop-shortcut actions.
- Restored **Create Desktop Icon** and application-menu shortcut generation.
- Desktop shortcuts launch the exact saved Known Good setup with `--profile-id` and `--launch-now`.
- Added migration of recognizable preserved Known Good layouts from ExeBridge 0.2–0.4 without deleting legacy keys.
- Reuses preserved extracted Windows icons from older App Library data when available.
- Kept all 0.5.0 legacy compatibility and expanded runner support.
- Kept the built-in stable update manager and user-local version backups.

## 0.5.0 — Legacy-game and expanded runner update

- Added runner discovery for UMU/GE-Proton, installed Steam Proton versions, custom Proton/Proton-TKG, Lutris Wine/Wine-GE, and system Wine/Wine64.
- Added **Legacy Auto** and **Japanese / CP932 legacy** compatibility presets.
- Added an ASCII path bridge for older applications that cannot safely consume non-ASCII paths.
- Added WineD3D/OpenGL fallback and conservative Esync/Fsync options for older titles.
- Added the built-in stable update manager with update-ZIP manifest/hash validation and rollback backups.

## 0.4.0 — Fedora / Ubuntu / Arch update

- Added first-class **Fedora**, **Ubuntu**, and **Arch Linux** distribution modes.
- Kept **Fedora as the default/fallback mode**.
- Added automatic supported-distro detection during installation.
- Added distro-aware package-manager and 32-bit graphics dependency handling.
- Preserved existing prefixes, per-app settings, Known Good data, snapshots, compatibility memory, and runner settings when upgrading from 0.3.0.

## 0.3.0 — Section 2 advanced update

- Added App Library, executable discovery, icon extraction, Runner Manager, advanced compatibility controls, prefix snapshots, Restricted mode, and compatibility memory.
- Desktop shortcuts use extracted Windows icons when available.

## 0.2.0

- Added Fix & Retry, local verified updates, PE architecture detection, Known Good restore, and GameMode fallback.

## 0.1.1

- Added Smart Auto-Fix and Managed/.NET compatibility mode.
