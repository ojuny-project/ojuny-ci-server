# Security

## Defaults

- Hydra and the cache are opened only on `ci.network.interface`.
- SSH is the only globally opened port.
- Root SSH login is disabled.
- The administrator uses SSH keys.
- The Hydra administrator password is an Argon2id hash.

## Public exposure

Public Hydra is out of scope. If you expose it, put a reverse proxy with TLS in
front and restrict access. Do not expose the cache port to the internet.

## Settings GUI

The server is headless. `nix-settings-gui` runs on the workstation.

A web-based settings GUI and an SSH proxy for the GUI are explicitly out of
scope because they turn a local edit into a remote privileged interface.

## Secrets

- Git token: `ci.git.tokenFile` is a netrc file consumed by Nix.
- SSH keys: `ci.ssh.authorizedKeys`.
- Hydra admin: `ci.hydra.adminPasswordHash`.
- Builder keys: `ci.builders.*.sshKey`.

Do not commit plaintext secrets. Use files with restrictive permissions.

## Cache trust

The cache is LAN-only and unsigned by default. Trust comes from network
membership. Do not route it over an untrusted network.

## Updates

Update the flake, rebuild, and roll back with NixOS generations. There is no
auto-update.
