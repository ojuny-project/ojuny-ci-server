{ self, inputs, ... }:

{
  flake.modules.nixos.host-imports = {
    imports = [
      self.modules.nixos.system-configuration
      self.modules.nixos.users
      self.modules.nixos.system-hardware
      self.modules.nixos.system-bootloader
      ../nixos/settings.nix
      ../nixos/system.nix
      ../nixos/network.nix
      ../nixos/disk.nix
      ../nixos/storage.nix
      ../nixos/storage-backend.nix
      ../nixos/cache.nix
      ../nixos/hydra.nix
      ../nixos/jobsets.nix
      ../nixos/builders.nix
      ../nixos/builders-backend.nix
      inputs.disko.nixosModules.disko
      inputs.nix-cache-discovery.nixosModules.default
    ];
  };
}
