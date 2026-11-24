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
      ../nixos/users.nix
      ../nixos/network.nix
      ../nixos/disk.nix
      ../nixos/storage.nix
      ../nixos/storage-backend.nix
      ../nixos/cache.nix
      ../nixos/connect.nix
      ../nixos/hydra.nix
      ../nixos/builder.nix
      ../nixos/jobsets.nix
      inputs.nix-cache-discovery.nixosModules.default
      inputs.nix-connect.nixosModules.default
    ];
  };
}
