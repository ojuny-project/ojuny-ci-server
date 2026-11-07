#!/usr/bin/env bash
set -euo pipefail

flake="${OJUNY_FLAKE:-$(pwd)}"
host="ci"
output="${OJUNY_IMAGE_OUT:-result}"
dry_run=0

usage() {
  cat <<'EOF'
Usage: proxmox-image [options]

Build a Proxmox image from the server flake.

Options:
  --flake DIR           Server flake (default: the current directory)
  --host NAME           nixosConfigurations name (default: ci)
  --output PATH         Output path (default: result)
  --dry-run             Print the command without running it
  -h, --help            Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --flake) flake="${2:-}"; shift 2 ;;
    --host) host="${2:-}"; shift 2 ;;
    --output) output="${2:-}"; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    -h | --help) usage; exit 0 ;;
    *) echo "proxmox-image: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ ! -f "$flake/flake.nix" ]; then
  echo "proxmox-image: no flake.nix in $flake" >&2
  exit 1
fi

command=(nixos-generate -f proxmox -c "$host" --flake "$flake" -o "$output")

if [ "$dry_run" -eq 1 ]; then
  printf '%q ' "${command[@]}"
  echo
  exit 0
fi

"${command[@]}"
