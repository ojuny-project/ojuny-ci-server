{ ... }:

{
  flake.modules.nixos.users = {
    imports = [
      ../nixos/users.nix
    ];
  };
}
