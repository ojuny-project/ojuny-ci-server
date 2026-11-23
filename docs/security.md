# Security

## Defaults

- Hydra is opened only on `ci.network.interface`.
- The cache port is opened only when `ci.cache.openFirewall` is on, and then
  only to private, link-local and unique-local ranges.
- SSH is the only globally opened port.
- Root SSH login is disabled. The main account created by setup or the installer
  is the administrator.
- The administrator uses SSH keys.
- The Hydra administrator password is an Argon2id hash.
- `ci.adminUser` is derived from the generated account module.

## Public exposure

Public Hydra is out of scope. If you expose it, put a reverse proxy with TLS in
front and restrict access. Do not expose the cache port to the internet.

## Settings GUI

The server is headless. `nix-settings-gui` runs on the workstation.

A web-based settings GUI and an SSH proxy for the GUI are explicitly out of
scope because they turn a local edit into a remote privileged interface.

## Secrets

- Git token: `ci.git.tokenFile` is a netrc file set as `nix.settings.netrc-file`.
- SSH keys: `ci.ssh.authorizedKeys`.
- Hydra admin: `ci.hydra.adminPasswordHash`.
- Builder authentication: remote builders use the queue runner gRPC endpoint
  with the builder `authorizationFile` or mTLS. This is part of the new
  remote-deploy work.

Do not commit plaintext secrets. Use files with restrictive permissions.

## Cache trust

The cache is LAN-only and unsigned by default. Trust comes from network
membership. Do not route it over an untrusted network.

## Updates

Update the flake, rebuild, and roll back with NixOS generations. There is no
auto-update.
