# Jobs

The jobset is generated from `ci.jobs.*` and the repository list.

## Groups

- `ci.jobs.checks`: the fast and Nix checks
- `ci.jobs.vmTests`: VM tests
- `ci.jobs.isos`: ISO builds
- `ci.jobs.persistentImage`: the persistent image
- `ci.jobs.reproducibility`: reproducibility rebuilds
- `ci.jobs.acceptance`: acceptance runs
- `ci.jobs.installReport`: the install report

Defaults: checks, VM tests and install report on. ISO, persistent image,
reproducibility and acceptance off.

## Repository list

The standard list is in `lib/jobsets.nix`. It includes the Ojuny product
repositories and `ojuny-ci-server`.

Each jobset points at a flake and uses its `hydraJobs` output. The jobset name
is `<group>-<repository>`.

## Repository overrides

Override a name without changing the list:

```nix
ci.git.repositories = {
  "ojuny-template" = {
    name = "my-template";
  };
};
```

## Upsert

`ojuny-ci-jobsets.service` runs after Hydra and PostgreSQL. It:

1. creates or updates the Hydra administrator,
2. ensures the `ojuny` project exists,
3. applies the declarative jobset with
   `hydra-prepare-declarative-jobset`.

The same service runs daily from `ojuny-ci-jobsets.timer`, so a settings
change is picked up without a reboot. The service is a oneshot that exits after
the upsert, so both the timer and `systemctl start` can run it again.

Inspect the generated jobset without a server:

```console
$ nix build .#packages.x86_64-linux.jobsets-json
$ nix store cat result
```

## Builders

The server runs one local `hydra-builder`. It uses `buildCores = 0`, so each
build gets every local core, and the queue runner uses `Dynamic` admission, so
CPU and memory PSI decide how many jobs run. `ci.hydra.maxJobs = 0` means no
cap. A positive value switches to `DynamicWithMaxJobLimit`.

Remote builders are not configured on the server. A builder host runs
`services.hydra-builder` with `queueRunnerAddr` pointing at the queue runner
gRPC endpoint. Provisioning those hosts belongs to the new remote-deploy
method.

## Extra repositories

Add a repository outside the standard list with `ci.jobs.extraRepositories`.
Each row names the repository, gives its flake ref or Git URL, optionally names
a branch or revision, and lists the job groups:

```nix
ci.jobs.extraRepositories = [
  {
    name = "my-ojuny-template";
    url = "github:me/ojuny-template";
    ref = "my-branch";
    groups = "checks vmTests";
  }
];
```

The jobset name is `<group>-<name>`. Duplicate names, an empty URL, an unknown
group or an empty group list fail evaluation. A row on a fork of
`ojuny-template` is the supported way to test a specific template version.

## Adding a standard repository

Add the repository name to the relevant group in `lib/jobsets.nix` and make
sure the repository exposes `hydraJobs`. Rebuild the server.
