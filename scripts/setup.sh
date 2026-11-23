#!/usr/bin/env bash
set -euo pipefail

default_clone_dir="${OJUNY_CLONE_DIR:-$HOME/repos/ojuny-ci-server}"

printf '\033[2J\033[H'
cat <<'EOF'
Ojuny CI server setup

Fork the template, then enter the URL of your fork.
EOF

read -rp "Git URL of your fork: " fork_url
[ -n "${fork_url:-}" ] || {
  echo "setup: no URL given, aborting" >&2
  exit 1
}

read -rp "Location to clone into [$default_clone_dir]: " answer
clone_dir="${answer:-$default_clone_dir}"
if [ -e "$clone_dir" ]; then
  echo "setup: $clone_dir already exists" >&2
  exit 1
fi

mkdir -p "$(dirname "$clone_dir")"
git clone "$fork_url" "$clone_dir"
export OJUNY_ROOT="$clone_dir"
export OJUNY_CLONE_PATH="$clone_dir"
cd "$clone_dir"

state_version="26.11"

echo "==> generate-user"
generate-user --state-version "$state_version"

read -rp "Hostname [$(uname -n)]: " hostname
hostname="${hostname:-$(uname -n)}"

read -rp "Target disk [/dev/vda]: " disk
disk="${disk:-/dev/vda}"

echo "==> create-new-system"
create-new-system --state-version="$state_version" --hostname="$hostname" --disk="$disk"

git add -A

echo
echo "setup: done. Provision a fresh server with:"
echo "  nix run .#provision -- --target <user>@server"
echo "Or install on an existing machine with:"
echo "  nix run .#install -- --target <user>@server"
