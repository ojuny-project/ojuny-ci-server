/* @menu
   displayname = "Jobs";
   icon = "view-list-symbolic";
   order = 70;
   description = "Declarative CI job groups";
*/

{ config, lib, pkgs, ... }:

let
  jobsets = import ../lib/jobsets.nix {
    lib = pkgs.lib;
    ci = config.ci;
  };

  jobsetsJson = pkgs.writeText "ojuny-jobsets.json" (builtins.toJSON jobsets);

  hydraPackage = config.services.hydra.package;
  postgresqlPackage = config.services.postgresql.package;
in
{
  options.ci.jobs = {
    checks = {
      enable = pkgs.lib.mkEnableOption "the checks job group";
    };
    vmTests = {
      enable = pkgs.lib.mkEnableOption "the VM test job group";
    };
    isos = {
      enable = pkgs.lib.mkEnableOption "the ISO build job group";
    };
    persistentImage = {
      enable = pkgs.lib.mkEnableOption "the persistent image job group";
    };
    reproducibility = {
      enable = pkgs.lib.mkEnableOption "the reproducibility job group";
    };
    acceptance = {
      enable = pkgs.lib.mkEnableOption "the acceptance job group";
    };
    installReport = {
      enable = pkgs.lib.mkEnableOption "the install report job group";
    };

    extraRepositories = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Repository name used in the jobset name.";
            };

            url = lib.mkOption {
              type = lib.types.str;
              description = "Flake ref or git URL, for example github:me/ojuny-template.";
            };

            ref = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Branch or revision. Appended to github:, gitlab: and sourcehut: refs; passed as ?ref= otherwise.";
            };

            groups = lib.mkOption {
              type = lib.types.str;
              default = "checks";
              description = "Space-separated job groups, for example \"checks vmTests\".";
            };
          };
        }
      );
      default = [ ];
      description = "Repositories outside the standard Ojuny set, for forks and revision-specific CI.";
    };
  };

  config = {
    /* @option widget = "switch"; label = "Checks"; group = "Job groups"; */
    ci.jobs.checks.enable = true;

    /* @option widget = "switch"; label = "VM tests"; group = "Job groups"; */
    ci.jobs.vmTests.enable = true;

    /* @option widget = "switch"; label = "ISO builds"; group = "Job groups"; description = "Disk-heavy. Enable only when there is enough space."; */
    ci.jobs.isos.enable = false;

    /* @option widget = "switch"; label = "Persistent image"; group = "Job groups"; */
    ci.jobs.persistentImage.enable = false;

    /* @option widget = "switch"; label = "Reproducibility"; group = "Job groups"; */
    ci.jobs.reproducibility.enable = false;

    /* @option widget = "switch"; label = "Acceptance"; group = "Job groups"; description = "Requires KVM."; */
    ci.jobs.acceptance.enable = false;

    /* @option widget = "switch"; label = "Install report"; group = "Job groups"; */
    ci.jobs.installReport.enable = true;

    /* @option widget = "table-list"; label = "Extra repositories"; columns = [ "name" "url" "ref" "groups" ]; columnTypes = [ "str" "str" "str" "str" ]; addLabel = "Add repository"; group = "Repositories"; description = "Full flake ref or git URL. The ref is appended to github:, gitlab: and sourcehut: refs and passed as ?ref= otherwise. Groups are space-separated."; */
    ci.jobs.extraRepositories = [ ];

    systemd.services.ojuny-ci-jobsets = lib.mkIf config.ci.hydra.enable {
      description = "Upsert the Ojuny Hydra project and declarative jobset";
      after = [
        "hydra-init.service"
        "hydra.service"
        "postgresql.service"
      ];
      requires = [
        "hydra-init.service"
        "postgresql.service"
      ];
      wantedBy = [ "multi-user.target" ];
      environment.HYDRA_CONFIG = "/etc/hydra/hydra.conf";
      path = [
        pkgs.coreutils
        pkgs.nix
        hydraPackage
        postgresqlPackage
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "hydra";
        Group = "hydra";
      };
      script = ''
        set -eu
        admin="${config.ci.adminUser}"
        hash='${config.ci.hydra.adminPasswordHash}'

        if ! hydra-create-user "$admin" --password-hash "$hash" --role admin; then
          echo "warning: could not create or update the Hydra administrator" >&2
        fi

        psql -d hydra -v ON_ERROR_STOP=1 -c "
          INSERT INTO Projects (name, displayName, description, enabled, hidden, owner)
          VALUES ('ojuny', 'Ojuny', 'Ojuny CI', 1, 0, '$admin')
          ON CONFLICT (name) DO UPDATE SET
            displayName = EXCLUDED.displayName,
            description = EXCLUDED.description,
            enabled = 1,
            hidden = 0,
            owner = EXCLUDED.owner;
        "

        hydra-prepare-declarative-jobset ojuny ${jobsetsJson}
      '';
    };

    systemd.timers.ojuny-ci-jobsets = lib.mkIf config.ci.hydra.enable {
      description = "Refresh the Ojuny Hydra jobset daily";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };
}
