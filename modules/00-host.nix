{ self, inputs, ... }:

let
  mkSystem =
    system:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        self.modules.nixos.host-imports
      ];
    };
in
{
  flake.nixosConfigurations.ci = mkSystem "x86_64-linux";
  flake.nixosConfigurations.ci-aarch64 = mkSystem "aarch64-linux";
}
