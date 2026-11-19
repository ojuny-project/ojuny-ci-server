# Setup

## Workstation prerequisites

- Nix with `nix-command` and `flakes`.
- `nix-settings-gui` for editing the flake.
- SSH access to the target.
- The target disk name for a fresh install.

## Setup app

Fork the repository, then run the setup app from the upstream flake:

```console
$ nix run .#setup
```

The app clones the fork, writes the admin account and SSH keys, sets the
hostname and target disk, and prints the provision and install commands.

## Pin the inputs

The repository tracks `flake.lock`. Update it on a fork with:

```console
$ nix flake update
```


## Edit the settings

Open this directory in `nix-settings-gui` on the workstation. The pages are
generated from the `@menu` and `@option` comments in `nixos/`.

At minimum set:

- `ci.git.username`
- `ci.ssh.authorizedKeys`
- `ci.hydra.adminPasswordHash`
- `ci.hostName` and `ci.network.interface`

See [settings.md](settings.md).

## Fresh server with nixos-anywhere

The target disk comes from `ci.disk.device` in the flake. Set it in the
settings GUI. The `--disk` option only confirms it; a mismatch aborts.

```console
$ nix run .#provision -- --target root@server
```

The script shows the target and disk, requires `PROVISION`, and then runs
`nixos-anywhere`. Use `--dry-run` to print the command first.

The target disk is destroyed.

## Existing NixOS or Ojuny device

From the device or from the workstation:

```console
$ nix run .#install -- --target root@server
```

The script requires `INSTALL` and runs `nixos-rebuild switch --flake .#ci`.

## Remote deploy

Update a machine that already runs NixOS or Ojuny over SSH:

```console
$ nix run .#remote-setup -- --target root@server
```

Install a fresh machine without the ISO:

```console
$ nix run .#remote-install -- --target root@server --disk /dev/vda
```

`remote-install` prepares a disko repository with
`prepare-remote-repository` first. Both apps are the standard Ojuny deploy
apps, so the same commands work on the other Ojuny templates.

## Proxmox image

```console
$ nix run .#proxmox-image -- --output result
```

Import the image into Proxmox and boot it. The image uses the same disk layout
and settings.

## First boot

1. SSH in with the configured key.
2. Check `systemctl status hydra` and `systemctl status nix-cache-discovery`.
3. Open `http://<host>:3000` from the LAN.
4. Check `systemctl status ojuny-ci-jobsets`.
5. Confirm the `ojuny` project and its jobset exist in Hydra.

## Upgrades and rollback

```console
$ nix flake update
$ nix run .#install -- --target root@server
```

Rollback uses the NixOS generation list at boot. See
[operations.md](operations.md).
