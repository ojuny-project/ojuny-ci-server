#!/usr/bin/env bash
set -euo pipefail

target=""
flake="${OJUNY_FLAKE:-$(pwd)}"
host="ci"
disk=""
dry_run=0

usage() {
  cat <<'EOF'
Usage: provision [options]

Provision a fresh server with nixos-anywhere. Run this on the workstation.

The target disk comes from ci.disk.device in the flake. --disk only confirms it.

Options:
  --target USER@HOST    SSH target (required)
  --flake DIR           Server flake (default: the current directory)
  --host NAME           nixosConfigurations name (default: ci)
  --disk DEVICE         Confirm the target disk
  --dry-run             Print the command without running it
  -h, --help            Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target) target="${2:-}"; shift 2 ;;
    --flake) flake="${2:-}"; shift 2 ;;
    --host) host="${2:-}"; shift 2 ;;
    --disk) disk="${2:-}"; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    -h | --help) usage; exit 0 ;;
    *) echo "provision: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ ! -f "$flake/flake.nix" ]; then
  echo "provision: no flake.nix in $flake" >&2
  exit 1
fi

if [ -z "$target" ]; then
  read -rp "SSH target (user@host): " target
fi
if [ -z "$target" ]; then
  echo "provision: --target is required" >&2
  exit 2
fi

flake_disk="$(nix eval --raw "path:$flake#nixosConfigurations.$host.config.ci.disk.device")"
keys_json="$(nix eval --json "path:$flake#nixosConfigurations.$host.config.ci.ssh.authorizedKeys")"
real_keys="$(printf '%s' "$keys_json" | jq 'map(select(startswith("#") | not)) | length')"
if [ "$real_keys" -eq 0 ]; then
  echo "provision: set at least one real SSH key in ci.ssh.authorizedKeys" >&2
  exit 1
fi

hydra_hash="$(nix eval --raw "path:$flake#nixosConfigurations.$host.config.ci.hydra.adminPasswordHash")"
if [ "$hydra_hash" = "!" ]; then
  echo "provision: warning: the Hydra admin password is locked; set ci.hydra.adminPasswordHash" >&2
fi

if [ -z "$disk" ]; then
  disk="$flake_disk"
elif [ "$disk" != "$flake_disk" ]; then
  echo "provision: --disk $disk does not match ci.disk.device $flake_disk" >&2
  echo "provision: set ci.disk.device in the settings GUI and retry" >&2
  exit 1
fi

if [ "$dry_run" -eq 0 ]; then
  echo
  echo "Ojuny CI server provision"
  echo "  flake:     $flake"
  echo "  host:      $host"
  echo "  target:    $target"
  echo "  disk:      $disk (ci.disk.device)"
  echo
  echo "This destroys the target disk and installs the server."
  read -rp "Type PROVISION to continue: " answer
  [ "$answer" = "PROVISION" ] || { echo "provision: aborted" >&2; exit 1; }
fi

command=(
  "${OJUNY_NIXOS_ANYWHERE:?OJUNY_NIXOS_ANYWHERE is not set}"
  --flake "$flake#$host"
  --target-host "$target"
  --build-on remote
)

if [ "$dry_run" -eq 1 ]; then
  printf '%q ' "${command[@]}"
  echo
  exit 0
fi

"${command[@]}"
