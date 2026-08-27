# Canonical ExeBridge 0.3.0 source

The exact tested `exebridge.py` from the ExeBridge 0.3.0 release is stored here as gzip-compressed, Base64-encoded text shards so GitHub's text-only connector can preserve the original bytes exactly.

The installer handles reconstruction automatically. To reconstruct it manually from the repository root:

```bash
bash assemble-source.sh
```

Expected SHA-256 for the reconstructed `exebridge.py`:

```text
1ea9474b55f5c569caa62bf3b3e4294a7cc2d82d824f6885fcdf782a62c0c26a
```

`assemble-source.sh` refuses to install the reconstructed source if this checksum does not match.

The four `part-*` files should be treated as one source artifact. Do not edit an individual shard directly; reconstruct `exebridge.py`, make the intended source changes, then regenerate the compressed shards and update the expected checksum.
