# Settings

The server is headless. `nix-settings-gui` runs on the workstation and edits
this flake. The server receives the built system only.

## Workflow

1. Install `nix-settings-gui` on the workstation.
2. Open `~/repos/ojuny-ci-server` in the GUI.
3. Change a setting.
4. Save.
5. Run `nix run .#install -- --target <user>@server` or
   `nix run .#provision -- --target <user>@server`.

The GUI writes the annotated defaults in `nixos/`. The option declarations and
the annotated defaults are in plain attribute sets so the controls render.
`modules/` holds the flake-parts module declarations that the installers rewrite.

An installer writes `networking.hostName`, `system.stateVersion` and
`ojuny.repoPath` into `modules/00-system.nix`. Those plain assignments take
precedence over the `lib.mkDefault` values that follow the GUI options, so keep
`ci.hostName` equal to the installed hostname when Hydra URLs must match it.
The Disk page drives the disko layout for `provision`; an installer ISO uses the
layout chosen in the installer.

Setup and the installer both write `modules/00-user.nix` before evaluation.
`ci.adminUser` is derived from the account in that file, so the account name is
not a GUI setting. `nixos/users.nix` applies the password hash and SSH keys from
the GUI to the derived account.

## The central setting

`ci.git.username` is the only setting needed when you fork the Ojuny
repositories under your own account or organization with the same names.

If you renamed a repository, add a row to `ci.git.repositories`:

```nix
ci.git.repositories = {
  "ojuny-template" = {
    name = "my-template";
  };
};
```

The generator uses `ci.git.repositories.<standard>.name or <standard>`.

## Extra CI repositories

`ci.jobs.extraRepositories` adds a repository outside the standard list. Each
row carries a name, a flake ref or Git URL, an optional ref, and the job groups:

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

`ref` is appended to `github:`, `gitlab:` and `sourcehut:` refs, and passed as
`?ref=` for other URLs. `groups` is a space-separated list of the job group
names. The row appears under Jobs in the GUI.

## Git host and protocol

- `ci.git.host` defaults to `github.com`.
- `ci.git.protocol` is `https`. The ssh path is not supported because it has no
  key or host-key handling.
- `ci.git.tokenFile` is an optional netrc file for private repositories. It is
  set as `nix.settings.netrc-file`.

## Hydra sizing

- `ci.hydra.maxJobs = 0` uses dynamic PSI scheduling with no cap. A positive
  value caps the builder with `DynamicWithMaxJobLimit`.
- `ci.hydra.maxOutputSize = 0` disables the per-output cap.
- `ci.hydra.minimumDiskFree` and `ci.hydra.minimumDiskFreeEvaluator` stop the
  queue runner and evaluator when the store is low.
- The builder uses every local core per build (`buildCores = 0`).

## Administrator

- `ci.adminUser` is derived from the account module written by setup or the
  installer. It is the system and Hydra administrator name.
- `ci.adminHashedPassword` is the system password hash. Use SSH keys.
- `ci.ssh.authorizedKeys` are the allowed keys.
- `ci.hydra.adminPasswordHash` is a Hydra Argon2id hash.

Generate a Hydra hash with the command in the Hydra help:

```console
$ nix shell nixpkgs#libargon2 -c argon2 ...
```

## Safety

- Do not run the GUI on the server.
- Do not expose a web GUI or SSH proxy.
- Every GUI edit is a normal flake change and is reviewed before deployment.
