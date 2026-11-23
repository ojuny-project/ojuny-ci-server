{ self, inputs, ... }:

{
  flake.modules.nixos.disko = {
    imports = [
      inputs.disko.nixosModules.disko
      ../nixos/disk-backend.nix
    ];
  };
}
