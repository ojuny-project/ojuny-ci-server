#!/usr/bin/env python3
"""Validate the generated Ojuny Hydra jobset JSON."""

from __future__ import annotations

import json
import sys
from pathlib import Path


def main(argv: list[str]) -> int:
    path = Path(argv[1])
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or not data:
        print("jobsets must be a non-empty object", file=sys.stderr)
        return 1

    failures = []
    for name, jobset in data.items():
        if not isinstance(jobset, dict):
            failures.append(f"{name}: not an object")
            continue
        if jobset.get("type") != 1:
            failures.append(f"{name}: type must be 1 for a flake jobset")
        if not isinstance(jobset.get("flake"), str) or not jobset["flake"].startswith("git+"):
            failures.append(f"{name}: flake must start with git+")
        if jobset.get("enabled") not in (0, 1):
            failures.append(f"{name}: enabled must be 0 or 1")
        if not isinstance(jobset.get("description"), str):
            failures.append(f"{name}: description must be a string")
        if not isinstance(jobset.get("checkinterval"), int):
            failures.append(f"{name}: checkinterval must be an integer")

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print(f"jobsets-schema: {len(data)} jobset(s) ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
