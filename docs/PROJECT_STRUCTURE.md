# ExeBridge Project Structure

This repository is being organized so application code, desktop integration, tests, and documentation stay separate.

Planned layout:

```text
ExeBridge/
├── .github/
│   └── ISSUE_TEMPLATE/
├── assets/             # icons and other project artwork
├── docs/               # architecture and developer documentation
├── src/                # ExeBridge application source
├── tests/              # automated tests
├── CONTRIBUTING.md
├── SECURITY.md
├── README.md
└── .gitignore
```

The application source and installer should be added from the known-working ExeBridge build rather than recreated from guesses. This keeps the public repository aligned with the version that has actually been tested on Fedora/KDE.
