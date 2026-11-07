# Troubleshooting

## Hydra does not start

```console
$ systemctl status hydra
$ journalctl -u hydra -u postgresql
```

Check that PostgreSQL is running and that the Hydra database exists.

## The jobset does not appear

```console
$ systemctl status ojuny-ci-jobsets
$ journalctl -u ojuny-ci-jobsets
```

The service creates the admin user, the `ojuny` project and the declarative
jobset. A failing `hydra-create-user` is a warning; a failing `psql` or
`hydra-prepare-declarative-jobset` is an error.

## The jobset is stale

The timer runs daily. Trigger it manually:

```console
$ sudo systemctl start ojuny-ci-jobsets
```

## Cache is not discovered

- Check `ci.cache.port` is the same on every host.
- Check the hosts are on the same subnet or in `ci.cache.discovery.ranges`.
- Check the firewall on `ci.network.interface`.
- `curl http://<host>:5055/nix-cache-info` from a peer.

## A mount fails

- Check `device`, `fsType` and `options`.
- Network filesystems need `_netdev`.
- The module rejects network filesystems on `/nix` and PostgreSQL.

## Settings do not appear in the GUI

The `@option` comment must sit above an assignment in a plain attribute set or a
`lib.mkIf` set. It cannot be inside `lib.mkMerge`, a list, `map` or `forEach`.
The `options-coverage` check catches this.

## Provision fails

- Check SSH access to the target.
- Check the disk name.
- Use `--dry-run` to print the command.
- Check `nixos-anywhere` output for the failing phase.
