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
store all grow. `ci.hydra.minimumDiskFree` stops the queue runner and
`ci.hydra.minimumDiskFreeEvaluator` stops the evaluator when the store is low.
The builder also has percentage store and build-dir thresholds.

## Dynamic sizing

The builder is not sized for one machine. `buildCores = 0` gives each build every
local core, `nix.settings.max-jobs = "auto"` and `cores = 0` use the local core
count, and `machineFreeFn = Dynamic` admits jobs from CPU and memory PSI.
`ci.hydra.maxOutputSize = 0` disables the per-output cap. The same closure works
on a small host and on a large one without a rebuild.

PSI must be available (`/proc/pressure`). Without it, the builder falls back to
`load1Threshold`, which does not scale with core count.
