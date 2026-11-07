{
  description = "Ojuny CI server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:numtide/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cache-discovery = {
      url = "github:ojuny-project/nix-cache-discovery";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      disko,
      nixos-anywhere,
      nix-cache-discovery,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkSystem =
        system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./modules/default.nix
            disko.nixosModules.disko
            nix-cache-discovery.nixosModules.default
          ];
        };
    in
    {
      nixosConfigurations.ci = mkSystem "x86_64-linux";
      nixosConfigurations.ci-aarch64 = mkSystem "aarch64-linux";

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          configuration =
            self.nixosConfigurations.${if system == "aarch64-linux" then "ci-aarch64" else "ci"}.config;
          jobsets = import ./lib/jobsets.nix {
            lib = nixpkgs.lib;
            ci = configuration.ci;
          };
          provision = pkgs.writeShellApplication {
            name = "provision";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.git
              pkgs.jq
              pkgs.nix
              pkgs.openssh
            ];
            text = ''
              export OJUNY_NIXOS_ANYWHERE="${nixos-anywhere.packages.${system}.default}/bin/nixos-anywhere"
              ${builtins.readFile ./scripts/provision.sh}
            '';
          };
          install = pkgs.writeShellApplication {
            name = "install";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.git
              pkgs.nix
              pkgs.nixos-rebuild
              pkgs.openssh
            ];
            text = builtins.readFile ./scripts/install.sh;
          };
          proxmox-image = pkgs.writeShellApplication {
            name = "proxmox-image";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.nix
              pkgs.nixos-generators
            ];
            text = builtins.readFile ./scripts/proxmox-image.sh;
          };
        in
        {
          inherit provision install proxmox-image;
          jobsets-json = pkgs.writeText "ojuny-jobsets.json" (builtins.toJSON jobsets);
          default = provision;
        }
      );

      apps = forAllSystems (system: {
        ci = {
          type = "app";
          program = "${
            nixpkgs.legacyPackages.${system}.writeShellApplication {
              name = "ci";
              runtimeInputs = [ nixpkgs.legacyPackages.${system}.nix ];
              text = ''
                exec nix flake check "$@"
              '';
            }
          }/bin/ci";
        };
        provision = {
          type = "app";
          program = "${self.packages.${system}.provision}/bin/provision";
        };
        install = {
          type = "app";
          program = "${self.packages.${system}.install}/bin/install";
        };
        proxmox-image = {
          type = "app";
          program = "${self.packages.${system}.proxmox-image}/bin/proxmox-image";
        };
        default = self.apps.${system}.provision;
      });

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          configuration =
            self.nixosConfigurations.${if system == "aarch64-linux" then "ci-aarch64" else "ci"}.config;
          jobsets = import ./lib/jobsets.nix {
            lib = nixpkgs.lib;
            ci = configuration.ci;
          };
          jobsetsJson = pkgs.writeText "ojuny-jobsets.json" (builtins.toJSON jobsets);
          checks = import ./checks {
            inherit pkgs configuration jobsetsJson;
          };
        in
        checks
        // {
          default = pkgs.runCommand "check-default" { } ''
            echo ${checks.settings-eval} >/dev/null
            echo ${checks.jobsets-schema} >/dev/null
            echo ${checks.storage-assertions} >/dev/null
            echo ${checks.options-coverage} >/dev/null
            touch $out
          '';
        }
      );

      hydraJobs = self.checks;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
