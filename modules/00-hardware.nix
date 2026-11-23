{ self, ... }:

{
  flake.modules.nixos.system-hardware = {
    imports = [ ];
  };

  flake.modules.nixos.system-bootloader = {
    imports = [ self.modules.nixos.disko ];
  };
}
