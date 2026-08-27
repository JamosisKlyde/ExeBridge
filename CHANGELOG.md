# Changelog

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
