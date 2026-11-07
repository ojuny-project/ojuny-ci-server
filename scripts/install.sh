#!/usr/bin/env bash
set -euo pipefail

flake="${OJUNY_FLAKE:-$(pwd)}"
host="ci"
target=""
dry_run=0

usage() {
  cat <<'EOF'
Usage: install [options]

Install or update the server from an existing NixOS or Ojuny machine, or from
the workstation with --target.

Options:
  --flake DIR           Server flake (default: the current directory)
  --host NAME           nixosConfigurations name (default: ci)
  --target USER@HOST    Remote target; omit to rebuild locally
  --dry-run             Print the command without running it
  -h, --help            Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --flake) flake="${2:-}"; shift 2 ;;
    --host) host="${2:-}"; shift 2 ;;
    --target) target="${2:-}"; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    -h | --help) usage; exit 0 ;;
    *) echo "install: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ ! -f "$flake/flake.nix" ]; then
  echo "install: no flake.nix in $flake" >&2
  exit 1
fi

if [ "$dry_run" -eq 0 ]; then
  echo
  echo "Ojuny CI server install"
  echo "  flake:  $flake"
  echo "  host:   $host"
  echo "  target: ${target:-local}"
  read -rp "Type INSTALL to continue: " answer
  [ "$answer" = "INSTALL" ] || { echo "install: aborted" >&2; exit 1; }
fi

command=(nixos-rebuild switch --flake "$flake#$host" --sudo)
if [ -n "$target" ]; then
  command+=(--target-host "$target")
fi

if [ "$dry_run" -eq 1 ]; then
  printf '%q ' "${command[@]}"
  echo
  exit 0
fi

"${command[@]}"
