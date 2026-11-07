# Sizing

## Minimum

- 4 CPU cores
- 16 GiB RAM
- 256 GiB local SSD
- wired LAN

This is enough for the fast and Nix checks and a small VM test set.

## Recommended

- 8 or more CPU cores
- 32 GiB RAM or more
- 1 TiB NVMe local storage
- wired LAN with a local cache peer

The ISO jobs are the disk-heavy part. The offline ISOs are several gigabytes
each and the build also needs store space for the closure.

## VM tests and acceptance

VM tests need KVM and enough RAM for the guest or guests. Acceptance runs a
graphical VM and is the heaviest single job.

## Network

- Hydra and the cache are LAN-only by default.
- A remote builder needs SSH from the server.
- A public Hydra needs a reverse proxy and TLS, which are out of scope.

## Disk reserve

Keep at least 20 percent free on the local disk. Hydra, PostgreSQL and the Nix
store all grow. Set `ci.hydra.maxOutputSize` and `nix.gc` to match the disk.
