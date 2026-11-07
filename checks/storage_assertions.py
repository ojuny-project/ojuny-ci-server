#!/usr/bin/env python3
"""Reject network filesystems on paths that must stay local."""

from __future__ import annotations

import json
import sys
from pathlib import Path

RESERVED = {"/nix", "/var/lib/postgresql", "/var/lib/hydra"}
NETWORK = {"nfs", "nfs4", "cifs", "smb3", "glusterfs", "ceph", "9p"}


def main(argv: list[str]) -> int:
    mounts = json.loads(Path(argv[1]).read_text(encoding="utf-8"))
    if not isinstance(mounts, list):
        print("mounts must be a list", file=sys.stderr)
        return 1

    failures = []
    for mount in mounts:
        if not isinstance(mount, dict):
            failures.append("mount entry is not an object")
            continue
        if not mount.get("enable", True):
            continue
        path = mount.get("path", "")
        fs_type = mount.get("fsType", "")
        if path in RESERVED and fs_type in NETWORK:
            failures.append(f"{path} uses {fs_type}; local block storage is required")

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print("storage-assertions: ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
