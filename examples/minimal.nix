# Minimal overrides
#
# Copy the settings you need into a module imported by modules/default.nix.
{ ... }:

{
  ci.git.username = "your-name";
  ci.hostName = "ojuny-ci";
  ci.ssh.authorizedKeys = [
    "ssh-ed25519 AAAA... you@workstation"
  ];
}
