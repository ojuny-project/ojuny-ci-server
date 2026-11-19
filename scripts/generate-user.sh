#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${OJUNY_ROOT:-$PWD}"
SETTER="$REPO_ROOT/scripts/set-setting.py"
SETTINGS="$REPO_ROOT/nixos/settings.nix"

while [ "$#" -gt 0 ]; do
  case "$1" in
  --force) ;;
  --state-version)
    shift
    ;;
  --state-version=*) ;;
  --home-manager | --no-home-manager) ;;
  *)
    echo "generate-user: unknown argument: $1" >&2
    exit 2
    ;;
  esac
  shift
done

if [ ! -f "$SETTINGS" ]; then
  echo "generate-user: $SETTINGS not found" >&2
  exit 1
fi

read -rp "Admin username [admin]: " username
username="${username:-admin}"

read -rsp "Password (empty to leave locked): " password
echo

hashed="!"
if [ -n "$password" ]; then
  if command -v mkpasswd >/dev/null 2>&1; then
    hashed="$(mkpasswd -m yescrypt "$password" 2>/dev/null || mkpasswd -m sha-512 "$password")"
  else
    echo "generate-user: mkpasswd not found" >&2
    exit 1
  fi
fi

keys=()
while true; do
  read -rp "SSH public key (empty to finish): " key
  [ -z "$key" ] && break
  keys+=("$key")
done

python3 "$SETTER" --file "$SETTINGS" --string ci.adminUser "$username"
python3 "$SETTER" --file "$SETTINGS" --string ci.adminHashedPassword "$hashed"
python3 "$SETTER" --file "$SETTINGS" --list ci.ssh.authorizedKeys "${keys[@]}"

echo "generate-user: updated $SETTINGS"
