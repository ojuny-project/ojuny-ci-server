# Contributing

## Before a pull request

```console
$ nix flake check --no-build
$ nix build .#checks.x86_64-linux.default
$ nix build .#packages.x86_64-linux.provision
```

If the change touches the Hydra setup, the cache, storage or deployment
scripts, state the manual test you ran in the pull request.

## Rules

- Read the docs first. The design lives in the repository documentation.
- Keep the server headless. Do not add a web settings GUI or an SSH proxy.
- Do not add a graphical stack.
- Keep settings annotations in plain attribute sets or `lib.mkIf` sets. Do not
  put `@option` inside `lib.mkMerge`, a list, `map`, `forEach` or
  `lib.optionalAttrs`.
- Do not commit secrets. Use the documented file-based options.
- Do not add a hardcoded organization or repository owner.
- Do not make a heavy job a required path for a default deployment.
- Update the docs and the checks with the code.

## Local checks

```console
$ nix flake check --no-build
$ nix build .#checks.x86_64-linux.default
```

The checks include `settings-eval`, `jobsets-schema`, `storage-assertions` and
`options-coverage`.

## Issues

Use the issue forms in this repository. Include the flake revision, the server
generation and the failing service, command or mount.

## Security

Do not open a public issue for a vulnerability. See `SECURITY.md`.
