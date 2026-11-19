#!/usr/bin/env python3
"""Validate the generated Ojuny Hydra jobset JSON."""

from __future__ import annotations

import json
import sys
from pathlib import Path

FLAKE_PREFIXES = (
    "git+",
    "github:",
    "gitlab:",
    "sourcehut:",
    "path:",
    "file:",
    "http://",
    "https://",
)


def main(argv: list[str]) -> int:
    path = Path(argv[1])
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or not data:
        print("jobsets must be a non-empty object", file=sys.stderr)
        return 1

    groups = None
    if len(argv) > 2:
        groups = set(json.loads(Path(argv[2]).read_text(encoding="utf-8")))

    failures = []
    for name, jobset in data.items():
        if not isinstance(jobset, dict):
            failures.append(f"{name}: not an object")
            continue
        if not name:
            failures.append("jobset name must not be empty")
        if jobset.get("type") != 1:
            failures.append(f"{name}: type must be 1 for a flake jobset")
        flake = jobset.get("flake")
        if not isinstance(flake, str) or not flake.startswith(FLAKE_PREFIXES):
            failures.append(f"{name}: flake must be a flake ref or git URL")
        if jobset.get("enabled") not in (0, 1):
            failures.append(f"{name}: enabled must be 0 or 1")
        if not isinstance(jobset.get("description"), str):
            failures.append(f"{name}: description must be a string")
        if not isinstance(jobset.get("checkinterval"), int):
            failures.append(f"{name}: checkinterval must be an integer")
        if groups is not None and not any(name.startswith(group + "-") for group in groups):
            failures.append(
                f"{name}: name must start with one of: {', '.join(sorted(groups))}"
            )

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print(f"jobsets-schema: {len(data)} jobset(s) ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
