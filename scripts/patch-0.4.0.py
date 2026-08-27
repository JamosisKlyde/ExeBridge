#!/usr/bin/env python3
"""Deterministically upgrade the verified ExeBridge 0.3.0 source to 0.4.0."""
from __future__ import annotations

import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit("usage: patch-0.4.0.py <0.3.0-source> <0.4.0-output>")

source = Path(sys.argv[1])
output = Path(sys.argv[2])
text = source.read_text(encoding="utf-8")


def replace_once(old: str, new: str) -> None:
    global text
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"0.4.0 patch expected one match but found {count}: {old[:80]!r}")
    text = text.replace(old, new, 1)


replace_once('VERSION = "0.3.0"', 'VERSION = "0.4.0"')
replace_once(
    'I686_GRAPHICS_PACKAGES = ("mesa-vulkan-drivers.i686", "mesa-dri-drivers.i686", "vulkan-loader.i686")',
    '''DISTRO_MODES = ("Fedora", "Ubuntu", "Arch")\nDISTRO_32BIT_PACKAGES = {\n    "Fedora": ("mesa-vulkan-drivers.i686", "mesa-dri-drivers.i686", "vulkan-loader.i686"),\n    "Ubuntu": ("mesa-vulkan-drivers:i386", "libvulkan1:i386", "libgl1-mesa-dri:i386"),\n    "Arch": ("lib32-mesa", "lib32-vulkan-icd-loader"),\n}''',
)
replace_once(
    'def ensure_dirs() -> None:\n',
    '''def read_os_release() -> dict[str, str]:\n    data: dict[str, str] = {}\n    try:\n        for raw in Path("/etc/os-release").read_text(encoding="utf-8").splitlines():\n            line = raw.strip()\n            if not line or line.startswith("#") or "=" not in line:\n                continue\n            key, value = line.split("=", 1)\n            data[key] = value.strip().strip('"').strip("'")\n    except Exception:\n        pass\n    return data\n\n\ndef detect_host_distro() -> str:\n    """Map the host to an ExeBridge distro mode; Fedora is the fallback/default."""\n    info = read_os_release()\n    distro_id = info.get("ID", "").lower()\n    like = set(info.get("ID_LIKE", "").lower().split())\n    tokens = {distro_id, *like}\n    if "ubuntu" in tokens:\n        return "Ubuntu"\n    if "arch" in tokens:\n        return "Arch"\n    if "fedora" in tokens:\n        return "Fedora"\n    return "Fedora"\n\n\ndef ensure_dirs() -> None:\n''',
)
replace_once(
    '''def load_config() -> dict:\n    try:\n        return json.loads(CONFIG_FILE.read_text())\n    except Exception:\n        return {"apps": {}}\n''',
    '''def load_config() -> dict:\n    try:\n        cfg = json.loads(CONFIG_FILE.read_text())\n        if not isinstance(cfg, dict):\n            raise ValueError("config root must be an object")\n    except Exception:\n        cfg = {"apps": {}}\n    cfg.setdefault("apps", {})\n    cfg.setdefault("distribution_mode", detect_host_distro())\n    return cfg\n''',
)
replace_once(
    '''class MainWindow(QMainWindow):\n    def __init__(self, initial_exe: str | None = None, auto_launch: bool = False,\n                 initial_profile: str | None = None) -> None:\n''',
    '''class MainWindow(QMainWindow):\n    def __init__(self, initial_exe: str | None = None, auto_launch: bool = False,\n                 initial_profile: str | None = None, initial_distro: str | None = None) -> None:\n''',
)
replace_once(
    '''        self.profile_combo = QComboBox()\n        self.profile_combo.addItems([\n''',
    '''        self.distro_combo = QComboBox()\n        self.distro_combo.addItems([\n            "Fedora — default",\n            "Ubuntu — apt/dpkg",\n            "Arch — pacman",\n        ])\n        distro_mode = initial_distro or self.cfg.get("distribution_mode", detect_host_distro())\n        self.set_distro_by_name(distro_mode)\n        self.distro_combo.currentTextChanged.connect(self.distribution_changed)\n        form.addRow("Distribution mode:", self.distro_combo)\n\n        self.profile_combo = QComboBox()\n        self.profile_combo.addItems([\n''',
)
replace_once(
    '    def set_profile_by_name(self, name: str) -> None:\n',
    '''    def distribution_mode(self) -> str:\n        text = self.distro_combo.currentText().lower()\n        if text.startswith("ubuntu"):\n            return "Ubuntu"\n        if text.startswith("arch"):\n            return "Arch"\n        return "Fedora"\n\n    def set_distro_by_name(self, name: str) -> None:\n        needle = (name or "Fedora").lower()\n        for i in range(self.distro_combo.count()):\n            if self.distro_combo.itemText(i).lower().startswith(needle):\n                self.distro_combo.setCurrentIndex(i)\n                return\n        self.distro_combo.setCurrentIndex(0)\n\n    def distribution_changed(self, _text: str = "") -> None:\n        self.cfg["distribution_mode"] = self.distribution_mode()\n        save_config(self.cfg)\n        self.refresh_backend()\n        raw = self.exe_edit.text().strip()\n        if raw:\n            self.update_exe_metadata(Path(raw).expanduser())\n\n    def set_profile_by_name(self, name: str) -> None:\n''',
)
replace_once(
    '                "Install the Fedora \'bubblewrap\' package or switch Filesystem access back to Normal."\n',
    '                "Install the \'bubblewrap\' package for your distribution or switch Filesystem access back to Normal."\n',
)
replace_once(
    '''    def refresh_backend(self) -> None:\n        umu = find_umu()\n        gm = shutil.which("gamemoderun")\n        if umu:\n            text = f"ExeBridge <b>{VERSION}</b><br>UMU: <b>ready</b> ({umu})"\n        else:\n            text = f"ExeBridge <b>{VERSION}</b><br>UMU: <b>not installed</b> — use “Install / Repair UMU”"\n        if gm:\n            gm_ok = self.gamemode_works()\n            text += "<br>GameMode: " + (f"<b>ready</b> ({gm})" if gm_ok else "<b>installed but unhealthy — automatic fallback enabled</b>")\n        else:\n            text += "<br>GameMode: <b>not installed — automatic fallback enabled</b>"\n        text += "<br>Restricted mode: " + ("<b>ready</b> (bubblewrap)" if shutil.which("bwrap") else "<b>unavailable</b> (bubblewrap not installed)")\n        self.backend_label.setText(text)\n''',
    '''    def refresh_backend(self) -> None:\n        umu = find_umu()\n        gm = shutil.which("gamemoderun")\n        mode = self.distribution_mode()\n        detected = detect_host_distro()\n        if umu:\n            text = f"ExeBridge <b>{VERSION}</b><br>UMU: <b>ready</b> ({umu})"\n        else:\n            text = f"ExeBridge <b>{VERSION}</b><br>UMU: <b>not installed</b> — use “Install / Repair UMU”"\n        text += f"<br>Distribution mode: <b>{mode}</b>"\n        if detected != mode:\n            text += f" (host looks like {detected})"\n        if gm:\n            gm_ok = self.gamemode_works()\n            text += "<br>GameMode: " + (f"<b>ready</b> ({gm})" if gm_ok else "<b>installed but unhealthy — automatic fallback enabled</b>")\n        else:\n            text += "<br>GameMode: <b>not installed — automatic fallback enabled</b>"\n        text += "<br>Restricted mode: " + ("<b>ready</b> (bubblewrap)" if shutil.which("bwrap") else "<b>unavailable</b> (bubblewrap not installed)")\n        self.backend_label.setText(text)\n''',
)
replace_once(
    '''    def missing_i686_packages(self) -> list[str]:\n        if not shutil.which("rpm"):\n            return []\n        missing = []\n        for pkg in I686_GRAPHICS_PACKAGES:\n            try:\n                result = subprocess.run(\n                    ["rpm", "-q", pkg],\n                    stdout=subprocess.DEVNULL,\n                    stderr=subprocess.DEVNULL,\n                    timeout=4,\n                    check=False,\n                )\n                if result.returncode != 0:\n                    missing.append(pkg)\n            except Exception:\n                break\n        return missing\n''',
    '''    def missing_32bit_graphics_packages(self) -> list[str]:\n        mode = self.distribution_mode()\n        packages = DISTRO_32BIT_PACKAGES.get(mode, ())\n        missing: list[str] = []\n\n        if mode == "Fedora":\n            if not shutil.which("rpm"):\n                return []\n            command = lambda pkg: ["rpm", "-q", pkg]\n        elif mode == "Ubuntu":\n            if not shutil.which("dpkg-query"):\n                return []\n            command = lambda pkg: ["dpkg-query", "-W", "-f=${Status}", pkg]\n        else:\n            if not shutil.which("pacman"):\n                return []\n            command = lambda pkg: ["pacman", "-Q", pkg]\n\n        for pkg in packages:\n            try:\n                result = subprocess.run(\n                    command(pkg),\n                    stdout=subprocess.PIPE,\n                    stderr=subprocess.DEVNULL,\n                    text=True,\n                    timeout=4,\n                    check=False,\n                )\n                ok = result.returncode == 0\n                if mode == "Ubuntu" and ok:\n                    ok = "install ok installed" in result.stdout.lower()\n                if not ok:\n                    missing.append(pkg)\n            except Exception:\n                break\n        return missing\n''',
)
replace_once(
    '''            missing = self.missing_i686_packages()\n            if missing:\n                extra = " — 32-bit graphics packages missing"\n''',
    '''            missing = self.missing_32bit_graphics_packages()\n            if missing:\n                extra = f" — {self.distribution_mode()} 32-bit graphics support incomplete"\n''',
)
replace_once(
    '            self.log_handle.write(f"Executable: {exe}\\nPrefix: {prefix}\\nMode: {self.profile_key()}\\n")\n',
    '''            self.log_handle.write(\n                f"Executable: {exe}\\nPrefix: {prefix}\\nDistribution: {self.distribution_mode()}\\nMode: {self.profile_key()}\\n"\n            )\n''',
)
replace_once(
    '        self.append_log(f"Prefix: {prefix}\\nMode: {self.profile_key()}\\n")\n',
    '''        self.append_log(\n            f"Prefix: {prefix}\\nDistribution: {self.distribution_mode()}\\nMode: {self.profile_key()}\\n"\n        )\n''',
)
replace_once(
    '''    p.add_argument(\n        "--profile",\n        choices=["Standard", "Gaming", "Legacy", "Managed", "Debug"],\n        default=None,\n        help="Compatibility profile to select",\n    )\n''',
    '''    p.add_argument(\n        "--profile",\n        choices=["Standard", "Gaming", "Legacy", "Managed", "Debug"],\n        default=None,\n        help="Compatibility profile to select",\n    )\n    p.add_argument(\n        "--distro",\n        choices=["Fedora", "Ubuntu", "Arch"],\n        default=None,\n        help="Distribution mode to select (Fedora is the fallback/default)",\n    )\n''',
)
replace_once(
    '    win = MainWindow(initial_exe=initial, auto_launch=bool(args.launch), initial_profile=args.profile)\n',
    '''    win = MainWindow(\n        initial_exe=initial,\n        auto_launch=bool(args.launch),\n        initial_profile=args.profile,\n        initial_distro=args.distro,\n    )\n''',
)
replace_once(
    '''        self.exe_edit.editingFinished.connect(self.exe_changed)\n\n        if initial_profile:\n''',
    '''        self.exe_edit.editingFinished.connect(self.exe_changed)\n\n        if initial_distro:\n            self.cfg["distribution_mode"] = self.distribution_mode()\n            save_config(self.cfg)\n        if initial_profile:\n''',
)

output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(text, encoding="utf-8")
