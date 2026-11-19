#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${OJUNY_ROOT:-$PWD}"
SETTER="$REPO_ROOT/scripts/set-setting.py"
SETTINGS="$REPO_ROOT/nixos/settings.nix"
DISK="$REPO_ROOT/nixos/disk.nix"
SYSTEM="$REPO_ROOT/modules/00-system.nix"

state_version="26.11"
hostname=""
disk="/dev/vda"

for arg in "$@"; do
  case "$arg" in
  --force) ;;
  --state-version=*) state_version="${arg#*=}" ;;
  --hostname=*) hostname="${arg#*=}" ;;
  --disk=*) disk="${arg#*=}" ;;
  *)
    echo "create-new-system: unknown argument: $arg" >&2
    exit 2
    ;;
  esac
done

if [ -z "$hostname" ]; then
  read -rp "Hostname [ci]: " hostname
fi
hostname="${hostname:-ci}"

python3 "$SETTER" --file "$SETTINGS" --string ci.hostName "$hostname"
python3 "$SETTER" --file "$DISK" --string ci.disk.device "$disk"
python3 "$SETTER" --file "$SYSTEM" --string system.stateVersion "$state_version"

echo "create-new-system: set ci.hostName=$hostname and system.stateVersion=$state_version"
