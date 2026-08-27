# Contributing to ExeBridge

Thanks for helping improve ExeBridge.

## Good contribution targets

- Windows application compatibility reports
- Fedora/KDE integration fixes
- Proton/UMU launch improvements
- Prefix management fixes
- Logging and diagnostics
- Installer reliability
- Documentation

## Before opening an issue

Please include enough detail to reproduce the problem:

- Linux distribution and version
- Desktop environment
- GPU and driver stack
- Proton or GE-Proton version if known
- ExeBridge launch mode
- Application or game name
- Relevant debug output

Remove passwords, API keys, tokens, private paths, or other sensitive information before posting logs.

## Pull requests

Keep changes focused and explain:

1. What problem the change solves
2. How it was tested
3. Any compatibility or migration impact

Avoid unrelated formatting changes in the same pull request as functional changes.

## Compatibility reports

If an application works only with a specific mode or environment variable, include that information so the behavior can potentially be automated in a future release.
