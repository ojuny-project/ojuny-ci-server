{ ... }:

{
  flake.modules.nixos.system-hardware = {
    imports = [ ];
  };

  flake.modules.nixos.system-bootloader = {
    imports = [
      ../nixos/disk-backend.nix
    ];
  };
}
