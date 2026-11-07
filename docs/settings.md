# Settings

The server is headless. `nix-settings-gui` runs on the workstation and edits
this flake. The server receives the built system only.

## Workflow

1. Install `nix-settings-gui` on the workstation.
2. Open `~/repos/ojuny-ci-server` in the GUI.
3. Change a setting.
4. Save.
5. Run `nix run .#install -- --target root@server` or
   `nix run .#provision -- --target root@server --disk /dev/vda`.

The GUI writes the annotated defaults in `modules/`. The option declarations
and the annotated defaults are in plain attribute sets so the controls render.

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

## Git host and protocol

- `ci.git.host` defaults to `github.com`.
- `ci.git.protocol` is `https` or `ssh`.
- `ci.git.tokenFile` is an optional netrc file for private repositories.

## Administrator

- `ci.adminUser` is the system and Hydra administrator name.
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
