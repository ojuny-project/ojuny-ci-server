#!/usr/bin/env python3
"""Check that this repository is a valid Ojuny template."""

import argparse
import json
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import flake_structure

REQUIRED_MODULES = (
    "host-imports",
    "system-configuration",
    "system-hardware",
    "system-bootloader",
    "users",
)

REQUIRED_FILES = (
    "flake.nix",
    "scripts/setup.sh",
    "scripts/generate-hw.sh",
    "scripts/generate-user.sh",
    "scripts/create-new-system.sh",
    "scripts/flake_structure.py",
)


def fail(message):
    print("invalid template: " + message, file=sys.stderr)
    return 1


def run_nix(root, args):
    command = [
        "nix",
        "--extra-experimental-features",
        "nix-command flakes",
        "eval",
    ] + args
    return subprocess.run(
        command,
        cwd=root,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".", help="template repository root")
    parser.add_argument("--static", action="store_true", help="skip Nix evaluation")
    parser.add_argument(
        "--system",
        action="store_true",
        help="also evaluate the system toplevel; requires generated hardware",
    )
    args = parser.parse_args()
    root = Path(args.root).resolve()

    for name in REQUIRED_FILES:
        if not (root / name).is_file():
            return fail("missing " + name)

    found = {
        name: flake_structure.find_modules(root, name) for name in REQUIRED_MODULES
    }
    for name, paths in found.items():
        if not paths:
            return fail("no file declares flake.modules.nixos." + name)

    hosts = flake_structure.find_hosts(root)
    if not hosts:
        return fail("no flake.nixosConfigurations host")

    if not args.static:
        flake = json.dumps("path:" + str(root))
        result = run_nix(
            root,
            [
                "--json",
                "--impure",
                "--expr",
                "builtins.attrNames (builtins.getFlake {}).nixosConfigurations".format(
                    flake
                ),
            ],
        )
        if result.returncode != 0:
            return fail("nix evaluation failed:\n" + result.stderr.strip())
        try:
            evaluated = json.loads(result.stdout)
        except ValueError:
            return fail("nix returned an invalid host list")
        if not evaluated:
            return fail("nix evaluated no nixosConfigurations")
        host = evaluated[0]
        if args.system:
            result = run_nix(
                root,
                [
                    "--raw",
                    "--impure",
                    "--expr",
                    '(builtins.getFlake {}).nixosConfigurations.{}.config.system.build.toplevel.drvPath'.format(
                        flake, host
                    ),
                ],
            )
            if result.returncode != 0:
                return fail(
                    "system evaluation failed for {}:\n{}".format(
                        host, result.stderr.strip()
                    )
                )

    print(
        "valid template: {} host(s), {} required module(s)".format(
            len(hosts), len(REQUIRED_MODULES)
        )
    )
    for name in REQUIRED_MODULES:
        print("  {}: {}".format(name, found[name][0]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
