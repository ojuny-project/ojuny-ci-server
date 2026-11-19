#!/usr/bin/env python3
"""Set one assignment in a Nix file from a JSON, string or list value."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


def assignment_end(text: str, start: int) -> int | None:
    depth = 0
    quote = None
    index = start
    while index < len(text):
        char = text[index]
        if quote is not None:
            if char == "\\":
                index += 2
                continue
            if char == quote:
                quote = None
        elif char in ('"', "'"):
            quote = char
        elif char in "([{":
            depth += 1
        elif char in ")]}":
            depth -= 1
        elif char == ";" and depth == 0:
            return index + 1
        index += 1
    return None


def replace_assignment(text: str, option: str, value) -> str:
    pattern = re.compile(r"(?m)^([ \t]*" + re.escape(option) + r"[ \t]*=[ \t]*)")
    match = pattern.search(text)
    if match is None:
        raise SystemExit(f"set-setting: no assignment for {option}")

    end = assignment_end(text, match.end())
    if end is None:
        raise SystemExit(f"set-setting: assignment for {option} has no end")

    literal = json.dumps(value)
    return text[: match.start()] + match.group(1) + literal + ";" + text[end:]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--file", required=True, help="Nix file to edit")
    parser.add_argument("--string", action="store_true", help="treat the value as a string")
    parser.add_argument("--list", action="store_true", help="treat the values as a string list")
    parser.add_argument("option", help="option path to replace")
    parser.add_argument("values", nargs="*", help="new value")
    args = parser.parse_args()

    if args.list:
        value = args.values
    elif args.string:
        if len(args.values) != 1:
            parser.error("--string needs exactly one value")
        value = args.values[0]
    else:
        if len(args.values) != 1:
            parser.error("pass one JSON value")
        value = json.loads(args.values[0])

    path = Path(args.file)
    text = path.read_text(encoding="utf-8")
    path.write_text(replace_assignment(text, args.option, value), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
