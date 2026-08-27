# ExeBridge

> A Linux front-end for launching Windows `.exe` and `.msi` applications through Proton using the UMU launcher.

ExeBridge is designed to make running Windows applications on Linux feel less like managing Wine prefixes by hand and more like launching a normal desktop application.

It provides a KDE/Qt interface, per-application compatibility modes, isolated prefixes, logging, desktop shortcuts, and Dolphin integration while keeping ordinary launches inside the user account.

---

## Features

- **Windows `.exe` / `.msi` launcher for Linux**
- **PyQt6 / KDE-friendly desktop interface**
- **UMU Launcher + Proton integration**
- **Per-application isolated prefixes**
- **Automatic prefix reuse** for executables located inside an existing managed prefix
- **Dolphin “Open With” integration**
- **Desktop shortcut creation**
- **Per-app settings**
- **Per-app logs**
- **Open or reset an application prefix**
- **User-local UMU installation and repair**
- **No `sudo` or `pkexec` required for normal application launches**

---

## Compatibility Modes

ExeBridge includes several launch profiles so applications can be started with different compatibility settings without manually editing environment variables.

| Mode | Purpose |
|---|---|
| **Standard** | Default mode for most Windows applications |
| **Gaming** | Gaming-oriented launch profile |
| **Legacy / OpenGL** | Uses WineD3D for applications that have problems with DXVK/Vulkan |
| **Debug** | Enables additional logging for troubleshooting |

The **Legacy / OpenGL** profile uses:

```bash
PROTON_USE_WINED3D=1
```

---

## How It Works

```text
Windows EXE / MSI
       │
       ▼
   ExeBridge
       │
       ├── Select compatibility mode
       ├── Load per-app settings
       ├── Create/reuse isolated prefix
       │
       ▼
   UMU Launcher
       │
       ▼
 Proton / GE-Proton
       │
       ▼
 Windows application
```

Each managed application gets its own compatibility environment instead of forcing every Windows program into one shared prefix.

Managed prefixes are stored under:

```text
~/.local/share/exebridge/prefixes/
```

---

## Installation

### Fedora / Fedora KDE

Clone or download the ExeBridge repository, then run:

```bash
chmod +x install.sh
./install.sh
```

The installer performs the required system-package setup and then installs ExeBridge and UMU for the current user.

The Fedora setup may request administrator authentication once to install required packages such as:

- `python3-pyqt6`
- `gamemode`
- desktop integration utilities

Normal ExeBridge launches do **not** require administrator privileges.

> **Development status:** the public repository is being prepared now. The application source and installer will be added separately; the install commands above become usable once `install.sh` is present.

---

## Starting ExeBridge

After installation, ExeBridge can be opened from the KDE application menu.

It can also be started directly with:

```bash
~/.local/bin/exebridge
```

You can additionally launch supported Windows files through Dolphin using **Open With → ExeBridge**.

---

## First Launch

The first launch of a Windows application may take longer than later launches.

UMU may need to download components such as:

- Steam Linux Runtime
- Proton
- compatibility runtime files

Depending on your connection, this can take several minutes.

After the required runtime is available, later launches should be substantially faster.

---

## Application Prefixes

ExeBridge isolates applications using separate Proton/Wine prefixes.

Default location:

```text
~/.local/share/exebridge/prefixes/
```

This helps reduce conflicts between applications that require different Windows libraries, settings, or compatibility options.

ExeBridge can also detect executables launched from inside an existing managed prefix and reuse that prefix when appropriate.

### Prefix Tools

From ExeBridge you can:

- Open an application's prefix
- Reset a broken prefix
- View application logs
- Change launch mode
- Create a desktop shortcut

> Resetting a prefix can remove Windows-side configuration and files stored inside that prefix. Back up important application data first.

---

## Desktop Integration

ExeBridge is intended to behave like a native Linux application.

Supported integration includes:

- KDE application launcher entry
- Dolphin **Open With** support
- Desktop shortcuts for Windows programs
- Graphical launch configuration
- Notifications and logs

---

## UMU Launcher

ExeBridge uses **UMU Launcher** as the compatibility-layer bridge between Linux and Proton.

UMU allows Proton to be used outside of the normal Steam game-launch workflow while retaining the runtime environment Proton expects.

ExeBridge's installer can bootstrap or repair the user-local UMU installation.

---

## File Locations

Typical ExeBridge paths:

```text
~/.local/bin/exebridge
~/.local/share/exebridge/
~/.local/share/exebridge/prefixes/
~/.local/share/applications/
```

Exact paths may vary as the project evolves.

---

## Troubleshooting

### The first launch appears stuck

Give UMU time to download the required Steam runtime and Proton files.

Run ExeBridge in **Debug** mode if the application still does not start.

### A program opens but graphics are broken

Try **Legacy / OpenGL**. This enables:

```bash
PROTON_USE_WINED3D=1
```

and can help with applications that do not work correctly through the normal Vulkan/DXVK path.

### A game performs poorly

Try the **Gaming** profile.

Also verify that your graphics drivers and Vulkan support are correctly installed.

### An application stopped working after changing settings

Reset that application's prefix and launch it again.

Be aware that resetting the prefix can remove application data stored inside the Windows compatibility environment.

### ExeBridge itself will not start

Launch it from a terminal:

```bash
~/.local/bin/exebridge
```

The terminal output can help identify missing Python, Qt, UMU, or runtime dependencies.

---

## Project Goals

ExeBridge aims to provide a practical middle ground between:

- manually configuring Wine
- full compatibility managers
- launching everything through Steam

The focus is on making individual Windows executables easy to launch while still exposing enough control to troubleshoot programs that need special compatibility settings.

---

## Current Focus

Development priorities include:

- broader Windows application compatibility
- improved automatic Proton selection
- cleaner error reporting
- stronger prefix management
- easier repair tools
- additional desktop integration
- streamlined updates

---

## Platform

ExeBridge is currently designed primarily around:

- **Linux**
- **Fedora / Fedora KDE**
- **KDE Plasma**
- **Python / PyQt6**
- **UMU Launcher**
- **Proton / GE-Proton**

Support for additional distributions can be expanded as the project matures.

---

## Contributing

Bug reports, compatibility reports, and development contributions are welcome once the public contribution workflow is finalized.

When reporting an application compatibility problem, useful information includes:

- Linux distribution
- desktop environment
- GPU
- Proton version
- ExeBridge launch mode
- application/game name
- relevant ExeBridge debug log

Do **not** include passwords, API keys, authentication tokens, or other credentials in logs or issue reports.

---

## Disclaimer

ExeBridge is an independent compatibility utility.

Windows, Steam, Proton, Wine, UMU Launcher, and other referenced projects or trademarks belong to their respective owners.

Compatibility varies by application. Some Windows software may require additional components or may not work correctly through Proton/Wine.

---

## License

A project license has not yet been selected.

Until a license is added, normal copyright restrictions apply to the source code.

---

<p align="center">
  <strong>ExeBridge</strong><br>
  Windows EXE launcher • UMU + Proton • Linux
</p>
