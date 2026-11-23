{
  pkgs,
  configuration,
  jobsetsJson,
  root,
}:

let
  checkSrc = pkgs.runCommand "ojuny-check-src" { } ''
    mkdir -p $out
    cp ${root}/scripts/check-template.py $out/check-template.py
    cp ${root}/scripts/flake_structure.py $out/flake_structure.py
  '';

  primaryUserNested = import ../lib/primary-user.nix {
    lib = pkgs.lib;
    text = "users.users = { den = { }; };";
  };

  primaryUserDirect = import ../lib/primary-user.nix {
    lib = pkgs.lib;
    text = "users.users.den = { };";
  };

  primaryUserFallback = import ../lib/primary-user.nix {
    lib = pkgs.lib;
    text = "{ imports = [ ../nixos/users.nix ]; }";
  };

  groupNames = builtins.filter (
    name:
    builtins.isAttrs configuration.ci.jobs.${name}
    && (configuration.ci.jobs.${name} ? enable)
  ) (builtins.attrNames configuration.ci.jobs);

  checks = {
    settings-eval = pkgs.runCommand "check-settings" { } ''
      test -n "${configuration.ci.git.username}"
      test -n "${configuration.ci.hostName}"
      test -n "${configuration.ci.adminUser}"
      touch $out
    '';

    jobsets-schema = pkgs.runCommand "check-jobsets-schema" {
      nativeBuildInputs = [ pkgs.python3 ];
    } ''
      python3 ${./jobsets_schema.py} ${jobsetsJson} ${
        pkgs.writeText "groups.json" (builtins.toJSON groupNames)
      }
      touch $out
    '';

    storage-assertions = pkgs.runCommand "check-storage-assertions" {
      nativeBuildInputs = [ pkgs.python3 ];
    } ''
      python3 ${./storage_assertions.py} ${
        pkgs.writeText "mounts.json" (builtins.toJSON configuration.ci.storage.mounts)
      }
      touch $out
    '';

    options-coverage = pkgs.runCommand "check-options-coverage" {
      nativeBuildInputs = [ pkgs.python3 ];
    } ''
      python3 ${./options_coverage.py} ${../modules} ${../nixos}
      touch $out
    '';

    template = pkgs.runCommand "check-template-static" {
      nativeBuildInputs = [ pkgs.python3 ];
    } ''
      python3 ${checkSrc}/check-template.py --root ${root} --static
      touch $out
    '';

    installer-ownership = pkgs.runCommand "check-installer-ownership" {
      nativeBuildInputs = [ pkgs.python3 ];
    } ''
      python3 ${./installer_ownership.py} ${root}
      touch $out
    '';

    primary-user = pkgs.runCommand "check-primary-user" { } ''
      test "${primaryUserNested}" = "den"
      test "${primaryUserDirect}" = "den"
      test "${primaryUserFallback}" = "admin"
      touch $out
    '';
  };
in
checks
// {
  default = pkgs.runCommand "check-default" { } ''
    echo ${checks.settings-eval} >/dev/null
    echo ${checks.jobsets-schema} >/dev/null
    echo ${checks.storage-assertions} >/dev/null
    echo ${checks.options-coverage} >/dev/null
    echo ${checks.template} >/dev/null
    echo ${checks.installer-ownership} >/dev/null
    echo ${checks.primary-user} >/dev/null
    touch $out
  '';
}
