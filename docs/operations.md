# Operations

## Upgrade

```console
$ nix flake update
$ nix run .#install -- --target root@server
```

The server is a rolling flake. The lock is the snapshot.

## Rollback

NixOS generations are complete bootable systems. Select an older generation at
the bootloader, or:

```console
$ sudo nixos-rebuild switch --rollback
```

## Backups

Back up:

- the flake repository and its lock
- the Hydra PostgreSQL database
- the artifacts path, if it is not already on redundant storage

Do not back up the Nix store. It is reproducible from the flake.

Example database backup:

```console
$ sudo -u postgres pg_dump hydra > hydra-$(date +%F).sql
```

Restore into an empty database before starting Hydra.

## Garbage collection

`nix.gc` runs weekly and deletes generations older than 30 days. Adjust it in
`modules/system.nix` if the ISO jobs need a longer window.

## Logs

```console
$ journalctl -u hydra -u hydra-queue-runner -u ojuny-ci-jobsets
$ journalctl -u nix-cache-discovery
```

## Health checks

- `systemctl status hydra`
- `systemctl status nix-cache-discovery`
- `systemctl status ojuny-ci-jobsets`
- `curl http://<host>:3000`
- `curl http://<host>:5055/nix-cache-info`

## Restore

1. Reinstall the same flake.
2. Restore the Hydra database.
3. Restore the artifacts path.
4. Rebuild and reboot.

The jobset is regenerated from the flake on boot.
