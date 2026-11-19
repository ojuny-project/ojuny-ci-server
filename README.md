# ojuny-ci-server

A self-hostable, headless CI server for Ojuny. It runs Hydra and
`nix-cache-discovery` on one NixOS host. Configure it with `nix-settings-gui` on
your workstation, then provision or update the server.

## What it provides

- Hydra with a declarative jobset generated from the flake settings
- `nix-cache-discovery` for the server store and LAN peers
- PostgreSQL for Hydra
- Optional extra filesystems for artifacts, release staging and archival
- Optional remote builders
- `nixos-anywhere`, existing-device and Proxmox install paths

The server has no graphical interface. The settings GUI runs on your
workstation and edits this flake. A web GUI or SSH proxy is out of scope.

## Deploy methods

This repository follows the Ojuny template shape, so the standard install and
deploy surfaces work for it.

- `nix run .#setup` clones a fork and writes the account, hostname and disk
  settings.
- `nix run .#remote-setup -- --target root@server` updates a running NixOS or
  Ojuny machine over SSH with deploy-rs.
- `nix run .#remote-install -- --target root@server --disk /dev/vda` prepares a
  disko repository and installs a fresh machine with nixos-anywhere.
- `nix run .#prepare-remote-repository -- --disk /dev/vda` writes a prepared
  repository for a later remote install.
- `nix run .#check` runs the template check.

The Calamares installer and the CLI installer find the configuration through
`flake.modules.nixos.system-configuration`, `users`, `host-imports`,
`system-hardware` and `system-bootloader`, so either installer ISO can install
this template.

## CI repositories

The standard jobset list is in `lib/jobsets.nix`. Set `ci.git.username` to your
own account or organization to test forks of the standard repositories, or add
a row to `ci.jobs.extraRepositories` to test any other repository and revision.

## Quickstart

1. Install `nix-settings-gui` on the workstation.
2. Open this flake and set `ci.git.username` to your Git user or organization.
3. Set `ci.ssh.authorizedKeys`.
4. Set `ci.hydra.adminPasswordHash` to an Argon2id hash.
5. Optionally add `ci.jobs.extraRepositories` rows for forks and test branches.
6. Save the flake.
7. Provision a fresh server:

```console
$ nix run .#provision -- --target root@server
```

Or install on an existing NixOS or Ojuny device:

```console
$ nix run .#install -- --target root@server
```

## Requirements

- Nix with flakes enabled.
- A trusted LAN. Hydra and the cache are LAN-only by default.
- KVM on the server for VM tests.
- Enough disk for the ISO jobs if they are enabled.

## Documentation

- [docs/pre-deployment.md](docs/pre-deployment.md): the checklist before the first deployment
- [docs/setup.md](docs/setup.md): provisioning, existing-device install and Proxmox
- [docs/settings.md](docs/settings.md): the workstation settings workflow
- [docs/jobs.md](docs/jobs.md): job groups, repo overrides and the jobset
- [docs/cache.md](docs/cache.md): cache URL, discovery and trust
- [docs/storage.md](docs/storage.md): local, GlusterFS, NFS and SMB
- [docs/operations.md](docs/operations.md): upgrades, backups and restore
- [docs/sizing.md](docs/sizing.md): hardware guidance
- [docs/security.md](docs/security.md): firewall, admin and public exposure
- [docs/troubleshooting.md](docs/troubleshooting.md): common failures
- [docs/heavy-testing.md](docs/heavy-testing.md): tests that need hardware

## Support

- Issues: <https://github.com/ojuny-project/ojuny-ci-server/issues>
- Contributing: [CONTRIBUTING.md](CONTRIBUTING.md)
- Security: [SECURITY.md](SECURITY.md)

