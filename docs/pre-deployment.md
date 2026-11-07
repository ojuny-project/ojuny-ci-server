# Pre-deployment checklist

Run this on the workstation before provisioning.

## 1. Pin the inputs

```console
$ nix flake lock
```

This creates `flake.lock`. Commit it.

## 2. Set the required settings

Open the flake in `nix-settings-gui` and set:

- `ci.git.username` to your Git user or organization
- `ci.ssh.authorizedKeys` to at least one real key. The template contains a
  comment placeholder; NixOS accepts it, but you cannot log in with it.
- `ci.hydra.adminPasswordHash` to an Argon2id hash. The template value is
  locked.
- `ci.network.interface` to the real interface name
- `ci.disk.device` to the target disk
- `ci.hostName` if the default is not suitable

Optional:

- `ci.git.repositories` if a repository name differs
- `ci.storage.mounts` for extra local or network filesystems
- `ci.builders` for remote builders

## 3. Evaluate the flake

```console
$ nix flake check
```

If this fails, fix the evaluation before provisioning. The likely causes are:

- a setting that points at a missing package or option
- an interface name that conflicts with the network module
- a mount that the storage assertion rejects

## 4. Build the server

```console
$ nix build .#nixosConfigurations.ci.config.system.build.toplevel
```

This is the strongest local proof that the system evaluates and builds. It is
the first thing to run when server access returns.

## 5. Dry-run the deployment

```console
$ nix run .#provision -- --target root@server --dry-run
```

Confirm the flake, host, target and disk. The disk must match
`ci.disk.device`.

## 6. Provision

```console
$ nix run .#provision -- --target root@server
```

## 7. First boot

```console
$ ssh root@server
$ systemctl status hydra hydra-queue-runner nix-cache-discovery ojuny-ci-jobsets
$ curl http://127.0.0.1:3000
$ curl http://127.0.0.1:5055/nix-cache-info
```

## 8. Jobset

Check the `ojuny` project in Hydra. If the jobset is missing:

```console
$ sudo systemctl start ojuny-ci-jobsets
$ journalctl -u ojuny-ci-jobsets
```

## Known unverified paths

These are implemented but not runtime-tested:

- `hydra-create-user`, `psql` and `hydra-prepare-declarative-jobset` in
  `ojuny-ci-jobsets.service`
- the jobset grouping and `hydraJobs` evaluation
- the disko layout on the target disk
- the Proxmox image
- the aarch64 configuration
- cache discovery from a second host
- network filesystem mounts and remote builders

They are not blockers for a first deployment except where the checklist above
fails.
