# Cache

The server runs `nix-cache-discovery`. It serves its own store and discovers
peers on the same network and port.

## URL

The cache listens on port `ci.cache.port`, default `5055`:

```text
http://<ci.hostName>:5055
```

On a LAN with discovery, clients usually do not need the URL directly.

## Discovery

`ci.cache.discovery.auto` uses the connected subnet for discovery and the
client allowlist. Set it off to use `ci.cache.discovery.ranges`.

`ci.cache.openFirewall` opens the cache port to the private, link-local and
unique-local ranges. It never opens the port to internet addresses.

## Trust

- The cache is LAN-only by default.
- There is no project signing key.
- The module trusts local peers by network membership.
- Do not expose the cache port to the internet.

## Fallback

`nix-cache-discovery` can proxy upstream caches after the local store and live
LAN peers. The module defaults to `cache.nixos.org`.
