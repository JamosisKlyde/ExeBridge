# Canonical ExeBridge 0.5.1 source

The canonical ExeBridge 0.5.1 Python sources are stored as gzip-compressed, Base64-encoded text shards so the repository can preserve the exact bytes while remaining text-only.

`assemble-source.sh` reconstructs and verifies both files:

- `exebridge.py` SHA-256: `129ecf05ddd13c7414b0a9a51c739702a96c691e403db963844837dcd8cef8dd`
- `updater.py` SHA-256: `64932bb59413e59b4cf9a4db7b5bde420cd9d4a692f7272934ae4558c07b360c`

The five `exebridge.py.gz.b64.part-*` files and two `updater.py.gz.b64.part-*` files must each be treated as one source artifact. Do not edit an individual shard directly; reconstruct, modify, compile/test, recompress, then replace the complete shard set and update the expected hashes.
