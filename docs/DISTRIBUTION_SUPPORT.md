# Distribution Support

ExeBridge 0.4.0 has three supported distribution modes. Fedora is the default/fallback profile.

## Fedora

- Package manager: `dnf`
- UI package: `python3-pyqt6`
- Restricted mode: `bubblewrap`
- 32-bit graphics checks: `mesa-vulkan-drivers.i686`, `mesa-dri-drivers.i686`, `vulkan-loader.i686`

Fedora remains the baseline ExeBridge platform.

## Ubuntu

- Package manager: `apt`
- UI package: `python3-pyqt6`
- Restricted mode: `bubblewrap`
- x86-64 installs enable the `i386` architecture when needed.
- 32-bit Vulkan checks include `libvulkan1:i386` and `mesa-vulkan-drivers:i386`.

Ubuntu systems using proprietary NVIDIA drivers may need the NVIDIA 32-bit userspace libraries matching the installed driver branch.

## Arch Linux

- Package manager: `pacman`
- UI package: `python-pyqt6`
- Restricted mode: `bubblewrap`
- Generic Vulkan loader: `vulkan-icd-loader`
- 32-bit Vulkan loader: `lib32-vulkan-icd-loader`
- 32-bit GameMode: `lib32-gamemode`

For 32-bit Vulkan applications, Arch's `[multilib]` repository must be enabled and a matching 32-bit GPU driver must be installed. Common examples:

- AMD: `lib32-vulkan-radeon`
- Intel: `lib32-vulkan-intel`
- NVIDIA: `lib32-nvidia-utils`

## Selection behavior

`install.sh` detects supported distro families from `/etc/os-release`. When detection is inconclusive, it falls back to Fedora.

Override the installer explicitly with:

```bash
./install.sh --distro fedora
./install.sh --distro ubuntu
./install.sh --distro arch
```

The ExeBridge application itself stores the selected mode in `~/.local/share/exebridge/config.json` and exposes it in the UI.

Distribution mode affects package/dependency diagnostics and distro-specific support guidance. The UMU/Proton launch architecture remains shared across all three modes.
