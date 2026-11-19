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


def check_text(name: str, text: str) -> list[str]:
    failures = []
    lines = text.splitlines()
    has_menu = "@menu" in text
    has_option = "@option" in text

    if has_option and not has_menu:
        failures.append(f"{name}: has @option but no @menu")
    if has_menu and not has_option:
        failures.append(f"{name}: has @menu but no @option")
    if has_option and "mkMerge" in text:
        failures.append(f"{name}: @option appears in a file that uses mkMerge")
    if has_option and "optionalAttrs" in text:
        failures.append(f"{name}: @option appears in a file that uses optionalAttrs")
    if has_option and "forEach" in text:
        failures.append(f"{name}: @option appears in a file that uses forEach")
    if has_option and "map (" in text:
        failures.append(f"{name}: @option appears in a file that uses map")

    for index, line in enumerate(lines):
        if "@option" not in line:
            continue
        following = next_meaningful(lines, index + 1)
        if following is None or "=" not in following:
            failures.append(f"{name}:{index + 1}: @option is not followed by an assignment")

    return failures


def self_test() -> None:
    good = """/* @menu displayname = "Test"; */
{ ... }: {
  /* @option widget = "switch"; */
  x = true;
}
"""
    missing_menu = """/* @option widget = "switch"; */
x = true;
"""
    missing_option = """/* @menu displayname = "Test"; */
{ ... }: {
  x = true;
}
"""
    merged = """/* @menu displayname = "Test"; */
{ ... }: {
  /* @option widget = "switch"; */
  x = lib.mkMerge [ true ];
}
"""
    dangling = """/* @menu displayname = "Test"; */
{ ... }: {
  /* @option widget = "switch"; */
  # no assignment follows
}
"""

    cases = (
        ("good.nix", good, None),
        ("missing-menu.nix", missing_menu, "has @option but no @menu"),
        ("missing-option.nix", missing_option, "has @menu but no @option"),
        ("merged.nix", merged, "uses mkMerge"),
        ("dangling.nix", dangling, "not followed by an assignment"),
    )

    for name, text, expected in cases:
        failures = check_text(name, text)
        if expected is None:
            if failures:
                raise RuntimeError(f"self-test {name} should pass: {failures}")
        elif not any(expected in failure for failure in failures):
            raise RuntimeError(f"self-test {name} should report {expected}: {failures}")


def main(argv: list[str]) -> int:
    roots = [Path(arg) for arg in argv[1:]] or [Path("modules")]
    failures = []

    try:
        self_test()
    except RuntimeError as error:
        print(f"check-menu-coverage: {error}", file=sys.stderr)
        return 1

    for root in roots:
        for path in sorted(root.glob("*.nix")):
            failures.extend(check_text(str(path), path.read_text(encoding="utf-8")))

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print("options-coverage: ok")
    print("check-menu-coverage: ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
