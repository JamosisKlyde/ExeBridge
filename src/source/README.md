# Canonical ExeBridge 0.4.0 source

ExeBridge keeps the previously verified 0.3.0 source shards as its immutable base and applies the reviewed deterministic `scripts/patch-0.4.0.py` update to reconstruct the 0.4.0 source.

`assemble-source.sh` verifies both stages:

- Verified 0.3.0 base SHA-256: `1ea9474b55f5c569caa62bf3b3e4294a7cc2d82d824f6885fcdf782a62c0c26a`
- Final 0.4.0 SHA-256: `3aed3ff04b6f43ae79757d0ca88c7a058550566be8caf5ccbfe6ca8f49cdfeae`

To reconstruct the final source from the repository root:

```bash
bash assemble-source.sh
```

The assembler refuses to produce/install the source if either integrity check fails. This keeps release provenance explicit: 0.4.0 is the verified 0.3.0 base plus the multi-distro patch stored in the repository.
