{
  description = "Ojuny CI server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

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

    nix-connect = {
      url = "github:ojuny-project/nix-connect";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      hostFor = system: if system == "aarch64-linux" then "ci-aarch64" else "ci";

      mkTools =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          checkSrc = pkgs.runCommand "ojuny-check-src" { } ''
            mkdir -p $out
            cp ${./scripts/check-template.py} $out/check-template.py
            cp ${./scripts/flake_structure.py} $out/flake_structure.py
          '';

          generate-hw = pkgs.writeShellApplication {
            name = "generate-hw";
            runtimeInputs = [
              pkgs.python3
              pkgs.nixos-install-tools
              pkgs.nixos-facter
              pkgs.coreutils
              pkgs.gnused
              pkgs.gnugrep
              pkgs.util-linux
              pkgs.sudo
            ];
            text = builtins.readFile ./scripts/generate-hw.sh;
          };

          generate-user = pkgs.writeShellApplication {
            name = "generate-user";
            runtimeInputs = [
              pkgs.python3
              pkgs.mkpasswd
              pkgs.coreutils
            ];
            text = builtins.readFile ./scripts/generate-user.sh;
          };

          create-new-system = pkgs.writeShellApplication {
            name = "create-new-system";
            runtimeInputs = [
              pkgs.python3
              pkgs.coreutils
            ];
            text = builtins.readFile ./scripts/create-new-system.sh;
          };

          check = pkgs.writeShellApplication {
            name = "check";
            runtimeInputs = [
              pkgs.python3
              pkgs.nix
            ];
            text = ''
              export TEMPLATE_ROOT=${./.}
              exec python3 ${checkSrc}/check-template.py --root "$TEMPLATE_ROOT" "$@"
            '';
          };

          setup = pkgs.writeShellApplication {
            name = "setup";
            runtimeInputs = [
              pkgs.python3
              pkgs.nix
              pkgs.git
              pkgs.coreutils
              generate-user
              create-new-system
            ];
            text = builtins.readFile ./scripts/setup.sh;
          };

          prepare-repo = pkgs.writeShellApplication {
            name = "prepare-repo";
            runtimeInputs = [ pkgs.python3 ];
            text = ''
              export PYTHONPATH=${./scripts}:$PYTHONPATH
              exec python3 ${./scripts/prepare-repo.py} "$@"
            '';
          };

          remote-setup = pkgs.writeShellApplication {
            name = "remote-setup";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.git
              pkgs.openssh
              pkgs.nix
              inputs.deploy-rs.packages.${system}.default
            ];
            text = ''
              export OJUNY_TEMPLATE_SOURCE="${./.}"
              export OJUNY_DEPLOY_RS="${inputs.deploy-rs.packages.${system}.default}/bin/deploy"
              ${builtins.readFile ./scripts/remote-setup.sh}
            '';
          };

          remote-install = pkgs.writeShellApplication {
            name = "remote-install";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.git
              pkgs.gnused
              pkgs.nix
              pkgs.openssh
              inputs.disko.packages.${system}.disko
              inputs.nixos-anywhere.packages.${system}.default
            ];
            text = ''
              export OJUNY_TEMPLATE_SOURCE="${./.}"
              export OJUNY_DISKO="${inputs.disko.packages.${system}.disko}/bin/disko"
              export OJUNY_NIXOS_ANYWHERE="${inputs.nixos-anywhere.packages.${system}.default}/bin/nixos-anywhere"
              ${builtins.readFile ./scripts/remote-install.sh}
            '';
          };

          prepare-remote-repository = pkgs.writeShellApplication {
            name = "prepare-remote-repository";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.git
              pkgs.gnused
              pkgs.mkpasswd
              pkgs.nix
              pkgs.python3
            ];
            text = ''
              export OJUNY_TEMPLATE_SOURCE="${./.}"
              ${builtins.readFile ./scripts/prepare-remote-repository.sh}
            '';
          };
        in
        {
          inherit
            setup
            generate-hw
            generate-user
            create-new-system
            check
            prepare-repo
            remote-setup
            remote-install
            prepare-remote-repository
            ;
        };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (inputs.import-tree ./modules)
        inputs.flake-parts.flakeModules.modules
      ];

      inherit systems;

      flake = {
        packages = forAllSystems (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            configuration = self.nixosConfigurations.${hostFor system}.config;
            jobsets = import ./lib/jobsets.nix {
              lib = pkgs.lib;
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
                export OJUNY_NIXOS_ANYWHERE="${inputs.nixos-anywhere.packages.${system}.default}/bin/nixos-anywhere"
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
            prepare-repo = (mkTools system).prepare-repo;
            jobsets-json = pkgs.writeText "ojuny-jobsets.json" (builtins.toJSON jobsets);
            default = provision;
          }
        );

        apps = forAllSystems (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            tools = mkTools system;
            provision = self.packages.${system}.provision;
            install = self.packages.${system}.install;
            proxmox-image = self.packages.${system}.proxmox-image;
          in
          {
            ci = {
              type = "app";
              program = "${
                pkgs.writeShellApplication {
                  name = "ci";
                  runtimeInputs = [ pkgs.nix ];
                  text = ''
                    exec nix flake check "$@"
                  '';
                }
              }/bin/ci";
            };
            provision = {
              type = "app";
              program = "${provision}/bin/provision";
            };
            install = {
              type = "app";
              program = "${install}/bin/install";
            };
            proxmox-image = {
              type = "app";
              program = "${proxmox-image}/bin/proxmox-image";
            };
            setup = {
              type = "app";
              program = "${tools.setup}/bin/setup";
            };
            generate-hw = {
              type = "app";
              program = "${tools.generate-hw}/bin/generate-hw";
            };
            generate-user = {
              type = "app";
              program = "${tools.generate-user}/bin/generate-user";
            };
            create-new-system = {
              type = "app";
              program = "${tools.create-new-system}/bin/create-new-system";
            };
            check = {
              type = "app";
              program = "${tools.check}/bin/check";
            };
            prepare-repo = {
              type = "app";
              program = "${tools.prepare-repo}/bin/prepare-repo";
            };
            remote-setup = {
              type = "app";
              program = "${tools.remote-setup}/bin/remote-setup";
            };
            remote-install = {
              type = "app";
              program = "${tools.remote-install}/bin/remote-install";
            };
            prepare-remote-repository = {
              type = "app";
              program = "${tools.prepare-remote-repository}/bin/prepare-remote-repository";
            };
            default = {
              type = "app";
              program = "${provision}/bin/provision";
            };
          }
        );

        checks = forAllSystems (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            configuration = self.nixosConfigurations.${hostFor system}.config;
            jobsets = import ./lib/jobsets.nix {
              lib = pkgs.lib;
              ci = configuration.ci;
            };
            jobsetsJson = pkgs.writeText "ojuny-jobsets.json" (builtins.toJSON jobsets);
          in
          import ./checks {
            inherit pkgs configuration jobsetsJson;
            root = ./.;
          }
        );

        deploy.nodes = builtins.mapAttrs (
          name: configuration: {
            hostname = name;
            sshUser = configuration.config.ci.adminUser;
            profiles.system = {
              user = "root";
              path =
                inputs.deploy-rs.lib.${configuration.config.nixpkgs.hostPlatform.system}.activate.nixos
                  configuration;
            };
          }
        ) self.nixosConfigurations;

        hydraJobs = {
          x86_64-linux = self.checks.x86_64-linux;
        };

        formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
      };
    };
}
