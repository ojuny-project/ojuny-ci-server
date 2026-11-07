# Heavy testing

These tests need hardware, KVM or a network environment. They are not run in
the static verification pass.

1. Build the server:

```console
$ nix build .#nixosConfigurations.ci.config.system.build.toplevel
```

2. Provision a VM with `apps.provision` and boot it.
3. Confirm Hydra starts and the `ojuny` project exists.
4. Confirm `ojuny-ci-jobsets` creates the declarative jobset.
5. Change `ci.git.username`, rebuild, and confirm the jobset updates.
6. Run one Hydra job and confirm the build and cache.
7. Discover the cache from a second host.
8. Test local disk, GlusterFS, NFS and SMB mounts.
9. Confirm a network filesystem on `/nix` is rejected.
10. Build the Proxmox image and boot it.
11. Build `nixosConfigurations.ci-aarch64`.
12. Log in as the Hydra administrator.
13. Back up and restore the Hydra database.
14. Test a remote builder.
15. Enable the ISO, acceptance and reproducibility groups one at a time.

Record the results in the release notes and the server README.
