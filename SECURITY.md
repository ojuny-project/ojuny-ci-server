# Security policy

## Supported versions

`ojuny-ci-server` is a rolling flake. The supported version is the latest commit
on `main` and its committed `flake.lock`. Older revisions are not supported.

## Reporting a vulnerability

Use GitHub private vulnerability reporting for this repository. Do not open a
public issue for a vulnerability.

Include:

- the flake revision and lock hash
- the affected service or script
- the steps to reproduce
- the impact
- any suggested fix

## Scope

In scope:

- the NixOS modules in `modules/`
- the deployment scripts in `scripts/`
- the checks in `checks/`
- the jobset generator in `lib/jobsets.nix`
- the documented security boundary

Out of scope:

- vulnerabilities in Hydra, PostgreSQL, `nix-cache-discovery` or nixpkgs.
  Report those upstream.
- a deliberately public Hydra or cache port
- a deliberately weakened administrator configuration
- a fork with its own changes

## Posture

- Hydra and the cache are LAN-only by default.
- SSH is the only globally opened port.
- The administrator uses SSH keys.
- The Hydra administrator password is an Argon2id hash.
- Public Hydra is out of scope. It requires a reverse proxy and TLS.
- The cache is unsigned and trusted by LAN membership.
- There is no telemetry.

## Response

Best effort. No bounty, no security team and no SLA.
