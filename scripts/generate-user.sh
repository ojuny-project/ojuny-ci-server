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

if [[ ! "$username" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]; then
  echo "generate-user: invalid username: $username" >&2
  exit 2
fi

read -rsp "Password (empty to leave locked): " password
echo

hashed="!"
if [ -n "$password" ]; then
  if command -v mkpasswd ; then
    hashed="$(mkpasswd -m yescrypt "$password"  || mkpasswd -m sha-512 "$password")"
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

mkdir -p "$REPO_ROOT/modules"
cat >"$REPO_ROOT/modules/00-user.nix" <<EOF
{ ... }:

{
  flake.modules.nixos.users = {
    users.users = {
      $username = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
    };
  };
}
EOF

if [ -n "$password" ]; then
  python3 "$SETTER" --file "$SETTINGS" --string ci.adminHashedPassword "$hashed"
fi

if [ "${#keys[@]}" -gt 0 ]; then
  python3 "$SETTER" --file "$SETTINGS" --list ci.ssh.authorizedKeys "${keys[@]}"
fi

echo "generate-user: updated $REPO_ROOT/modules/00-user.nix and $SETTINGS"
