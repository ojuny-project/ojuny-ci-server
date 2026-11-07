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
change is picked up without a reboot.

Inspect the generated jobset without a server:

```console
$ nix build .#packages.x86_64-linux.jobsets-json
$ nix store cat result
```

## Adding a repository

Add the repository name to the relevant group in `lib/jobsets.nix` and make
sure the repository exposes `hydraJobs`. Rebuild the server.
