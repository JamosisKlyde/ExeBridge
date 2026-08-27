# Canonical ExeBridge 0.4.0 source

The canonical `exebridge.py` for ExeBridge 0.4.0 is stored here as gzip-compressed, Base64-encoded text shards so the GitHub text connector can preserve the source bytes exactly.

The installer handles reconstruction automatically. To reconstruct it manually from the repository root:

```bash
bash assemble-source.sh
```

Expected SHA-256 for the reconstructed `exebridge.py`:

```text
003140c03e5a2aa4203c42547c18a3a62545b6ee7560606d27cb932d8b88a389
```

`assemble-source.sh` refuses to install the reconstructed source if this checksum does not match.

The five `part-*` files must be treated as one source artifact. Do not edit a shard directly. Reconstruct `exebridge.py`, make the intended source changes, compile/test it, regenerate all shards, and update the expected checksum.
