# Storage

## Default

The server works on a single disk. Artifacts live under
`ci.storage.artifactsPath`, default `/var/lib/ojuny-ci/artifacts`.

The Nix store and PostgreSQL stay on local block storage.

## Extra mounts

Add optional filesystems with `ci.storage.mounts`. The table has `path`,
`device`, `fsType`, `options` and `enable`. Options are space-separated.

## GlusterFS

```nix
ci.storage.mounts = [
  {
    path = "/var/lib/ojuny-ci/artifacts";
    device = "gluster1:/ojuny-artifacts";
    fsType = "glusterfs";
    options = "defaults,_netdev";
    enable = true;
  }
];
```

## NFS

```nix
ci.storage.mounts = [
  {
    path = "/var/lib/ojuny-ci/artifacts";
    device = "nas.lan:/export/ojuny-artifacts";
    fsType = "nfs4";
    options = "defaults,_netdev,soft,timeo=100";
    enable = true;
  }
];
```

## SMB

```nix
ci.storage.mounts = [
  {
    path = "/var/lib/ojuny-ci/artifacts";
    device = "//nas.lan/ojuny-artifacts";
    fsType = "cifs";
    options = "credentials=/var/lib/ojuny-ci/smb.credentials,uid=1000,gid=100,_netdev";
    enable = true;
  }
];
```

## Reserved paths

The module rejects network filesystems on `/nix`, `/var/lib/postgresql` and
`/var/lib/hydra`. They must remain on local block storage.

## Local data disks

A second local disk can be mounted through the same table:

```nix
ci.storage.mounts = [
  {
    path = "/var/lib/ojuny-ci/artifacts";
    device = "/dev/vdb1";
    fsType = "ext4";
    options = "defaults";
    enable = true;
  }
];
```

## Sizing

See [sizing.md](sizing.md).
