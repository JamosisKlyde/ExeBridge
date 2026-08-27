#!/usr/bin/env python3
import ast
import sys
from pathlib import Path

source_path = Path(sys.argv[1])
text = source_path.read_text(encoding="utf-8")
tree = ast.parse(text)

version = None
distro_modes = None
functions = set()
for node in ast.walk(tree):
    if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
        functions.add(node.name)
    if isinstance(node, ast.Assign):
        for target in node.targets:
            if isinstance(target, ast.Name) and target.id == "VERSION":
                version = ast.literal_eval(node.value)
            if isinstance(target, ast.Name) and target.id == "DISTRO_MODES":
                distro_modes = ast.literal_eval(node.value)

assert version == "0.4.0", version
assert distro_modes == ("Fedora", "Ubuntu", "Arch"), distro_modes
for required in {"detect_host_distro", "distribution_mode", "set_distro_by_name", "missing_32bit_graphics_packages"}:
    assert required in functions, required
for token in ("Fedora — default", "Ubuntu — apt/dpkg", "Arch — pacman", "--distro"):
    assert token in text, token
print("ExeBridge 0.4.0 multi-distro source checks passed")
