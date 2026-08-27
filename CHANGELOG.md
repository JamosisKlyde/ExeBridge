# Changelog

## 0.4.0 — Fedora, Ubuntu, and Arch modes

- Added first-class **Fedora**, **Ubuntu**, and **Arch** distribution modes.
- Fedora remains the fallback/default mode.
- Added host distro detection using `/etc/os-release`; recognized Ubuntu/Arch/Fedora families are selected automatically on first run.
- Added a visible **Distribution mode** selector in the ExeBridge UI and persistence in `config.json`.
- Added `--distro Fedora|Ubuntu|Arch` command-line override.
- Added distro-aware 32-bit graphics dependency checks:
  - Fedora: RPM/i686 Mesa + Vulkan packages.
  - Ubuntu: dpkg/i386 Mesa + Vulkan packages.
  - Arch: pacman/lib32 Mesa + Vulkan loader packages.
- Reworked `install.sh` to use the appropriate package manager:
  - Fedora → `dnf`
  - Ubuntu → `apt-get` / `dpkg`
  - Arch → `pacman`
- Ubuntu installation can enable i386 multiarch automatically on x86-64 systems.
- Arch installation detects whether `multilib` is available and attempts to install a matching 32-bit Vulkan driver for common AMD, Intel, Nouveau, software Vulkan, and NVIDIA setups.
- Backend status and launch logs now record the active distribution mode.
- Restricted-mode guidance is no longer Fedora-specific.
- Release packaging now generates a root `manifest.json` so GitHub-built packages remain compatible with ExeBridge's verified local updater.
- Added CI checks for the 0.4.0 multi-distro source structure.

## 0.3.0 — Section 2 advanced update

- Added App Library with saved programs, quick load/launch, and automatic library registration after successful launches.
- Added post-installer executable discovery for MSI/setup-style installers.
- Added built-in PE icon extraction with no extra Python package dependency.
- Added Runner Manager for rolling UMU/GE runners and specific `compatibilitytools.d` runners.
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
