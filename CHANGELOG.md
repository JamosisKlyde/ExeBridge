# Changelog

## 0.4.0 — Fedora / Ubuntu / Arch update

- Added first-class **Fedora**, **Ubuntu**, and **Arch Linux** distribution modes.
- Kept **Fedora as the default/fallback mode**.
- Added automatic supported-distro detection during installation.
- Added `./install.sh --distro fedora|ubuntu|arch` to override installer detection.
- Added a persistent **Distribution mode** selector directly in the ExeBridge UI.
- Added `--distro Fedora|Ubuntu|Arch` to the ExeBridge command line.
- Added distro-aware package-manager handling:
  - Fedora: `dnf`
  - Ubuntu: `apt`
  - Arch: `pacman`
- Added Ubuntu `i386` setup and 32-bit Vulkan dependency handling for x86-64 systems.
- Added Arch multilib-aware 32-bit Vulkan/GameMode handling and GPU-driver guidance.
- Replaced Fedora-only 32-bit graphics diagnostics with distro-aware checks.
- Updated Bubblewrap/Restricted-mode guidance so it follows the selected distro mode.
- Preserved existing prefixes, per-app settings, Known Good data, snapshots, compatibility memory, and runner settings when upgrading from 0.3.0.

## 0.3.0 — Section 2 advanced update

- Added App Library with saved programs, quick load/launch, and automatic library registration after successful launches.
- Added post-installer executable discovery for MSI/setup-style installers.
- Added built-in PE icon extraction with no extra Python package dependency.
- Added Runner Manager for rolling UMU/GE runners and specific compatibilitytools.d runners.
- Added per-app advanced compatibility controls for runner, WineD3D, GameMode, Esync, Fsync, Protonfixes, and isolation.
- Added prefix snapshots and restore, with automatic pre-change snapshots before Winetricks modifications.
- Added Restricted filesystem mode using bubblewrap when available, plus optional network isolation.
- Added compatibility memory: successful Fix & Retry recipes are learned by executable fingerprint and can be reused on another copy of the same executable.
- Desktop shortcuts now use extracted Windows icons when available.
- Existing 0.2.0 reliability features remain intact.

## 0.2.0

- Added Fix & Retry, local verified updates, PE architecture detection, Known Good restore, and GameMode fallback.

## 0.1.1

- Added Smart Auto-Fix and Managed/.NET compatibility mode.
