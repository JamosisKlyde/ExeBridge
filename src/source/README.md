# Canonical ExeBridge 0.6.0 source

The canonical ExeBridge 0.6.0 Python sources are stored as gzip-compressed, Base64-encoded text shards so the repository can preserve the exact bytes while remaining text-only.

`assemble-source.sh` reconstructs and verifies all three application source files:

- `exebridge.py` SHA-256: `cb4139e71d3beec9ae79d26516082124c681da7699e43e25ee821a51f8ca415a`
- `updater.py` SHA-256: `3ac90db850b164436ee621e503819e3fe0a3c694be54fa1167b6b19837f7de7b`
- `webview2_helper.py` SHA-256: `3cebf6d05ea76e31ebeeab34973baeff227bd28470c05797491f9f3f93e25327`

The six `exebridge.py.gz.b64.part-*` files, two `updater.py.gz.b64.part-*` files, and two `webview2_helper.py.gz.b64.part-*` files must each be treated as one complete source artifact. Do not edit an individual shard directly; reconstruct, modify, compile/test, recompress, then replace the complete shard set and update the expected hashes.
