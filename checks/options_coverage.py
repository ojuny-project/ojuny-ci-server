#!/usr/bin/env python3
"""Check that annotated options use a GUI-supported module shape."""

from __future__ import annotations

import sys
from pathlib import Path


def next_meaningful(lines: list[str], start: int) -> str | None:
    for line in lines[start:]:
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or stripped.startswith("//"):
            continue
        return stripped
    return None


def main(argv: list[str]) -> int:
    root = Path(argv[1])
    failures = []

    for path in sorted(root.glob("*.nix")):
        text = path.read_text(encoding="utf-8")
        lines = text.splitlines()
        has_menu = "@menu" in text
        has_option = "@option" in text

        if has_menu and not has_option:
            failures.append(f"{path.name}: has @menu but no @option")
        if has_option and "mkMerge" in text:
            failures.append(f"{path.name}: @option appears in a file that uses mkMerge")
        if has_option and "optionalAttrs" in text:
            failures.append(f"{path.name}: @option appears in a file that uses optionalAttrs")
        if has_option and "forEach" in text:
            failures.append(f"{path.name}: @option appears in a file that uses forEach")
        if has_option and "map (" in text:
            failures.append(f"{path.name}: @option appears in a file that uses map")

        for index, line in enumerate(lines):
            if "@option" not in line:
                continue
            following = next_meaningful(lines, index + 1)
            if following is None or "=" not in following:
                failures.append(f"{path.name}:{index + 1}: @option is not followed by an assignment")

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print("options-coverage: ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
